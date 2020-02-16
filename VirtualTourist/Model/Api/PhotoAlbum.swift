//
//  PhotoAlbum.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

struct PhotoAlbum: Codable {

    let page: Int
    let pages: Int
    let perPage: Int
    let total: Int
    let photo: [Image]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photo
    }
}
