//
//  MockFlickrAPI.swift
//  FlickrSearchTests
//
//  Created by Isuru Nanayakkara on 2021-07-01.
//

import Foundation
@testable import Flickr_Search

class MockFlickrAPI: FlickrAPIProvider {
    func fetchPhotos(for searchText: String, page: Int, resultsPerPage: Int, onCompletion: @escaping (Result<SearchPhotosResponse, Error>) -> ()) {
        if searchText == "cat" {
            let response = SearchPhotosResponse(page: 1, pages: 10, total: 1000, photos: [
                Photo(id: "", secret: "", server: "", farm: 0),
                Photo(id: "", secret: "", server: "", farm: 0),
                Photo(id: "", secret: "", server: "", farm: 0)
            ])
            onCompletion(.success(response))
        }
    }
}
