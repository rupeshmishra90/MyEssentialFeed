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
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice()
    {
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError()
    {
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load{ capturedErrors.append($0)}
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    //MARK: - Helper functions
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient{
        private var messages = [(url: URL, completion: ((Error)-> Void))]()
        var requestedURLs: [URL]{
            return messages.map{$0.url}
        }
        func get(from url: URL, compoletion: @escaping (Error)-> Void)
        {
            messages.append((url,compoletion))
        }
        
        func complete(with error: Error, at index: Int = 0)
        {
            messages[index].completion(error)
        }
    }
}
