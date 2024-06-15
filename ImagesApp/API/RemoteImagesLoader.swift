//
//  ImagesLoader.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import Foundation

public final class RemoteImagesLoader: ImagesSearchLoader {
    public static let baseURL = URL(string: "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=")!
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL = baseURL,
                client: HTTPClient = URLSessionHTTPClient()) {
        self.url = url
        self.client = client
    }

    public func load(_ search: String,
                     completion: @escaping (ImagesSearchLoader.Result) -> Void) {
        guard let urlWithSearch = URL(string: url.absoluteString.appending(search))
        else { return completion(.failure(RemoteImagesLoader.Error.connectivity)) }

        client.get(from: urlWithSearch) { [weak self] result in
            self?.handleLoadResult(result, completion: completion)
        }
    }

    private func handleLoadResult(_ result: HTTPClient.Result,
                                  completion: (ImagesSearchLoader.Result) -> Void) {
        switch result {
        case let .success((data, response)):
            completion(ImagesSerachMapper.map(data, from: response))
        case .failure:
            completion(.failure(RemoteImagesLoader.Error.connectivity))
        }
    }
}
