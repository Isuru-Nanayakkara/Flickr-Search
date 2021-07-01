//
//  FlickrSearchPresenterTests.swift
//  FlickrSearchTests
//
//  Created by Isuru Nanayakkara on 2021-07-01.
//

import XCTest
@testable import Flickr_Search

class FlickrSearchPresenterTests: XCTestCase {
    private var sut: SearchPresenter!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let api = MockFlickrAPI()
        let store = MockSearchHistoryStore()
        sut = SearchPresenter(api: api, store: store)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testFirstResultsPageFetching() {
        sut.fetchPhotos(for: "cat") { _ in }
        XCTAssertEqual(sut.photos.count, 3)
    }
}
