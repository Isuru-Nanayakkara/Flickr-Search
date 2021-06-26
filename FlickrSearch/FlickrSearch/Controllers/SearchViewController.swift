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
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search Photos (ex: cats, cars)"
        return searchController
    }()
    lazy private var collectionView: UICollectionView = {
        let spacing: CGFloat = 2
        let twoColumnLayout = ColumnFlowLayout(cellsPerRow: 2, minimumInteritemSpacing: spacing, minimumLineSpacing: spacing, sectionInset: UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing))
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: twoColumnLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        return collectionView
    }()
    
    private enum Section {
        case main
    }
    private var presenter: SearchPresenter!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Photo>!
    
    
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
        
        // UI Setup
        setupView()
        setupNavigationBar()
        setupCollectionView()
        
        // Configs
        configureCollectionViewDataSource()
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
    private func fetchPhotos() {
        guard let searchText = searchController.searchBar.text else { return }
        presenter.fetchPhotos(for: searchText)
    }
    
    // MARK: - Data Source
    private func configureCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: collectionView, cellProvider: { collectionView, indexPath, photo -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
            cell.set(photo)
            return cell
        })
    }
    
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(presenter.photos)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension SearchViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 && presenter.photos.count > 0 {
            for indexpath in collectionView.indexPathsForVisibleItems {
                if indexpath == IndexPath(row: presenter.photos.count - 1, section: 0) {
                    fetchPhotos()
                }
            }
        }
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchPhotos()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Clear results when the 'Clear' button inside searchbar is tapped
        guard searchText.isEmpty else { return }
        presenter.clearSearch()
    }
}

// MARK: - UISearchControllerDelegate
extension SearchViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        // Clear results when 'Cancel' button is tapped
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText.isEmpty else { return }
        presenter.clearSearch()
    }
}

// MARK: - SearchPresenterDelegate
extension SearchViewController: SearchPresenterDelegate {
    func didFetchPhotos(_ error: Error?) {
        if let error = error {
            print("💥 Error occurred: \(error.localizedDescription)")
        } else {
            updateCollectionView()
        }
    }
}
