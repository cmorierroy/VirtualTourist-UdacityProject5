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
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin:Pin!
    var images:[UIImage] = []
    var region:MKCoordinateRegion = MKCoordinateRegion()
    let collectionViewInsets = UIEdgeInsets(top: 3.0,
                                               left: 3.0,
                                               bottom: 3.0,
                                               right: 3.0)
    let cellsPerRow: CGFloat = 3
    
    @IBAction func backButtonPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: IB ACTIONS
    @IBAction func newCollectionTapped(_ sender: Any)
    {
        //start activity indicator
        activityIndicator.startAnimating()
        
        pin.page = pin.page+1
        
        if(pin.page == pin.maxPage)
        {
            pin.page = 1
        }
        
        //clear all previous photos
        DispatchQueue.main.async
        {
            self.deletePhotos()
        }
        
        //get new collection
        let q = DispatchQueue.global(qos: .userInitiated)
        q.async { () -> Void in
            FlickrClient.photosForLocation(lat: self.pin.latitude, lon: self.pin.longitude, page: Int(self.pin.page), completion: self.handlePhotosForLocation(result:error:))
        }
    }
    
    //MARK: LIFECYCLE FUNCTIONS
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        
        setupMap()
        setupFetchedResultsController()
        setupPictures()
    }
    
    
    
    //MARK: API CALL HANDLERS
    func handlePhotosForLocation(result:ImageCollection?,error:Error?)
    {
        if error != nil
        {
            displayAlert(title: "Error", message: error?.localizedDescription ?? "")
            DispatchQueue.main.async
            {
                self.activityIndicator.stopAnimating()
            }
        }
        else
        {
            if let imageCollection = result
            {
                //if there are no pictures
                DispatchQueue.main.async
                {
                    if(Int(imageCollection.total) == 0)
                    {
                        self.collectionView.isHidden = true
                        self.newCollectionButton.isHidden = true
                    }
                    else
                    {
                        self.pin.maxPage = Int32(imageCollection.pages)
                        self.collectionView.isHidden = false
                        self.newCollectionButton.isHidden = false
                        
                        let q = DispatchQueue.global(qos: .userInitiated)
                        
                        for image in imageCollection.photo
                        {
                            q.sync
                            { () -> Void in
                                FlickrClient.downloadPhoto(image: image, completion: self.handleDownloadPhoto(image:error:))
                            }
                        }
                    }
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
                DispatchQueue.main.async
                {
                    self.collectionView.reloadData()
                    //create coredata photo
                    let newPhoto = Photo(context: DataController.shared.viewContext)
                    newPhoto.image = image.pngData()
                    newPhoto.pin = self.pin
                    
                    //save context
                    DataController.shared.saveContext()
                    
                    //update fetchResultsController
                    self.updateFetchResultsController()
                }
            }
        }
        DispatchQueue.main.async
        {
            self.activityIndicator.stopAnimating()
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
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
    }
    
    func setupPictures()
    {
        //if this pin was never fetched for
        if (!pin.loaded)
        {
            //NO PICTURES STORED, INITIATE API CALL
            collectionView.isHidden = false
            newCollectionButton.isHidden = false
            activityIndicator.startAnimating()
            
            let q = DispatchQueue.global(qos: .userInitiated)
            
            q.sync
            { ()->Void in
                FlickrClient.photosForLocation(lat: self.pin.latitude, lon: self.pin.longitude, page: Int(self.pin.page), completion: self.handlePhotosForLocation(result:error:))
            }
            
            pin.loaded = true
        }
        else
        {
            updateFetchResultsController()
            
            if let data = fetchedResultsController.fetchedObjects
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
            }
        }
    }
    
    func deletePhotos()
    {
        for _ in 0..<images.count
        {
            collectionView.deleteItems(at:[IndexPath(item: 0, section: 0)])
            let photo = fetchedResultsController.object(at: IndexPath(item: 0, section: 0))
            DataController.shared.viewContext.delete(photo)
            DataController.shared.saveContext()
            updateFetchResultsController()
        }

        //clear vc copy of images
        images = []
    }
    
    //MARK: ERROR HANDLING
    func displayAlert(title: String, message: String)
    {
        DispatchQueue.main.async
        {
            let alertVC = UIAlertController(title:title,message: message,preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.showDetailViewController(alertVC, sender: nil)
        }
    }
    
    //MARK: FETCHED RESULTS CONTROLLER
    fileprivate func setupFetchedResultsController()
    {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)

        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        updateFetchResultsController()
    }
    
    func updateFetchResultsController()
    {
        do
        {
            try fetchedResultsController.performFetch()
        }
        catch
        {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
}
