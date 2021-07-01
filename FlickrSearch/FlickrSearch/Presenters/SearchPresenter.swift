//
//  SearchPresenter.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import Foundation

protocol SearchPresenterDelegate: AnyObject {
    func didFetchPhotos(_ error: Error?)
    func didClearSearch()
}

protocol SearchPresenterProvider {
    var photos: [Photo] { get }
    var searches: [String] { get }
    
    func fetchPhotos(for searchText: String, onCompletion: @escaping (_ error: Error?) -> ())
}

class SearchPresenter: SearchPresenterProvider {
    // Public
    weak private(set) var delegate: SearchPresenterDelegate?
    
    var searches: [String] {
        return store.getSearches()
    }
    private(set) var photos: [Photo] = []
    
    // Private
    private let resultsPerPage = 10
    private var page: Int = 0
    private var total: Int = 0
    
    private var api: FlickrAPIProvider
    private var store: SearchHistoryStoreProvider
    
    
    init(api: FlickrAPIProvider, store: SearchHistoryStoreProvider) {
        self.api = api
        self.store = store
    }
    
    func setDelegate(_ delegate: SearchPresenterDelegate) {
        self.delegate = delegate
    }
    
    func fetchPhotos(for searchText: String, onCompletion: @escaping (_ error: Error?) -> ()) {
        api.fetchPhotos(for: searchText, page: page + 1, resultsPerPage: resultsPerPage) { result in
            switch result {
            case .success(let response):
                self.photos.append(contentsOf: response.photos)
                self.page = response.page
                self.total = response.total
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
        delegate?.didClearSearch()
    }
    
    func saveSearch(_ text: String) {
        store.saveSearch(text)
    }
}
