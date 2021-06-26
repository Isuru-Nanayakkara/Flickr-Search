//
//  AsyncImageView.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import UIKit

class AsyncImageView: UIImageView {
    lazy private(set) var activityIndicatorView: UIActivityIndicatorView = {
        var activityIndicatorView: UIActivityIndicatorView
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .systemGray
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupActivityIndicatorView()
    }
    
    private func setupActivityIndicatorView() {
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - Public API
extension AsyncImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil, cache: URLCache? = nil, showActivityIndicator: Bool = true) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            // If image data exists in cache, load image from there
            self.image = image
        } else {
            self.image = placeholder
            
            activityIndicatorView.isHidden = !showActivityIndicator
            activityIndicatorView.startAnimating()
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                }
                
                if let imageData = data, let image = UIImage(data: imageData), let response = response {
                    // Save image data to cache
                    let cacheResponse = CachedURLResponse(response: response, data: imageData)
                    cache.storeCachedResponse(cacheResponse, for: request)
                    
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }.resume()
        }
    }
    
    func loadImage(from urlString: String, placeholder: UIImage? = nil, cache: URLCache? = nil, showActivityIndicator: Bool = true) {
        guard let url = URL(string: urlString) else { return }
        loadImage(from: url, placeholder: placeholder, cache: cache, showActivityIndicator: showActivityIndicator)
    }
}
