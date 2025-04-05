//
//  CachedFeedUseCaseTests.swift
//  MyEssentialFeed
//
//  Created by Rupesh Kumar on 30/03/25.
//

import XCTest
import MyEssentialFeed
class LocalFeedLoader{
    var store: FeedStore
    
    init(store: FeedStore){
        self.store = store
    }
    
    func save(_ items: [FeedItem]){
        store.deleteCachedFeed()
    }
}

class FeedStore{
    var deleteCachedFeedCallCount = 0
    func deleteCachedFeed(){
        deleteCachedFeedCallCount += 1
    }
}

class CachedFeedUseCaseTests: XCTestCase{
    func test_init_doesNotDeleteCacheUponCreation()
    {
        let (_, store) = makeSUT()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    func test_save_requestCacheDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    //MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore ){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        return (sut: sut, store: store)
    }
    
    private func uniqueItem() -> FeedItem{
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
