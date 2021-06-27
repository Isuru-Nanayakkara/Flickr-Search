//
//  SearchHistoryStore.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-27.
//

import Foundation

struct SearchHistoryStore {
    private let Key = "Searches"
    
    func saveSearch(_ text: String) {
        var existingSearches = getSearches()
        existingSearches.insert(text, at: 0)
        
        UserDefaults.standard.setValue(existingSearches, forKey: Key)
    }
    
    func getSearches() -> [String] {
        let searches = UserDefaults.standard.stringArray(forKey: Key)
        return searches ?? []
    }
}
