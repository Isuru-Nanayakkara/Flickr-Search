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
    func loadImage(from url: URL, placeholder: UIImage? = nil, showActivityIndicator: Bool = true) {
        image = placeholder
        
        activityIndicatorView.isHidden = !showActivityIndicator
        activityIndicatorView.startAnimating()
        
        let request = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
    
    func loadImage(from urlString: String, placeholder: UIImage? = nil, showActivityIndicator: Bool = true) {
        guard let url = URL(string: urlString) else { return }
        loadImage(from: url, placeholder: placeholder, showActivityIndicator: showActivityIndicator)
    }
}
