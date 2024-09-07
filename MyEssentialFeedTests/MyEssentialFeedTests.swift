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
    init(client: HTTPClient) {
        self.client = client
    }
    func load()
    {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}
protocol HTTPClient{
    func get(from url: URL)
}
class HTTPClientSpy: HTTPClient{
    var requestedURL: URL?
    
    func get(from url: URL)
    {
        requestedURL = url
    }
}

final class MyEssentialFeedTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init_doesNotRequestDataFromURL()
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL()
    {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
    }

}
