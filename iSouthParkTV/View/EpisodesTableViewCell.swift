//
//  EpisodesTableViewCell.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 30.06.22.
//

import UIKit

protocol EpisodesTableViewCellDelegate: AnyObject {
    func didSelectItem(episode: ExcelEpisode)
}

class EpisodesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var videoCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var episodesForThisSeason: [ExcelEpisode]?
    weak var delegate: EpisodesTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoCollectionView.delegate = self
        videoCollectionView.dataSource = self
        registerCollectionViewCells()
        
    }
    
    func registerCollectionViewCells() {
        videoCollectionView.register(UINib(nibName: K.EPISODE_COLLECTION_VIEW_CELL, bundle: nil), forCellWithReuseIdentifier: K.EPISODE_COLLECTION_VIEW_CELL)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension EpisodesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodesForThisSeason?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.EPISODE_COLLECTION_VIEW_CELL, for: indexPath) as! EpisodeCollectionViewCell
        cell.thumbnailImageView.image = UIImage(named: "appleSignIn")
        cell.thumbnailImageView.contentMode = .scaleAspectFill
        cell.episode = episodesForThisSeason![indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(episode: episodesForThisSeason![indexPath.item])
    }
    
    
}
