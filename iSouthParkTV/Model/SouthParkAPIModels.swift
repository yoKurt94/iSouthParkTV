//
//  SouthParkAPIModels.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import Foundation
import CoreMIDI
import UIKit

// MARK:  SouthParkAPI objects

struct Characters: Codable {
    let id: Int
    let name: String
    let age: Int
    let sex: String
    let hair_color: String
    let occupation: String
    let grade: Int
    let religion: String
    let voiced_by: String
    let created_at: String
    let updated_at: String
    let url: String
    let family: String
    let relatives: Relatives
    let episodes: [String]
}

struct Relatives: Codable {
    let url: String
    let relation: String
}

struct APIEpisodes: Codable {
    let id: Int
    let name: String
    let season: Int
    let episode: Int
    let air_date: String
    let wiki_url: String
    let thumbnail_url: String
    let description: String
    let created_at: String
    let updated_at: String
    let characters: [String]
    let locations: [String]
}

struct EpisodesData: Codable {
    let data: APIEpisodes
}

struct CharactersData: Codable {
    let data: Characters
}

// MARK:  Models for the EXCEL file

struct Episodes {
    let id: Int
    let name: String
    let season: Int
    let episode: Int
    let air_date: String
    let wiki_url: String
    let thumbnail_url: String
    let description: String
    let created_at: String
    let updated_at: String
    let characters: [String]
    let locations: [String]
}

// MARK:  Models for the EpisodeAPI

struct SouthParkArrayOfNums: Codable {
    let zero: [SouthParkEpisodesWithNestedEnum]
    let one: [SouthParkEpisodesWithNestedEnum]
    let two: [SouthParkEpisodesWithNestedEnum]
    let three: [SouthParkEpisodesWithNestedEnum]
    private enum CodingKeys: Int, CodingKey {
        case zero = 0, one = 1, two = 2, three = 3
    }
}

struct SouthParkEpisodesWithNestedEnum: Codable {
    let num: Int
    let obj: [EpisodeAPIObject]
    private enum CodingKeys: Int, CodingKey {
        case num = 0, obj = 1
    }
}

struct EpisodeAPIObject: Codable {
    let title: String
    let formats: [EpisodeAPIFormat]
    let subtitles: EpisodeAPISubtitles
}

struct EpisodeAPIFormat: Codable {
    let format_id: String
    let url: String
    let manifest_url: String
    let tbr: Float
    let ext: String
    let fps: Float
    let width: Float
    let height: Float
    let vcodec: String
    let acodec: String
}

struct EpisodeAPISubtitles: Codable {
    
}




