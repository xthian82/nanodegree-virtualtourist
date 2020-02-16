//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//
import Foundation
import OAuthSwift

class FlickrClient {

    // MARK: - Properties
    //static let userId = "186992282@N07"
    private static let baseFlickr = "https://www.flickr.com/services"
    private static let oauthswift = OAuth1Swift(
        consumerKey:    "3e659047e9b28abd3c5a961c7522217d",
        consumerSecret: "e9a6d80d1e310540",
        requestTokenUrl: "\(baseFlickr)/oauth/request_token",
        authorizeUrl:    "\(baseFlickr)/oauth/authorize",
        accessTokenUrl:  "\(baseFlickr)/oauth/access_token"
    )
    
    static var tokenCredential = OAuthSwiftCredential(consumerKey: "3e659047e9b28abd3c5a961c7522217d", consumerSecret: "e9a6d80d1e310540")
    
    // MARK: Endpoints
    enum Endpoints {
        
        static let base = "\(baseFlickr)/rest/?method=flickr.photos.geo.photosForLocation"
        
        case photosFromLocation(lat: Double, lon: Double, api: String, token: String)
        case thumbnail(farmId: Int, server: Int, id: Int, secret: String)
        
        var stringValue: String {
            switch self {
            // all pics from a location
            case .photosFromLocation(let lat, let lon, let api, let token):
                return Endpoints.base + "lat=\(lat)&lon=\(lon)&format=json&nojsoncallback=1&api_key=\(api)&auth_token=\(token)"
            // thumbnails for a pic
            case .thumbnail(let farmId, let server, let id, let secret):
                return "https://farm\(farmId).staticflickr.com/\(server)/\(id)_\(secret)_t.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    //MARK: - Request Functions
    class func getPhotoFromsLocation(latitude: Double, longitude: Double, completion: @escaping (PhotoAlbumResponse?, Error?) -> Void) {
        loadRequestToken()
        let endpoint = Endpoints.photosFromLocation(lat: latitude, lon: longitude, api: tokenCredential.oauthTokenSecret, token: tokenCredential.oauthToken).url
        let task = URLSession.shared.dataTask(with: endpoint, completionHandler: {(data, res, err) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, err)
                }
                return
            }
            let decoder = JSONDecoder()
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
    
    class func downloadThumbnailImage(image: Image, completionHandler: @escaping (Data?, Error?) -> Void) {
        let endpoint = Endpoints.thumbnail(farmId: image.id, server: image.server, id: image.id, secret: image.secret).url
        let task = URLSession.shared.dataTask(with: endpoint, completionHandler: {(data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(data, nil)
            }
        })
        task.resume()
    }
    
    // MARK: - OAuth1.0
    class func loadRequestToken() {
        if (!tokenCredential.isTokenExpired()) {
            print("token still valid ... we quit")
        } else {
            print("token expired, requesting a new one")
        }
        
        oauthswift.authorize(withCallbackURL: URL(string: "VirtualTourist://oauth-callback/flickr")!) { result in
            switch result {
            case .success(let (credential, response, parameters)):
              print("-------------------------")
              print("credential = \(credential)")
              print("response = \(String(describing: response))")
              print("parameters = \(parameters)")
              tokenCredential = credential
              // Do your request
            case .failure(let error):
              print(error.localizedDescription)
            }
        }
    }
}
