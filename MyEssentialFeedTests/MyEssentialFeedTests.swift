//
//  MyEssentialFeedTests.swift
//  MyEssentialFeedTests
//
//  Created by Rupesh Mishra on 05/09/24.
//

import XCTest
@testable import MyEssentialFeed

class RemoteFeedLoader{
    let client: HTTPClient
    let url: URL
    init(url: URL,client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load()
    {
        client.get(from: url)
    }
}
protocol HTTPClient{
    func get(from url: URL)
}


final class MyEssentialFeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    //MARK: - Test functions
    func test_init_doesNotRequestDataFromURL()
    {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL()
    {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
    }
    
    //MARK: - Create factory methods (Helpers)
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!)-> (sut: RemoteFeedLoader, client: HTTPClientSpy)
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }

    
    private class HTTPClientSpy: HTTPClient{
        var requestedURL: URL?
        
        func get(from url: URL)
        {
            requestedURL = url
        }
    }
}
