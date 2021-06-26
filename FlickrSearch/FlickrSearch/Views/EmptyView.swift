//
//  EmptyView.swift
//  FlickrSearch
//
//  Created by Isuru Nanayakkara on 2021-06-26.
//

import UIKit

class EmptyView: UIView {
    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private(set) var message: String?
    
    convenience init(message: String) {
        self.init(frame: CGRect.zero)
        
        self.message = message
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupMessageLabel()
    }
    
    private func commonInit() {
        guard let message = message else {
            fatalError("No value set for 'message' property")
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.secondaryLabel,
            NSAttributedString.Key.textEffect: NSAttributedString.TextEffectStyle.letterpressStyle,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline),
        ]
        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)
    }
    
    // MARK: - UI Setup
    private func setupMessageLabel() {
        addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
