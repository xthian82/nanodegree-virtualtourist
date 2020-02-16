//
//  ErrorResponse.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//
import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
        
    enum CodingKeys: String, CodingKey {
        case stat
        case code
        case message
    }
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
    
}
