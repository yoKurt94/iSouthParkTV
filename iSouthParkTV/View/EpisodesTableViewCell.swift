//
//  EpisodesTableViewCell.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 30.06.22.
//

import UIKit
import Combine

protocol EpisodesTableViewCellDelegate: AnyObject {
    func didSelectItem(episode: ExcelEpisode, allEpisodes: [ExcelEpisode])
}

class EpisodesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var videoCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var seasonNo = Int()
    var cachedImages = [String: UIImage]()
    var allEpisodes: [ExcelEpisode]?
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
        let episode = episodesForThisSeason![indexPath.item]
        cell.thumbnailImageView.image = UIImage(named: "appleSignIn")
        cell.thumbnailImageView.contentMode = .scaleAspectFill
        cell.episode = episode
        let prg = UserDefaults.standard.float(forKey: String(episode.id))
        if prg == 0 || prg > Float(0.85) {
            cell.progressBar.isHidden = true
        }
        else {
            cell.progressBar.isHidden = false
            cell.progressBar.progress = prg
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let allEpisodes = allEpisodes else {
            return
        }
        delegate?.didSelectItem(episode: episodesForThisSeason![indexPath.item], allEpisodes: allEpisodes)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        allEpisodes?.removeAll()
        videoCollectionView.reloadData()
        episodesForThisSeason?.removeAll()
        delegate = nil
    }
}
