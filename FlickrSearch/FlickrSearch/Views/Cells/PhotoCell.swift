//
//  PhotoCell.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    lazy private var imageView: AsyncImageView = {
        let imageView = AsyncImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        contentView.backgroundColor = .systemGreen
        
        setupImageView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    // MARK: - UI Setup
    private func setupImageView() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

extension PhotoCell {
    func set(_ photo: Photo) {
        let photoURL = FlickrPhotoURLBuilder(farm: photo.farm, server: photo.server, id: photo.id, secret: photo.secret)
            .size(.thumbnail)
            .build()
        
        imageView.loadImage(from: photoURL, placeholder: UIImage(named: "placeholder"))
    }
}
