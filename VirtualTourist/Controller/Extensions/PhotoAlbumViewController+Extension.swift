//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import Foundation

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - Edit Mode?
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        isEditMode = editing
        collectionView.allowsMultipleSelection = editing
        changeTextButton()
    }
    
    //MARK: - Collection Functions
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

    // mark selected items, set edit mode if corresponds
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        setEditing(areAnyItemSelected(), animated: true)
    }
    
    // mark options for deselection - are still enable to update?
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        setEditing(areAnyItemSelected(), animated: true)
    }
    
    // MARK: - Helpers
    func downloadFlickrImages() {
        if isEditMode {
            print("[WARN] downlad collection in editMode not suported!")
            return
        }
        
        // try to test different pages
        var pageNumber = 1
        if let pages = pages {
            pageNumber = Int.random(in: 1 ... pages)
        }

        FlickrClient.getPhotoFromsLocation(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, page: pageNumber) { (response, error) in
            guard let photoAlbum = response else {
                return
            }
            self.pages = photoAlbum.photos.pages
            self.images = photoAlbum.photos.photo
        }
        self.collectionView.reloadData()
    }
    
    func deleteCellItems() {
        if !isEditMode {
            print("[WARN] delete cell is not in editMode!")
            return
        }
        
        if let selectedCells = collectionView.indexPathsForSelectedItems {
            let items = selectedCells.map { $0.item }.sorted().reversed()
            for item in items {
                self.images?.remove(at: item)
            }
            collectionView.deleteItems(at: selectedCells)
        }
        
        setEditing(false, animated: true)
    }
    
    // utility to enable/disable edit mode
    private func areAnyItemSelected() -> Bool {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else {
            return false
        }
        
        return selectedItems.count > 0
    }

    // download image from collection cell in the background
    private func asyncDowload(_ image: Image, completionHandler handler: @escaping (_ image: UIImage) -> Void) {
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
