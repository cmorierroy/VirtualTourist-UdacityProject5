//
//  TravelLocationsMapVC.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-04.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapVC: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    // MARK: LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //add gesture recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(tapGesture:)))
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //get pins from core data
        setupFetchedResultsController();
           
        //setup pins on map
        loadPins()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        try? AppDelegate.dataController.viewContext.save()
    }
    
    
    @objc func mapTapped(tapGesture:UITapGestureRecognizer)
    {
        //convert tap to map coordinates
        let tappedLoc = tapGesture.location(in: mapView)
        let pinCoordinates = mapView.convert(tappedLoc, toCoordinateFrom: mapView)
        
        //store pin
        let newPin = Pin(context: AppDelegate.dataController.viewContext)
        newPin.latitude = pinCoordinates.latitude
        newPin.longitude = pinCoordinates.longitude
        try? AppDelegate.dataController.viewContext.save()
        
        //add pin to map
        addPin(newPin)
    }
    
    fileprivate func setupFetchedResultsController()
    {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        do
        {
            try fetchedResultsController.performFetch()
        }
        catch
        {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func addPin(_ pin:Pin)
    {
        let newPin = MKPointAnnotation()
        newPin.coordinate.latitude = pin.latitude
        newPin.coordinate.longitude = pin.longitude
        mapView.addAnnotation(newPin)
    }
    
    func loadPins()
    {
        if let section = fetchedResultsController.sections?[0]
        {
            var indexPath:IndexPath
            
            for index in 0 ..< section.numberOfObjects
            {
                indexPath = IndexPath(row: index, section: 0)
                let pin = fetchedResultsController.object(at: indexPath)
                
                addPin(pin)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //set map view on PhotoAlbumVC to same region/center as current map
        if let vc = segue.destination as? PhotoAlbumVC
        {
            vc.region = mapView.region
        }
    }
}
