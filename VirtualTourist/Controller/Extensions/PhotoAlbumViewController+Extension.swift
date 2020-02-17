//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCell, for: indexPath) as! CollectionViewCell
        let imgAlbum = images![indexPath.row]

        asyncDowload(imgAlbum) { image in
            cell.imageViewDetail.image = image
        }
        
        return cell
    }
    
    //TODO: implement delete from album an store
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        if !selectedItems.contains(indexPath.row) {
            print("+ image added at \(indexPath.row)")
            selectedItems.insert(indexPath.row)
        } else {
            print("- image removed at \(indexPath.row)")
            selectedItems.remove(indexPath.row)
        }
        
        isDeleteMode = (selectedItems.count != 0)
        print("capacity = \(selectedItems.count), is Delete = \(isDeleteMode)")
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCell, for: indexPath) as! CollectionViewCell
        //cell.isHighlighted = true
    }
      
    func asyncDowload(_ image: Image, completionHandler handler: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            if let url = image.imageLocation(), let imgData = try? Data(contentsOf: url), let img = UIImage(data: imgData)
            {
                DispatchQueue.main.async(execute: { () -> Void in
                        handler(img)
                })
            }
        }
    }
}
