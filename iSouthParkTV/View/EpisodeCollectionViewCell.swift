//
//  EpisodeCollectionViewCell.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var titleLabel: UILabel!
    var cellType: CellType = .episodes
    
    var episode: ExcelEpisode? {
        didSet {
            guard let episode = episode else {
                return
            }
            titleLabel.text = episode.name
            let lazyImage = LazyLoadingImage()
            lazyImage.loadImageUsingURLString(urlString: episode.thumbnail_url) { [weak self] image, urlstring in
                guard let strongSelf = self else {
                    return
                }
                if urlstring == episode.thumbnail_url {
                    DispatchQueue.main.async {
                        strongSelf.thumbnailImageView.image = image
                    }
                }
            }
            thumbnailImageView.image = lazyImage.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.layer.cornerRadius = 20
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.borderWidth = 10
        thumbnailImageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({ [weak self] in
            if self?.isFocused ?? false{
                self?.thumbnailImageView.layer.borderColor = UIColor.white.cgColor
            } else {
                self?.thumbnailImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.thumbnailImageView.layer.borderColor = UIColor.clear.cgColor
            }
        }, completion: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        episode = nil
    }
}
