//
//  EpisodeModels.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import Foundation

struct Season {
    var seasonNr: Int
    var episodes: [Episode]
}

struct Episode: Decodable {
    var geTitle: String
    var enTitle: String
    var enDescription: String
    var geDescription: String
    var thumbnailURL: String
    var enVideos: [String]
    var geVideos: [String]
    var alreadyWatched: Bool
}
