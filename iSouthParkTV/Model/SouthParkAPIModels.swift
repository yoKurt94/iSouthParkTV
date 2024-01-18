//
//  SouthParkAPIModels.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import Foundation
import CoreMIDI
import UIKit

// MARK: SouthParkAPI models

struct SouthParkAPICharacter: Codable {
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
    let relatives: SouthParkAPIRelative
    let episodes: [String]
}

struct SouthParkAPIRelative: Codable {
    let url: String
    let relation: String
}

struct SouthParkAPIEpisode: Codable {
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

struct SouthParkAPIEpisodeData: Codable {
    let data: SouthParkAPIEpisode
}

struct SouthParkAPICharacterData: Codable {
    let data: SouthParkAPICharacter
}

// MARK:  Models for the EXCEL file

struct ExcelEpisode {
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
    var thumbnailImage: UIImage?
}

// MARK:  Models for the VideoLinkAPI

struct WelcomeElement: Codable {
    let title: String
    let formats: [Format]
    let subtitles: Subtitles
    let id: String
    let thumbnail: String
    let description: JSONNull?
    let duration: Int
    let timestamp: JSONNull?
    let series: String
    let seasonNumber, episodeNumber: Int

    enum CodingKeys: String, CodingKey {
        case title, formats, subtitles, id, thumbnail, description, duration, timestamp, series
        case seasonNumber = "season_number"
        case episodeNumber = "episode_number"
    }
}

// MARK: - Format
struct Format: Codable {
    let formatID: String
    let formatIndex: JSONNull?
    let url, manifestURL: String
    let tbr: Double
    let ext: FormatEXT
    let fps: Double
    let formatProtocol: ProtocolEnum
    let preference, quality: JSONNull?
    let hasDRM: Bool
    let width, height: Int
    let vcodec: Vcodec
    let acodec: Acodec
    let dynamicRange: JSONNull?

    enum CodingKeys: String, CodingKey {
        case formatID = "format_id"
        case formatIndex = "format_index"
        case url
        case manifestURL = "manifest_url"
        case tbr, ext, fps
        case formatProtocol = "protocol"
        case preference, quality
        case hasDRM = "has_drm"
        case width, height, vcodec, acodec
        case dynamicRange = "dynamic_range"
    }
}

enum Acodec: String, Codable {
    case mp4A402 = "mp4a.40.2"
}

enum FormatEXT: String, Codable {
    case mp4 = "mp4"
}

enum ProtocolEnum: String, Codable {
    case m3U8Native = "m3u8_native"
}

enum Vcodec: String, Codable {
    case avc14D401E = "avc1.4D401E"
    case avc14D401F = "avc1.4D401F"
    case avc1640028 = "avc1.640028"
}

// MARK: - Subtitles
struct Subtitles: Codable {
    let de: [De]
}

// MARK: - De
struct De: Codable {
    let url: String
    let ext: DeEXT
}

enum DeEXT: String, Codable {
    case scc = "scc"
    case ttml = "ttml"
    case vtt = "vtt"
}

typealias Welcome = [WelcomeElement]

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
