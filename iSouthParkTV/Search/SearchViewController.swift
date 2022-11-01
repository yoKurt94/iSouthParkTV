//
//  SearchViewController.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 30.06.22.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var allEpisodes = [ExcelEpisode]()
    var filteredEpisodes = [ExcelEpisode]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: K.SEARCH_RESULT_TABLEVIEW_CELL, bundle: nil), forCellReuseIdentifier: K.SEARCH_RESULT_TABLEVIEW_CELL)
        tableView.estimatedRowHeight = 300
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        filteredEpisodes = allEpisodes
    }
    
    func performSearch(searchText: String) {
        filteredEpisodes = allEpisodes.filter({
            return $0.name.range(of: searchText, options: .caseInsensitive) != nil || $0.description.range(of: searchText, options: .caseInsensitive) != nil
        })
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.SEARCH_RESULT_TABLEVIEW_CELL, for: indexPath) as! SearchResultTableViewCell
        cell.episode = filteredEpisodes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEpisodes.count
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        performSearch(searchText: textField.text!)
        return true
    }
}
