//
//  CollectionExtension.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-18.
//

import Foundation
import UIKit
import CoreData

//MARK: Delegate and Data source
extension PhotoAlbumVC : UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count //MARK: adjust
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell

        cell.imageView?.image = images[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //delete it from view controller
        images.remove(at: indexPath.row)
        
        //delete a image from collection if tapped
        collectionView.deleteItems(at: [indexPath])

        //MARK: delete image from CoreData
        let photo = fetchedResultsController.object(at: indexPath)
        print(photo.description)
        AppDelegate.dataController.viewContext.delete(photo)
        try? AppDelegate.dataController.viewContext.save()
        
        updateFetchResultsController()
    }
}

//MARK: Flow Layout
extension PhotoAlbumVC : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return collectionViewInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
      return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let padding = cellsPerRow * collectionViewInsets.left
        let totalWidth = (view.bounds.width - padding)
        let itemWidth = totalWidth / cellsPerRow
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        return itemSize
  }
}
