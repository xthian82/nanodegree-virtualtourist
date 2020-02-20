//
//  LastMapLocation.swift
//  VirtualTourist
//
//  Created by Cristhian Jesus Recalde Franco on 20/02/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import CoreData

extension LastMapPosition {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
