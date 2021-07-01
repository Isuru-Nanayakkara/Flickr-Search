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
    
    func fetchPhotos(for searchText: String, onCompletion: @escaping (_ error: Error?) -> ())
}

class SearchPresenter: SearchPresenterProvider {
    private let resultsPerPage = 10
    
    weak private(set) var delegate: SearchPresenterDelegate?
    var pastSearches: [String] {
        return searchHistoryStore.getSearches()
    }
    
    private(set) var photos: [Photo] = []
    
    private var page: Int = 0
    private var total: Int = 0
    
    private var api: FlickrAPIProvider
    private var searchHistoryStore: SearchHistoryStore
    
    
    init(api: FlickrAPIProvider, searchHistoryStore: SearchHistoryStore) {
        self.api = api
        self.searchHistoryStore = searchHistoryStore
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
        searchHistoryStore.saveSearch(text)
    }
}
