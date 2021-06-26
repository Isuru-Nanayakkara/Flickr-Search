//
//  SearchResultsUpdater.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import UIKit

protocol SearchResultsUpdaterDelegate: AnyObject {
    func didFinishTyping(text: String)
}

class SearchResultsUpdater: NSObject, UISearchResultsUpdating {
    weak var delegate: SearchResultsUpdaterDelegate?
    private var pendingWorkItem: DispatchWorkItem?
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        guard !searchText.isEmpty else { return }
        
        // Throttling search calls.
        pendingWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.delegate?.didFinishTyping(text: searchText)
        }
        pendingWorkItem = workItem
        // Wait half a second after user stops typing to execute the search request
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
}
