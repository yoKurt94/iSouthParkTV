//
//  SearchResultTableViewCell.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 31.10.22.
//

import UIKit
import Kingfisher

class SearchResultTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var episode: ExcelEpisode? {
        didSet {
            guard let episode = episode else {
                return
            }
            let processor = DownsamplingImageProcessor(size: thumbnailImageView.bounds.size)
                         |> RoundCornerImageProcessor(cornerRadius: 20)
            thumbnailImageView.kf.indicatorType = .activity
            thumbnailImageView.kf.setImage(with: URL(string: episode.thumbnail_url), options: [.transition(.flipFromBottom(1)), .processor(processor)])
            titleLabel.text = "\(episode.name) • S\(episode.season)E\(episode.episode)"
            descriptionLabel.text = episode.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
