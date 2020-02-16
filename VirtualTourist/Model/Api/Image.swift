//
//  Image.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

struct Image: Codable {
    let id: Int
    let owner: String
    let secret: String
    let server: Int
    let title: String
    let isPublic: Int
    let isFriend: Int
    let isFamily: Int
    
    enum Codingkeys: String, CodingKey {
        case id
        case owner
        case secret
        case server
        case title
        case isPublic = "ispublic"
        case isFriend = "isfriend"
        case isFamily = "isfamily"
    }
}
