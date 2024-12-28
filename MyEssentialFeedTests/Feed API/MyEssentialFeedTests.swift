//
//  MyEssentialFeedTests.swift
//  MyEssentialFeedTests
//
//  Created by Rupesh Mishra on 05/09/24.
//

import XCTest
import MyEssentialFeed


final class MyEssentialFeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_doesNotRequestDataFromURL()
    {
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL()
    {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in}
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice()
    {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        sut.load{ _ in}
        sut.load{ _ in}
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError()
    {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse()
    {
        let (sut, client) = makeSUT()
        let samples = [199,201,300,400,500]
        samples.enumerated().forEach{ index, code in
            expect(sut, toCompleteWith: .failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
        
    }
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON()
    {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith:  .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data(bytes: "invalid json", count: "invalid json".count)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList()
    {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        }
        
    }
    func test_load_deliversItemsOn200HTTPResponseWithJSONItems()
    {
        let (sut, client) = makeSUT()
        let item1 = makeItem(
                    id: UUID(),
                    imageURL: URL(string: "http://a-url.com")!)

                let item2 = makeItem(
                    id: UUID(),
                    description: "a description",
                    location: "a location",
                    imageURL: URL(string: "http://another-url.com")!)

                let items = [item1.model, item2.model]

                expect(sut, toCompleteWith: .success(items), when: {
                    let json = makeItemsJSON([item1.json, item2.json])
                    client.complete(withStatusCode: 200, data: json)
                })
    }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated()
    {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load{ capturedResults.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssert(capturedResults.isEmpty)
    }
    //MARK: - Helper functions
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL)-> (model: FeedItem, json: [String: Any]){
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        let itemJson = ["id": id.uuidString,
                         "description": description,
                         "location": location,
                        "image": imageURL.absoluteString].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value
            }
        }
        return (item, itemJson)
    }
    private func trackForMemoryLeaks(_ instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line)
    {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leaks.", file: file, line: line)
        }
    }
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
            let json = ["items": items]
            return try! JSONSerialization.data(withJSONObject: json)
        }
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result,
    file: StaticString = #filePath,
    line: UInt = #line, when action: ()-> Void)
    {
        let exp = expectation(description: "Wait for loader to completion")
        sut.load{ receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result: \(expectedResult) got \(receivedResult) insted", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
    }
    private class HTTPClientSpy: HTTPClient{
        private var messages = [(url: URL, completion: (HTTPClientResult)-> Void)]()
        var requestedURLs: [URL]{
            return messages.map{$0.url}
        }
        func get(from url: URL, compoletion: @escaping (HTTPClientResult) -> Void)
        {
            messages.append((url,compoletion))
        }
        func complete(with error: Error, at index: Int = 0)
        {
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0)
        {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success( data, response))
        }
    }
}
