//
//  SearchViewModel.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

class SearchViewModel {
    func fetchPhotos(for searchText: String, page: Int = 1, resultsPerPage: Int = 10, onCompleton: @escaping (Result<[Photo], Error>) -> ()) {
        let request = FlickrAPI.SearchPhotosEndpoint(searchText: searchText, page: page, resultsPerPage: resultsPerPage).makeRequest()
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                onCompleton(.failure(error))
            } else if let data = data {
                do {
                    let response = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                    print(response)
                } catch {
                    onCompleton(.failure(error))
                }
            }
        }
        .resume()
    }
}
