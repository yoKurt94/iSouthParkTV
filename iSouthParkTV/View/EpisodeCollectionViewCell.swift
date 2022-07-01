//
//  EpisodeCollectionViewCell.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import UIKit

class EpisodeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var cellType: CellType = .episodes
    
    var episode: Episodes? {
        didSet {
            if episode != nil {
                let lazyImage = LazyLoadingImage()
                lazyImage.loadImageUsingURLString(urlString: episode!.thumbnail_url) { [weak self] image in
                    guard let strongSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.thumbnailImageView.image = image
                    }
                }
                thumbnailImageView.image = lazyImage.image
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.layer.cornerRadius = 20
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.borderWidth = 10
        thumbnailImageView.layer.borderColor = UIColor.clear.cgColor
    }
}
