//
//  Untitled.swift
//  MyEssentialFeed
//
//  Created by Rupesh Mishra on 27/09/24.
//
import Foundation


public enum HTTPClientResult{
    case success( Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, compoletion: @escaping (HTTPClientResult)-> Void)
}
public final class RemoteFeedLoader{
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error{
        case connectivity
        case invalidData
    }
    public enum Result: Equatable{
        case success([FeedItem])
        case failure(Error)
    }
    public init(url: URL,client: HTTPClient) {
        self.url = url
        self.client = client
    }
    public func load(completion: @escaping (Result)-> Void)
    {
        client.get(from: url){ result  in
            switch result{
            case let .success(data, _):
                if let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
                }else{
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable{
    let items: [FeedItem]
}
