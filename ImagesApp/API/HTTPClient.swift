//
//  HTTPClient.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
