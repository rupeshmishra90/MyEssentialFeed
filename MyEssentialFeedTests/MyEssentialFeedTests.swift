//
//  MyEssentialFeedTests.swift
//  MyEssentialFeedTests
//
//  Created by Rupesh Mishra on 05/09/24.
//

import XCTest
@testable import MyEssentialFeed

class RemoteFeedLoader{
    
}
class HTTPClient{
    var requestedURL: URL?
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
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
