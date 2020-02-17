//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: - Layout Properties
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                          sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                          insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                          minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }*/

    
    //MARK: - Data Handling
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let total = images?.count ?? 0
        if (total == 0) {
            collectionView.setEmptyMessage("This pin has no images.")
        } else {
            collectionView.restore()
        }
        return total
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
