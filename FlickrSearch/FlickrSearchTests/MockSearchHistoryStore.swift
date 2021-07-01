//
//  MockSearchHistoryStore.swift
//  FlickrSearchTests
//
//  Created by Isuru Nanayakkara on 2021-07-01.
//

import Foundation
@testable import Flickr_Search

class MockSearchHistoryStore: SearchHistoryStoreProvider {
    func saveSearch(_ text: String) {
        
    }
    
    func getSearches() -> [String] {
        return []
    }
}
