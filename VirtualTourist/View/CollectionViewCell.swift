//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/16/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    static let id = "CollectionViewCell"
    @IBOutlet var imageViewDetail: UIImageView!
    @IBOutlet weak var activityDownload: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            imageViewDetail.alpha = self.isSelected ? 0.5 : 1.0
        }
    }
    
    override func awakeFromNib() {
       super.awakeFromNib()
       // Initialization code
   }
}
