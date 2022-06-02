//
//  TopStoriesCollectionViewCell.swift
//  CyberStock
//
//  Created by William Hinson on 3/9/22.
//

import UIKit
import Kingfisher

class TopStoriesCollectionViewCell: UICollectionViewCell {
    
//    var song: SongPost? {
//        didSet {
//            titleLabel.text = song?.title
//            artistName.text = song?.author.fullname
//            let url = URL(string: (song?.coverImage.absoluteString)!)
//            coverImage.kf.setImage(with: url)
////            coverImage.loadImage(with: (song?.coverImage.absoluteString)!)
//        }
//    }
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageUrl: URL?

        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageUrl = URL(string: model.image)
        }
    }

    
    /// Source label
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()

    /// Headline label
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    /// Date label
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    /// Image for story
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .tertiarySystemBackground
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "news")
        return imageView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
//        coverImage.translatesAutoresizingMaskIntoConstraints = false
//        coverImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        coverImage.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
//        coverImage.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        coverImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//
//        addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.topAnchor.constraint(equalTo: coverImage.bottomAnchor,constant: 4).isActive = true
//        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
//        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
//
//        addSubview(artistName)
//        artistName.translatesAutoresizingMaskIntoConstraints = false
//        artistName.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 0).isActive = true
//        artistName.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
//        artistName.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
      }
    
      required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
}
