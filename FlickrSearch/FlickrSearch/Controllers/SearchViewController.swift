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
        collectionView.isHidden = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        return collectionView
    }()
    lazy private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchTermCell")
        return tableView
    }()
    
    private enum ViewState {
        case emptyResults
        case error(message: String)
        case populated
        case searchFocused
    }
    
    private var presenter: SearchPresenter!
    private var dataSource: UICollectionViewDiffableDataSource<Int, Photo>!
    private var state: ViewState = .emptyResults {
        didSet {
            DispatchQueue.main.async {
                self.updateView()
            }
        }
    }
    
    
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
        setupTableView()
        
        // Configs
        configureCollectionViewDataSource()
        
        state = .emptyResults
    }
    
    private func updateView() {
        switch state {
        case .emptyResults:
            tableView.isHidden = true
            collectionView.isHidden = false
            collectionView.backgroundView = EmptyView(message: "Nothing to Show 🍃")
        case .error(let message):
            tableView.isHidden = true
            collectionView.isHidden = false
            collectionView.backgroundView = EmptyView(message: message)
        case .populated:
            tableView.isHidden = true
            collectionView.isHidden = false
            collectionView.backgroundView = nil
            updateCollectionView()
        case .searchFocused:
            tableView.isHidden = false
            collectionView.isHidden = true
            tableView.reloadData()
        }
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
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - API
    private func fetchPhotos() {
        guard let searchText = searchController.searchBar.text else { return }
        presenter.fetchPhotos(for: searchText) { error in
            if let error = error {
                self.state = .error(message: error.localizedDescription)
            } else {
                self.state = .populated
            }
        }
    }
    
    // MARK: - Data Source
    private func configureCollectionViewDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, Photo>(collectionView: collectionView) { collectionView, indexPath, photo in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
            cell.set(photo)
            return cell
        }
    }
    
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Photo>()
        snapshot.appendSections([0])
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

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.searches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTermCell", for: indexPath)
        cell.textLabel?.text = presenter.searches[indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let search = presenter.searches[indexPath.row]
        searchController.searchBar.text = search
        fetchPhotos()
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchPhotos()
        guard let searchText = searchController.searchBar.text else { return }
        presenter.saveSearch(searchText)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Clear results when the 'Clear' button inside searchbar is tapped
        guard searchText.isEmpty else { return }
        presenter.clearSearch()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        state = .searchFocused
        return true
    }
}

// MARK: - UISearchControllerDelegate
extension SearchViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        // Clear results when 'Cancel' button is tapped
        guard let searchText = searchController.searchBar.text else { return }
        guard searchText.isEmpty else { return }
        presenter.clearSearch()
        updateCollectionView()
        state = .emptyResults
    }
}

// MARK: - SearchPresenterDelegate
extension SearchViewController: SearchPresenterDelegate {
    func didFetchPhotos(_ error: Error?) {
        if let error = error {
            state = .error(message: error.localizedDescription)
        } else {
            state = .populated
        }
    }
    
    func didClearSearch() {
        state = .searchFocused
    }
}
