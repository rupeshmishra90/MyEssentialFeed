//
//  Untitled.swift
//  MyEssentialFeed
//
//  Created by Rupesh Mishra on 27/09/24.
//
import Foundation
public protocol HTTPClient{
    func get(from url: URL, compoletion: @escaping (Error)-> Void)
}
public final class RemoteFeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error{
        case connectivity
    }
    
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion: @escaping (Error)-> Void = { _ in})
    {
        client.get(from: url){ error in
            completion(.connectivity)
        }
    }
}