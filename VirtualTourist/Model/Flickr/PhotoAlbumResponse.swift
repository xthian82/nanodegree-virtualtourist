//
//  PhotoAlbumResponse.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import Foundation

struct PhotoAlbumResponse: Codable {

    let photos: PhotoAlbum
    let stat: String
    
    enum CodingKeys: String, CodingKey {
        case photos
        case stat
    }
}
