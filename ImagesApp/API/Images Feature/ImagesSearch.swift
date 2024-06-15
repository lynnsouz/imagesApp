//
//  ImagesSearch.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import Foundation

public struct ImagesSerach: Codable, Equatable {
    let id: UUID
    let title: String
    let items: [ImageItem]
    
    public init(id: UUID = UUID(),
                title: String,
                items: [ImageItem]) {
        self.id = id
        self.title = title
        self.items = items
    }
    
    public static func == (lhs: ImagesSerach, rhs: ImagesSerach) -> Bool {
        lhs.title == rhs.title && lhs.items == rhs.items
    }
}

public struct ImageItem: Codable, Equatable, Identifiable {
    public let id: UUID
    let title: String
    let link: String
    let description: String
    let author: String
    let tags: String
    
    public init(id: UUID = UUID(),
                title: String,
                link: String,
                description: String,
                author: String,
                tags: String) {
        self.id = id
        self.title = title
        self.link = link
        self.description = description
        self.author = author
        self.tags = tags
    }
    
    public static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.title == rhs.title && lhs.link == rhs.link
    }
}


class ImagesSerachMapper {
    private init() {}
    
    private struct Media: Decodable{
        let m: String
    }
    
    private struct ImageDecodable: Decodable {
        let title: String
        let description: String
        let author, tags: String
        let media: Media
        
        var image: ImageItem {
            ImageItem(title: title,
                      link: media.m,
                      description: description,
                      author: author,
                      tags: tags)
        }
    }
    
    private struct ImagesSerachResponse: Decodable {
        let title: String
        let link: String
        let description: String
        let items: [ImageDecodable]
        
        var response: ImagesSerach {
            ImagesSerach(title: title,
                         items: items.map(\.image))
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data,
                    from response: HTTPURLResponse) -> ImagesSearchLoader.Result {
        guard response.statusCode == ImagesSerachMapper.OK_200,
              let result = try? JSONDecoder().decode(ImagesSerachResponse.self, from: data)
        else { return .failure(RemoteImagesLoader.Error.invalidData) }
        
        return .success(result.response)
    }
}
