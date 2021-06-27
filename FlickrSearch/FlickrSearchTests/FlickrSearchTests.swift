//
//  FlickrSearchTests.swift
//  FlickrSearchTests
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import XCTest
@testable import FlickrSearch

class FlickrSearchTests: XCTestCase {
    private var sut: URLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        sut = URLSession(configuration: config)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFetchingPhotosFromFlickrForGivenSearchText() {
        let promise = expectation(description: "Flickr API returns photos")
        var photos: [Photo] = []
        
        let request = FlickrAPI.SearchPhotosEndpoint(searchText: "cat", page: 1, resultsPerPage: 10).makeRequest()
        sut.dataTask(with: request) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                promise.fulfill()
            } else if let data = data {
                let response = try! JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                photos.append(contentsOf: response.photos)
                promise.fulfill()
            } else {
                XCTFail("Status Code: \((response as! HTTPURLResponse).statusCode)")
                promise.fulfill()
            }
        }
        .resume()
        
        wait(for: [promise], timeout: 5)
        XCTAssertEqual(photos.count, 10)
    }
    
    func testFetchingPhotoFromSourceURL() {
        let url = FlickrPhotoURLBuilder(farm: 1, server: "578", id: "23451156376", secret: "8983a8ebc7")
            .size(.thumbnail)
            .build()
        
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?

        let dataTask = sut.dataTask(with: url) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)

        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
}
