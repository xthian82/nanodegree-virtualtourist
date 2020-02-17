//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//
import Foundation

class FlickrClient {

    // MARK: - Properties
    static let decoder = JSONDecoder()

    // MARK: Endpoints
    private enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let propsParam = "&per_page=15&format=json&nojsoncallback=1"
        static let apiKeyParam = "&api_key=3e659047e9b28abd3c5a961c7522217d"
        
        // options
        case photosFromLocation(lat: Double, lon: Double, page: Int)
        
        // helper
        var stringValue: String {
            switch self {
            // all pics from a location
            case .photosFromLocation(let lat, let lon, let page):
                return Endpoints.base + "&lat=\(lat)&lon=\(lon)&page=\(String(describing: page))\(Endpoints.propsParam)\(Endpoints.apiKeyParam)"
            }
        }
        
        // for url task
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: - Request Functions
    class func getPhotoFromsLocation(lat: Double, lon: Double, page: Int, completion: @escaping (PhotoAlbumResponse?, Error?) -> Void) {
    
        let endpoint = Endpoints.photosFromLocation(lat: lat, lon: lon, page: page).url
        let task = URLSession.shared.dataTask(with: endpoint, completionHandler: {(data, res, err) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, err)
                }
                return
            }

            //let rawString = String(data: data, encoding: .utf8)!
            //print("rawVAl ===> \(rawString)")
            
            do {
                let photoResponse = try decoder.decode(PhotoAlbumResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(photoResponse, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        })
        task.resume()
    }
}
