//
//  ImagesLoader.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import Foundation

public protocol ImagesSearchLoader {
    typealias Result = Swift.Result<ImagesSerach, Error>

    func load(_ search: String, completion: @escaping (Result) -> Void)
}
