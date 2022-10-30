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
// Fixme: add German titles and descriptions
// Fixme: if the user interacts with the player while the automatic next episode label appears, stop the process
// Fixme: add animation to automatic next episode label
// Fixme: stop automatic next episode when the player is dismissed


import UIKit
import AVKit
import Kingfisher

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
    fileprivate var userHasInteractedWithTimeLine = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerController.delegate = self
        setupTableView()
        currentEpisodeID = episode!.id
        descriptionLabel.text = episode!.description
        titleLabel.text = episode!.name
        guard let episode = episode else {
            return
        }
        episodeThumbnail.kf.setImage(with: URL(string: episode.thumbnail_url))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userHasInteractedWithTimeLine = false
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
                // Fixme: if there is no internet connection, this will fail with an index out of bounds
            }
        }
    }
    
    func showNextVideo() {
        if nextEpisodeLabelVisible || userHasInteractedWithTimeLine {
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
        
        var secondsRemaining = 7
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (Timer) in
            guard let strongSelf = self else {
                return
            }
            if secondsRemaining > 0 {
                if strongSelf.userHasInteractedWithTimeLine == true {
                    Timer.invalidate()
                    label.removeFromSuperview()
                    return
                }
                label.text = "Next episode in \(secondsRemaining)"
                secondsRemaining -= 1
            } else {
                if strongSelf.playerController.viewIfLoaded?.window == nil {
                    return
                }
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
        
        let titleItem = makeMetadataItem(.commonIdentifierTitle, value: "\(episode?.name ?? "Error loading episode title.")")
        metadata.append(titleItem)
        
        if let image = UIImage(named: "debugging"), let pngData = image.pngData() {
            let artworkItem = makeMetadataItem(.commonIdentifierArtwork, value: pngData)
            metadata.append(artworkItem)
        }
        
        let descItem = makeMetadataItem(.commonIdentifierDescription, value: """
            \(episode?.description ?? "Description could not be loaded.")
            """
        )
        metadata.append(descItem)
        
        let genreItem = makeMetadataItem(.quickTimeMetadataGenre, value: "Entertainment")
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
        NotificationCenter.default.post(name: NSNotification.Name(K.UPDATE_PROGRESSBARS), object: Float(currentTime / totalTime))
        UserDefaults.standard.set(Float(currentTime / totalTime), forKey: String(episode!.id))
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
        if nextEpisodeLabelVisible {
            userHasInteractedWithTimeLine = true
        }
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
