//
//  FlickrPhotoURLBuilder.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

final class FlickrPhotoURLBuilder {
    private(set) var farm: Int
    private(set) var server: String
    private(set) var id: String
    private(set) var secret: String
    private(set) var size: Size?
    
    enum Size: String {
        case thumbnail = "q"
        case small = "m"
        case medium = "z"
        case large = "b"
    }
    
    
    init(farm: Int, server: String, id: String, secret: String) {
        self.farm = farm
        self.server = server
        self.id = id
        self.secret = secret
    }
    
    func size(_ size: Size) -> FlickrPhotoURLBuilder {
        self.size = size
        return self
    }
    
    func build() -> URL {
        // https://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg
        // With size: https://farm1.static.flickr.com/578/23451156376_8983a8ebc7_{size}.jpg
        // Ex: https://farm1.static.flickr.com/578/23451156376_8983a8ebc7.jpg
        
        if let size = size {
            let urlString = "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret)_\(size.rawValue).jpg"
            return URL(string: urlString)!
        } else {
            let urlString = "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
            return URL(string: urlString)!
        }
    }
}
