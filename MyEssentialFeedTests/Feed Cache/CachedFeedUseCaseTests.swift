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
    private let currentDate: ()-> Date
    init(store: FeedStore, currentDate: @escaping ()-> Date){
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]){
        store.deleteCachedFeed{[unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore{
    typealias DeletionCompletion = (Error?) -> Void
    
    private var deletionCompletions: [DeletionCompletion] = []
    
    enum RecievedMessage: Equatable{
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    private(set) var receivedMessages = [RecievedMessage]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion){
        
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    func completeDeletion(with error: Error?, at index: Int = 0){
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index: Int = 0){
        deletionCompletions[index](nil)
    }
    func insert(_ items: [FeedItem], timestamp: Date)
    {
        
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CachedFeedUseCaseTests: XCTestCase{
    func test_init_doesNotMessageStoreUponCreation()
    {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    func test_save_requestCacheDeletion(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        
        sut.save(items)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    
    
    func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion(){
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT(currentDate: {timestamp})
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
        
    }
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping ()-> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore ){
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func uniqueItem() -> FeedItem{
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    private func anyNSError()-> NSError? {
        return  NSError(domain: "any error", code: 0)
    }
}
