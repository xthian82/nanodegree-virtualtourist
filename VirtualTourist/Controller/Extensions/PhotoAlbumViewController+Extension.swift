//
//  PhotoAlbumViewController+Extension.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/15/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    //TODO: implement count from store
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    // TODO: implement load image in the background
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        //cell.imageViewDetail = UIImageView(image: UIImage(named: "AppIcon")!)
        cell.imageViewDetail.image = UIImage(named: "AppIcon")!

        return cell
    }
    
    //TODO: implement delete from album an store
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        //let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        //detailController.meme = self.memes[indexPath.row]
        //self.navigationController!.pushViewController(detailController, animated: true)
        print("image selected at \(indexPath.row)")
    }
}
