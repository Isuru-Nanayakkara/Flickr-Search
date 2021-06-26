//
//  SearchPhotosResponse.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

struct SearchPhotosResponse {
    let page: Int
    let pages: Int
    let total: Int
    let photos: [Photo]
}

extension SearchPhotosResponse: Decodable {
    private enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
    
    private enum NestedCodingKeys: String, CodingKey {
        case page
        case pages
        case total
        case photos = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let photosContainer = try container.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .photos)
        
        page = try photosContainer.decode(Int.self, forKey: .page)
        pages = try photosContainer.decode(Int.self, forKey: .pages)
        total = try photosContainer.decode(Int.self, forKey: .total)
        photos = try photosContainer.decode([Photo].self, forKey: .photos)
    }
}
