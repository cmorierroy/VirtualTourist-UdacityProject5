//
//  PhotoAlbumVC.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-13.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, NSFetchedResultsControllerDelegate
{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin:Pin!
    var images:[UIImage] = []
    var region:MKCoordinateRegion = MKCoordinateRegion()
    var picturesStored:Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        
        setupMap()
        setupCollectionView()
        setupFetchedResultsController()
        setupPictures()
    }
    
    @IBAction func backButtonPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func handlePhotosForLocation(result:ImageCollection?,error:Error?)
    {
        if error != nil
        {
            displayAlert(title: "Error", message: error?.localizedDescription ?? "")
        }
        else
        {
            if let imageCollection = result
            {
                //if there are no pictures
                if(Int(imageCollection.total) == 0)
                {
                    collectionView.isHidden = true
                    newCollectionButton.isHidden = true
                }
                else
                {
                    collectionView.isHidden = false
                    newCollectionButton.isHidden = false
                }
                
                for image in imageCollection.photo
                {
                    FlickrClient.downloadPhoto(image: image, completion: handleDownloadPhoto(image:error:))
                }
            }
        }
    }
    
    func handleDownloadPhoto(image: UIImage?, error: Error?)
    {
        if error != nil
        {
            displayAlert(title: "Error", message: error?.localizedDescription ?? "")
        }
        else
        {
            if let image = image
            {
                //save image into view controller
                images.append(image)
                
                //reload collection view
                self.collectionView.reloadData()
                
                //save image into photo context
                let newPhoto = Photo(context: AppDelegate.dataController.viewContext)
                newPhoto.image = image.pngData()
                newPhoto.pin = pin
                try? AppDelegate.dataController.viewContext.save()
            }
        }
    }
    //MARK: HELPER FUNCTIONS
    func setupMap()
    {
        //set pin in center of map
        mapView.region = region
        let newPin = MKPointAnnotation()
        newPin.coordinate = region.center
        mapView.addAnnotation(newPin)
    }
    
    func setupCollectionView()
    {
        //Set collection cell dimensions/spacing
        let space:CGFloat = 2.0
        let dimension = 10.0 //(collectionView.frame.size.width - (4 * space)) / 3.0
                
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func displayAlert(title: String, message: String)
    {
        let alertVC = UIAlertController(title:title,message: message,preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        showDetailViewController(alertVC, sender: nil)
    }
    
    fileprivate func setupFetchedResultsController()
    {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do
        {
            try fetchedResultsController.performFetch()
        }
        catch
        {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func setupPictures()
    {
        if let data = fetchedResultsController.fetchedObjects
        {
            if data.count == 0
            {
                //NO PICTURES STORED, INITIATE API CALL
                picturesStored = false
                collectionView.isHidden = false
                newCollectionButton.isHidden = false
                
                //setup place holders
                
                print("NO PICS YET")
                
                FlickrClient.photosForLocation(lat: pin.latitude, lon: pin.longitude, completion: handlePhotosForLocation(result:error:))
            }
            else
            {
                collectionView.isHidden = false
                newCollectionButton.isHidden = false
                
                //save pics in view controller
                for image in data
                {
                    if let photoData = image.image
                    {
                        if let photo = UIImage(data:photoData)
                        {
                            images.append(photo)
                        }
                    }
                }
                //update collection view
                self.collectionView.reloadData()
                print("PICS")
            }
        }
    }
}
