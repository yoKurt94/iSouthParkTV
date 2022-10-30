//
//  HomeViewController.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 30.06.22.
//

import UIKit
import CoreXLSX

enum CellType: Int, CaseIterable {
    case episodes
    case banner
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeTableView: UITableView!
    private var episodeArray: [ExcelEpisode] = []
    private var excelHeaders: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.register(UINib(nibName: K.EPISODES_TABLE_VIEW_CELL, bundle: nil), forCellReuseIdentifier: K.EPISODES_TABLE_VIEW_CELL)
        homeTableView.estimatedRowHeight = 300
        homeTableView.rowHeight = UITableView.automaticDimension
        homeTableView.reloadData()
        homeTableView.dataSource = self
        homeTableView.delegate = self
        getDataFromExcelFile()
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgressBar), name: NSNotification.Name(K.UPDATE_PROGRESSBARS), object: nil)
    }
    
    func filterAllEpisodesForNextDownloads(nextSeason: Int) -> [ExcelEpisode] {
        episodeArray.filter { episode in
            return episode.season == nextSeason
        }
    }
    
    @objc func updateProgressBar(){
        homeTableView.reloadData()
    }
    
    func getDataFromExcelFile(){
        let fileName = "southparkEpisodes"
        guard let excelFilePath = Bundle.main.path(forResource: fileName, ofType: "xlsx", inDirectory: nil) else {
            return
        }
        
        guard let file = XLSXFile(filepath: excelFilePath) else {
            print("EXCEL FILE NOT FOUND!")
            return
        }
        
        for wbk in try! file.parseWorkbooks() {
            for (name, path) in try! file.parseWorksheetPathsAndNames(workbook: wbk) {
                if let workSheetName = name {
                    print("Document titled \(workSheetName)")
                }
                let worksheet = try! file.parseWorksheet(at: path)
                let sharedString = try! file.parseSharedStrings()
                var episode: ExcelEpisode? = nil
                var id = 0
                var name = "name"
                var seasonNr = 0
                var episodeNr = 0
                var air_date = ""
                var wiki_url = "wiki_url"
                var thumbnail_url = "thumbnail_url"
                var description = "description"
                var created_at = "created_at"
                var updated_at = "updated_at"
                let characters: [String] = []
                let locations: [String] = []
                for row in worksheet.data?.rows ?? [] {
                    if row.reference == 1 {
                        for cellValue in row.cells {
                            guard let stringValue = cellValue.stringValue(sharedString!) else {
                                return
                            }
                            excelHeaders.append(stringValue)
                        }
                    } else {
                        for (index, cellValue) in row.cells.enumerated() {
                            guard let stringValueOfCell = cellValue.stringValue(sharedString!) else {
                                return
                            }
                            switch excelHeaders[index] {
                            case "id":
                                guard let intValue = Int(stringValueOfCell) else {
                                    return
                                }
                                id = intValue
                            case "name":
                                name = stringValueOfCell
                            case "season":
                                guard let intValue = Int(stringValueOfCell) else {
                                    return
                                }
                                seasonNr = intValue
                            case "episode":
                                guard let intValue = Int(stringValueOfCell) else {
                                    return
                                }
                                episodeNr = intValue
                            case "air_date":
                                air_date = stringValueOfCell
                            case "wiki_url":
                                wiki_url = stringValueOfCell
                            case "thumbnail_url":
                                thumbnail_url = stringValueOfCell
                            case "description":
                                description = stringValueOfCell
                            case "created_at":
                                created_at = stringValueOfCell
                            case "updated_at":
                                updated_at = stringValueOfCell
                            default:
                                break
                                
                            }
                            
                        }
                        episode = ExcelEpisode(id: id, name: name, season: seasonNr, episode: episodeNr, air_date: air_date, wiki_url: wiki_url, thumbnail_url: thumbnail_url, description: description, created_at: created_at, updated_at: updated_at, characters: characters, locations: locations, thumbnailImage: nil)
                        episodeArray.append(episode!)
                    }
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeArray.max { $0.season < $1.season }?.season ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EpisodesTableViewCell = tableView.dequeueReusableCell(withIdentifier: K.EPISODES_TABLE_VIEW_CELL, for: indexPath) as! EpisodesTableViewCell
        cell.delegate = self
        cell.titleLabel.text = "Season \(indexPath.row + 1)"
        cell.allEpisodes = episodeArray
        let seasonEpisodes = episodeArray.filter({ episode in
            episode.season == indexPath.row + 1
        })
        cell.episodesForThisSeason = seasonEpisodes
        cell.seasonNo = indexPath.row + 1
        return cell
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension HomeViewController: EpisodesTableViewCellDelegate {
    func didSelectItem(episode: ExcelEpisode, allEpisodes: [ExcelEpisode]) {
        if let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: K.DETAILVCID) as? DetailViewController {
            detailVC.episode = episode
            detailVC.allEpisodes = allEpisodes
            self.present(detailVC, animated: true, completion: nil)
        }
    }
}
