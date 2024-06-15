//
//  ImagesSearch.swift
//  ImagesApp
//
//  Created by Lynneker Souza on 15/06/24.
//

import Foundation

public struct ImagesSerach: Codable, Equatable {
    let title: String
    let items: [ImageItem]
    
    public init(title: String,
                items: [ImageItem]) {
        self.title = title
        self.items = items
    }
    
    public static func == (lhs: ImagesSerach, rhs: ImagesSerach) -> Bool {
        lhs.title == rhs.title && lhs.items == rhs.items
    }
}

public struct ImageItem: Codable, Equatable {
    let title: String
    let link: String
    let description: String
    let author: String
    let tags: String
    
    public static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.title == rhs.title && lhs.link == rhs.link
    }
}


class ImagesSerachMapper {
    private init() {}
    
    private struct ImageDecodable: Decodable {
        let title: String
        let link: String
        let media: Media
        let dateTaken: Date
        let description: String
        let published: Date
        let author, authorID, tags: String
        
        struct Media: Decodable {
            let m: String
        }
        
        enum CodingKeys: String, CodingKey {
            case title, link, media
            case dateTaken = "date_taken"
            case description, published, author
            case authorID = "author_id"
            case tags
        }
        
        var image: ImageItem {
            ImageItem(title: title,
                      link: link,
                      description: description,
                      author: author,
                      tags: tags)
        }
    }
    
    private struct ImagesSerachResponse: Decodable {
        let title: String
        let link: String
        let description: String
        let modified: Date
        let generator: String
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
