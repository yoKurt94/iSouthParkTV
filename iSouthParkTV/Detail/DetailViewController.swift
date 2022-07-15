//
//  DetailsViewController.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 30.06.22.
//


// Fixme: if you skip the first video by clicking next at the end, the video loops - you have to wait for it to automatically end (this bug happens unregularely?)
// Fixme: you cannot go back into the previous video
// Fixme: add en as video language
// Fixme: title in DetailVC has broken trailing
// Fixme: reduce redundant code (i.e. the episode network call)
// Fixme: add German titles and descriptions
// Fixme: notify HomeVC to update the progress bar when player was manually stopped
// Fixme: if the user interacts with the player while the automatic next episode label appears, stop the process
// Fixme: add animation to automatic next episode label


import UIKit
import AVKit

class DetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeThumbnail: UIImageView!
    @IBOutlet weak var similarTableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    var episode: ExcelEpisode? = nil
    var selectedLanguage = "GE"
    var allEpisodes: [ExcelEpisode]?
    
    fileprivate var videos: [String] = []
    fileprivate var urls: [URL] = []
    fileprivate var currentVideo: Int = 0
    fileprivate let playerController = AVPlayerViewController()
    fileprivate var player: AVPlayer?
    fileprivate var timeObeserverToken: Any?
    var avAssets: [AVAsset] = []
    var currentEpisodeID: Int?
    fileprivate var nextEpisodeLabelVisible = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerController.delegate = self
        setupTableView()
        currentEpisodeID = episode!.id
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
    
    func addPeriodicTimeObserver() {
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        if player != nil {
            timeObeserverToken = player!.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { [weak self] time in
                guard let strongSelf = self, let currentTimeOfAsset = strongSelf.playerController.player?.currentItem?.currentTime().seconds else {
                    return
                }
                
                let timeToEnd = strongSelf.avAssets[strongSelf.currentVideo].duration.seconds - currentTimeOfAsset
                if strongSelf.currentVideo == strongSelf.urls.count - 1 && timeToEnd < 25 {
                    strongSelf.showNextVideo()
                }
            })
        }
    }
    
    @IBAction func didClickOnPlayButton(_ sender: UIButton) {
        playButton.setTitle("", for: .normal)
        let spinner = UIActivityIndicatorView(frame: playButton.bounds)
        spinner.style = .medium
        spinner.startAnimating()
        spinner.color = UIColor.gray
        playButton.addSubview(spinner)
        
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
                    strongSelf.avAssets.append(AVAsset(url: url))
                    strongSelf.urls.append(url)
                }
            case .failure(let error):
                print(error)
            }
            DispatchQueue.main.async {
                spinner.removeFromSuperview()
                strongSelf.playButton.setTitle("Play", for: .normal)
                strongSelf.present(strongSelf.playerController, animated: true)
                strongSelf.startPlaying(url: strongSelf.urls[0])
            }
        }
    }
    
    func showNextVideo() {
        if nextEpisodeLabelVisible {
            return
        }
        guard var currentEpisodeID = currentEpisodeID else {
            return
        }
        nextEpisodeLabelVisible = true
        currentEpisodeID += 1
        let label = UILabel(frame: CGRect(x: self.view.frame.width - 450, y: self.view.frame.height - 360, width: 450, height: 100))
        label.text = ""
        label.textColor = UIColor.white
        label.tintColor = UIColor.white
        playerController.view.addSubview(label)
        
        var secondsRemaining = 10
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (Timer) in
            if secondsRemaining > 0 {
                label.text = "Next episode in \(secondsRemaining)"
                secondsRemaining -= 1
            } else {
                Timer.invalidate()
                label.text = "Loading next episode..."
                NotificationCenter.default.post(name: Notification.Name("startedFetching"), object: nil)
                Services().requestVideoLinks(episodeId: String(currentEpisodeID), lang: "ge") { [weak self] result in
                    guard let strongSelf = self, var currentEpisodeID = strongSelf.currentEpisodeID else {
                        return
                    }
                    
                    switch result {
                    case .success(let videoLinks):
                        strongSelf.avAssets.removeAll()
                        strongSelf.urls.removeAll()
                        for link in videoLinks {
                            guard let url = URL(string: link) else {
                                print("There is something wrong with the URL")
                                return
                            }
                            
                            strongSelf.avAssets.append(AVAsset(url: url))
                            strongSelf.urls.append(url)
                        }
                    case .failure(let error):
                        print(error)
                    }
                    DispatchQueue.main.async {
                        currentEpisodeID += 1
                        label.removeFromSuperview()
                        strongSelf.nextEpisodeLabelVisible = false
                        strongSelf.startPlaying(url: strongSelf.urls[0])
                        strongSelf.showNextVideo()
                    }
                }
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

        player = AVPlayer(url: url)
        playerController.player = player
        playerController.player?.currentItem?.externalMetadata = makeExternalMetadata()
        if player != nil {
            player!.play()
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
            addPeriodicTimeObserver()
        }
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

extension DetailViewController: AVPlayerViewControllerDelegate {
    func playerViewControllerWillBeginDismissalTransition(_ playerViewController: AVPlayerViewController) {
        
        var totalTime: Double = 0.0
        var currentTime: Double = 0.0
        for asset in avAssets {
            totalTime += asset.duration.seconds
        }
        guard let currentAsset = playerViewController.player?.currentItem?.asset else {
            return
        }
        for asset in avAssets {
            if asset.duration != currentAsset.duration {
                currentTime += asset.duration.seconds
            } else {
                currentTime += playerViewController.player?.currentTime().seconds ?? 0.0
                break
            }
        }
        
        UserDefaults.standard.set(Float(currentTime / totalTime), forKey: String(episode!.id))
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
