//
//  PhotoAlbumViewController+CollectionView.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit
import CoreData

//MARK: Collection Delegate
extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //MARK: - Edit Mode?
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        isEditMode = editing
        collectionView.allowsMultipleSelection = editing
        changeTextButton()
    }
    
    //MARK: - Collection Functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedPhotosController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let total = fetchedPhotosController.sections?[section].numberOfObjects ?? 0
        if (total == 0) {
            collectionView.setEmptyMessage("This pin has no images.")
        } else {
            collectionView.restore()
        }
        return total
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.id, for: indexPath) as! CollectionViewCell
        
        let photo = fetchedPhotosController.object(at: indexPath)
        if  let image = photo.image {
            cell.imageViewDetail.image = UIImage(data: image)
        }
        
        return cell
    }

    // mark selected items, set edit mode if corresponds
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        setEditing(areAnyItemSelected(), animated: false)
    }
    
    // mark options for deselection - are still enable to update?
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        setEditing(areAnyItemSelected(), animated: false)
    }
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (2 * spacing) + ((noOfCellsInRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        let width = (collectionView.bounds.width - totalSpacing)/noOfCellsInRow
        return CGSize(width: width, height: width)
    }
}
