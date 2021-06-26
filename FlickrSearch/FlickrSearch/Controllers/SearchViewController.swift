//
//  SearchViewController.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import UIKit

class SearchViewController: UIViewController {
    lazy private var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Photos (ex: cats, cars)"
        return searchController
    }()
    lazy private var collectionView: UICollectionView = {
        let spacing: CGFloat = 2
        let twoColumnLayout = ColumnFlowLayout(cellsPerRow: 2, minimumInteritemSpacing: spacing, minimumLineSpacing: spacing, sectionInset: UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing))
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: twoColumnLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        return collectionView
    }()
    
    private var presenter: SearchPresenter!
    private let searchResultsUpdater = SearchResultsUpdater()
    
    
    init(presenter: SearchPresenter) {
        super.init(nibName: nil, bundle: nil)
        
        self.presenter = presenter
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.setDelegate(self)
        searchResultsUpdater.delegate = self
        searchController.searchResultsUpdater = searchResultsUpdater
        
        // UI Setup
        setupView()
        setupNavigationBar()
        setupCollectionView()
    }
    
    // MARK: - UI Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Flickr Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - API
    private func fetchPhotos(forSearchText text: String) {
        presenter.fetchPhotos(for: text)
    }
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
        
        let photo = presenter.photos[indexPath.item]
        cell.set(photo)
        
        return cell
    }
}

// MARK: - SearchResultsUpdaterDelegate
extension SearchViewController: SearchResultsUpdaterDelegate {
    func didFinishTyping(text: String) {
        fetchPhotos(forSearchText: text)
    }
}

// MARK: - SearchPresenterDelegate
extension SearchViewController: SearchPresenterDelegate {
    func didFetchPhotos(_ error: Error?) {
        if let error = error {
            print("💥 Error occurred: \(error.localizedDescription)")
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}
