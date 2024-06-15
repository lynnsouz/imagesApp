//
//  SearchImagesViewModel.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import Foundation

protocol SearchViewModel: ObservableObject {
    var search: String { get set }
    var state: SearchImagesState { get set }
    
    func serach()
}

enum SearchImagesState {
    case loading
    case ready(ImagesSerach)
    case empty
    case error
}

final class SearchImagesViewModel: SearchViewModel {
    @Published var search: String
    @Published var state: SearchImagesState
    var loader: ImagesSearchLoader
    
    init(search: String = "",
         state: SearchImagesState = .empty,
         loader: ImagesSearchLoader = RemoteImagesLoader()) {
        self.search = search
        self.state = state
        self.loader = loader
    }
    
    func serach() {
        state = .loading

        loader.load(search) { [weak self] result in
            print(result)
            self?.handleSearchResult(result)
        }
    }
    
    private func handleSearchResult(_ result: ImagesSearchLoader.Result) {
        DispatchQueue.main.async { [weak self] in
            switch result {
            case let .success(images):
                guard !images.items.isEmpty else {
                    self?.state = .empty
                    return
                }
                
                self?.state = .ready(images)
            case .failure:
                self?.state = .error
            }
        }
    }
}
