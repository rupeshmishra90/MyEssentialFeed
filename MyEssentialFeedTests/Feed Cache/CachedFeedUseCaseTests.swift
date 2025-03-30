//
//  CachedFeedUseCaseTests.swift
//  MyEssentialFeed
//
//  Created by Rupesh Kumar on 30/03/25.
//

import XCTest

class LocalFeedLoader{
//    var store: FeedStore
    
    init(store: FeedStore){
//        self.store = store
    }
}

class FeedStore{
    var deleteCachedFeedCallCount = 0
}

class CachedFeedUseCaseTests: XCTestCase{
    func test()
    {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
