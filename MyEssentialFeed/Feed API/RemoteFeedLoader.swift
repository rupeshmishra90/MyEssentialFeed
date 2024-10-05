//
//  Untitled.swift
//  MyEssentialFeed
//
//  Created by Rupesh Mishra on 27/09/24.
//
import Foundation
public protocol HTTPClient{
    func get(from url: URL)
}
public final class RemoteFeedLoader{
    private let client: HTTPClient
    private let url: URL
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load()
    {
        client.get(from: url)
    }
}
