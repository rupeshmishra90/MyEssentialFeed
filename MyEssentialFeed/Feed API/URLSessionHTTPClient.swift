//
//  URLSessionHTTPClient.swift
//  MyEssentialFeed
//
//  Created by Rupesh Kumar on 19/01/25.
//
import Foundation
public class URLSessionHTTPClient: HTTPClient{
    private let session: URLSession
    
    public init(session: URLSession = .shared){
        self.session = session
    }
    struct UnexpectedValuesRepresntation: Error{
        
    }
    public func get(from url: URL, compoletion completion: @escaping (HTTPClientResult)->Void){
        session.dataTask(with: url){data, response, error in
            if let error = error{
                completion(.failure(error))
            }else if let data = data, let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            }else{
                completion(.failure(UnexpectedValuesRepresntation()))
            }
        }
        .resume()
    }
}
