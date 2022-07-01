//
//  DetailsViewController.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 30.06.22.
//

import UIKit
import AVKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeThumbnail: UIImageView!
    @IBOutlet weak var similarTableView: UITableView!
    var episode: ExcelEpisode? = nil
    var selectedLanguage = "GE"
    fileprivate var videos: [String] = []
    fileprivate var urls: [URL] = []
    fileprivate var currentVideo: Int = 0
    fileprivate let playerController = AVPlayerViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        descriptionLabel.text = episode!.description
        titleLabel.text = episode!.name
        let lazyImage = LazyLoadingImage()
        lazyImage.loadImageUsingURLString(urlString: episode!.thumbnail_url) { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.episodeThumbnail.image = image
            }
        }
        episodeThumbnail.image = lazyImage.image
        
    }
    
    @IBAction func didClickOnPlayButton(_ sender: UIButton) {
        
        var avAssets: [AVAsset] = []
        NotificationCenter.default.post(name: Notification.Name("startedFetching"), object: nil)
        Services().requestVideoLinks(episodeId: String(episode!.id), lang: "ge") { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let videoLinks):
                for link in videoLinks {
                    guard let url = URL(string: link) else {
                        print("There is something wrong with the URL")
                        return
                    }
                    avAssets.append(AVAsset(url: url))
                    strongSelf.urls.append(url)
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                strongSelf.present(strongSelf.playerController, animated: true)
                strongSelf.startPlaying(url: strongSelf.urls[0])
            }
        }
    }
    
    func setupTableView() {
        similarTableView.register(UINib(nibName: "VideosTableViewCell", bundle: nil), forCellReuseIdentifier: "VideosTableViewCell")
        similarTableView.estimatedRowHeight = 300
        similarTableView.rowHeight = UITableView.automaticDimension
        similarTableView.reloadData()
    }
    
    func startPlaying(url: URL) {
        let player = AVPlayer(url: url)
        playerController.player = player
        playerController.player?.currentItem?.externalMetadata = makeExternalMetadata()
        player.play()
        NotificationCenter.default
            .addObserver(self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if currentVideo < urls.count - 1 {
            currentVideo += 1
            startPlaying(url: urls[currentVideo])
        }
    }
    
    func makeExternalMetadata() -> [AVMetadataItem] {
        var metadata = [AVMetadataItem]()
        
        // Build title item
        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: "\(episode?.name ?? "Error loading episode title.")")
        metadata.append(titleItem)
        
        // Build artwork item
        if let image = UIImage(named: "debugging"), let pngData = image.pngData() {
            let artworkItem = makeMetadataItem(.commonIdentifierArtwork, value: pngData)
            metadata.append(artworkItem)
        }
        
        // Build description item
        let descItem = makeMetadataItem(.commonIdentifierDescription, value: """
            \(episode?.description ?? "Description could not be loaded.")
            """
        )
        metadata.append(descItem)
        
        // Build genre item
        let genreItem = makeMetadataItem(.quickTimeMetadataGenre, value: "Education")
        metadata.append(genreItem)
        return metadata
    }


    
    private func makeMetadataItem(_ identifier: AVMetadataIdentifier, value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: EpisodesTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.EPISODES_TABLE_VIEW_CELL, for: indexPath) as? EpisodesTableViewCell {
            cell.titleLabel.text = "Next episodes"
            cell.videoCollectionViewHeightConstraint.constant = 200
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
