//
//  HTTPClient.swift
//  MyEssentialFeed
//
//  Created by Rupesh Kumar on 17/11/24.
//
import Foundation
public enum HTTPClientResult{
    case success( Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, compoletion: @escaping (HTTPClientResult)-> Void)
}
