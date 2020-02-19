//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by Cristhian Jesus Recalde Franco on 18/02/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
