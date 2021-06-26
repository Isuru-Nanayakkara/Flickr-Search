//
//  FlickrAPI.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

struct FlickrAPI {
    struct SearchPhotosEndpoint {
        let method = "flickr.photos.search"
        let format = "json"
        let apiKey = "873aa7a6882640372aa70014d983d242"
        
        var searchText: String
        var page: Int
        var resultsPerPage: Int
        
        func makeRequest() -> URLRequest {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "api.flickr.com"
            components.path = "/services/rest"
            
            components.queryItems = [
                URLQueryItem(name: "method", value: method),
                URLQueryItem(name: "api_key", value: apiKey),
                URLQueryItem(name: "format", value: format),
                URLQueryItem(name: "nojsoncallback", value: String(1)),
                URLQueryItem(name: "text", value: searchText),
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "per_page", value: String(resultsPerPage)),
                URLQueryItem(name: "sort", value: "relevance"),
            ]
            
            return URLRequest(url: components.url!)
        }
    }
}
