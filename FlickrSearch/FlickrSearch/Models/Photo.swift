//
//  Photo.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

struct Photo {
    let id: String
    let secret: String
    let server: String
    let farm: Int
}

extension Photo: Decodable { }

extension Photo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(secret)
        hasher.combine(server)
    }
}
