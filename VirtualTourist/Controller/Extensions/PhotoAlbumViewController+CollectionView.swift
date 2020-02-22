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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let total = fetchedPhotosController.fetchedObjects?.count ?? 0
        if (total == 0) {
            collectionView.setEmptyMessage("This pin has no images.")
        } else {
            collectionView.restore()
        }
        return total
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCell, for: indexPath) as! CollectionViewCell
        let photo = fetchedPhotosController.object(at: indexPath)
        cell.imageViewDetail.image = UIImage(data: photo.image!)
        
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
    
    // MARK: - Flow Layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - Helpers
    func downloadFlickrImages(isFromCollectionButton: Bool) {
        // try to test different pages
        var pageNumber = 1
        if let pages = pages, pages > 0 {
            pageNumber = Int.random(in: 1 ... pages)
        }
        
        guard let currentLocation = currentLocation else {
            print("no location selected! ... quitting")
            return
        }

        FlickrClient.getPhotoFromsLocation(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, page: pageNumber) { (response, error) in
            guard let photoAlbum = response else {
                print("no photo downloaded. we quit")
                return
            }
            print("total photos \(photoAlbum.photos.photo?.count ?? -1)")
            self.newCollectionButton.isEnabled = false
            self.pages = photoAlbum.photos.pages
            self.asyncDowload(photoAlbum.photos.photo, isFromCollectionButton: isFromCollectionButton, completionHandler: { hasData in
                if hasData {
                    self.collectionView.reloadData()
                }
                self.newCollectionButton.isEnabled = true
            })
        }
    }
    
    func deleteCellItems(cellsToDelete: [IndexPath]?) {
        self.newCollectionButton.isEnabled = false
        asyncDelete(indexCells: cellsToDelete) { hasData in
            if hasData {
                self.collectionView.reloadData()
            }
            self.newCollectionButton.isEnabled = true
            self.setEditing(false, animated: true)
        }
    }
    
    /// utility to enable/disable edit mode
    private func areAnyItemSelected() -> Bool {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else {
            return false
        }
        
        return selectedItems.count > 0
    }

    /// download image from collection cell in the background
    private func asyncDowload(_ images: [Image]?, isFromCollectionButton: Bool, completionHandler: @escaping (_ disFinish: Bool) -> Void) {
        guard let images = images else {
            completionHandler(false)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            // first we delete any pic if any
            self.clearFetchedPhotos(isFromCollectionButton: isFromCollectionButton)
            
            for image in images {
                if let url = image.imageLocation(), let imgData = try? Data(contentsOf: url) {
                    self.addPhoto(imgData)
                }
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(true)
            })
        }
    }
    
    /// delete all cells in the background
    private func asyncDelete(indexCells: [IndexPath]?, completionHandler: @escaping (_ disFinish: Bool) -> Void) {
        guard let indexPaths = indexCells else {
            // no index to download, we skip
            completionHandler(false)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            for indexPath in indexPaths {
                self.deletePhoto(indexPath)
            }

            DispatchQueue.main.async(execute: { () -> Void in
                completionHandler(true)
            })
        }
    }
}
