//
//  SearchPresenter.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

protocol SearchPresenterProvider: AnyObject {
    var photos: [Photo] { get }
    var searches: [String] { get }
    
    func fetchPhotos(for searchText: String, onCompletion: @escaping (_ error: Error?) -> ())
}

class SearchPresenter: SearchPresenterProvider {
    // Public
    var searches: [String] {
        return store.getSearches()
    }
    private(set) var photos: [Photo] = []
    var onSearchCleared: (() -> Void)?
    
    // Private
    private let resultsPerPage = 20
    private var page: Int = 0
    private var total: Int = 0
    
    private var api: FlickrAPIProvider
    private var store: SearchHistoryStoreProvider
    
    
    init(api: FlickrAPIProvider, store: SearchHistoryStoreProvider) {
        self.api = api
        self.store = store
    }
    
    func fetchPhotos(for searchText: String, onCompletion: @escaping (_ error: Error?) -> ()) {
        api.fetchPhotos(for: searchText, page: page + 1, resultsPerPage: resultsPerPage) { result in
            switch result {
            case .success(let response):
                self.photos.append(contentsOf: response.photos)
                self.page = response.page
                self.total = response.total
                
                self.store.saveSearch(searchText)
                onCompletion(nil)
            case .failure(let error):
                onCompletion(error)
            }
        }
    }
    
    func clearSearch() {
        photos.removeAll()
        page = 0
        total = 0
        onSearchCleared?()
    }
}

private extension SearchPresenter {
    private func saveSearch(_ text: String) {
        store.saveSearch(text)
    }
}
