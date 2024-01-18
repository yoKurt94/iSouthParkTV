//
//  Services.swift
//  iSouthParkTV
//
//  Created by Yannik Hörnschemeyer on 01.07.22.
//

import Foundation

class Services {
    
    enum ServiceErrors: Error {
        case NoDataReceived
        case NotAValidURL
        case DecodingJsonFailed
        case DecodedObjIsNil
        case NoVideoURLSFound
    }
    
    enum SouthParkAPIType {
    case Episodes
    case Characters
    case Relatives
    }
    
    public static let shared = Services()
    
    var episodes: [SouthParkAPIEpisode] = []
    let numOfEpisodes = 314
    
    func getDataFromSouthParkAPI(urlString: String) {
        var currentNo = 1
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("ERROR IN URLSESSION - error is not nil or no data.")
                return
            }
        }.resume()
    }
    
    func sendNetworkRequestAndDecode<T: Decodable>(with urlString: String, completion: @escaping (Result<T, Error>) -> ()){
        let url = URL(string: urlString)
        guard let url = url else {
            completion(.failure(ServiceErrors.NotAValidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(ServiceErrors.NoDataReceived))
                return
            }
            if error != nil{
                completion(.failure(error!))
                return
            }
            var decodedObj: T?
            do {
                let obj = try JSONDecoder().decode(T.self, from: data)
                decodedObj = obj
            } catch {
                completion(.failure(ServiceErrors.DecodingJsonFailed))
            }
            guard let decodedObj = decodedObj else {
                completion(.failure(ServiceErrors.DecodedObjIsNil))
                return
            }
            completion(.success(decodedObj))
        }.resume()
        
    }
    
    func requestVideoLinks(episodeId: String, lang: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let url = URL(string: "http://217.160.33.35:7777/southparkapi?id=\(episodeId)&lang=ge")
        URLSession.shared.dataTask(with: url!) { data, response, error in
            let urlString = url?.absoluteString
            var videoLinks: [String] = []
            guard let data = data else {
                completion(.failure(ServiceErrors.NoDataReceived))
                return
            }
            
            var episodeParts: [WelcomeElement]?
            do {
                episodeParts = try JSONDecoder().decode([WelcomeElement].self, from: data)
            } catch {
                completion(.failure(error))
            }
            guard let episodeParts = episodeParts else {
                return
            }

            for videoElement in episodeParts {
                var highesResolutionURL = videoElement.formats.max(by: {$0.width < $1.width})?.url
                guard let highesResolutionURL = highesResolutionURL else {
                    completion(.failure(ServiceErrors.NoVideoURLSFound))
                    return
                }
                videoLinks.append(highesResolutionURL)
            }
            completion(.success(videoLinks))
        }.resume()
    }
}
