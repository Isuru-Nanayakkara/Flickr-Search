//
//  SearchPresenter.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

protocol SearchPresenterDelegate: AnyObject {
    func didFetchPhotos(_ error: Error?)
}

class SearchPresenter {
    private let resultsPerPage = 10
    
    weak private(set) var delegate: SearchPresenterDelegate?
    
    private(set) var photos: [Photo] = []
    private var page: Int = 0
    private var total: Int = 0
    
    
    func setDelegate(_ delegate: SearchPresenterDelegate) {
        self.delegate = delegate
    }
    
    func fetchPhotos(for searchText: String) {
        let request = FlickrAPI.SearchPhotosEndpoint(searchText: searchText, page: page + 1, resultsPerPage: resultsPerPage).makeRequest()
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.delegate?.didFetchPhotos(error)
            } else if let data = data {
                do {
                    let response = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                    self.photos.append(contentsOf: response.photos)
                    self.page = response.page
                    self.total = response.total
                    
                    self.delegate?.didFetchPhotos(nil)
                } catch {
                    self.delegate?.didFetchPhotos(error)
                }
            }
        }
        .resume()
    }
    
    func clearSearch() {
        photos.removeAll()
        page = 0
        total = 0
        delegate?.didFetchPhotos(nil)
    }
}
