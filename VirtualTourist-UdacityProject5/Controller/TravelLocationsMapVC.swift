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
    var currendCoordinateForNewPin:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    var pins:[Pin] = []
    
    // MARK: LIFECYCLE
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //add gesture recognizer
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapTapped(tapGesture:)))
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        //get pins from core data
        setupFetchedResultsController();
           
        //setup pins on map
        loadPins()        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        DataController.shared.saveContext()
    }
    
    
    @objc func mapTapped(tapGesture:UILongPressGestureRecognizer)
    {
        if tapGesture.state == .began
        {
            //convert tap to map coordinates
            let tappedLoc = tapGesture.location(in: mapView)
            currendCoordinateForNewPin = mapView.convert(tappedLoc, toCoordinateFrom: mapView)
        }
        else if tapGesture.state == .changed
        {
            //convert tap to map coordinates
            let tappedLoc = tapGesture.location(in: mapView)
            currendCoordinateForNewPin = mapView.convert(tappedLoc, toCoordinateFrom: mapView)
        }
        else if tapGesture.state == .ended
        {
            //store pin
            let newPin = Pin(context: DataController.shared.viewContext)
            newPin.latitude = currendCoordinateForNewPin.latitude
            newPin.longitude = currendCoordinateForNewPin.longitude
            
            //save context
            DataController.shared.saveContext()
            
            //update fetchedResultsController
            updateFetchedResultsController()
            
            //add pin to map
            addPin(newPin)
        }
    
    }
    
    //MARK: FETCHED RESULTS CONTROLLER
    fileprivate func setupFetchedResultsController()
    {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        
        updateFetchedResultsController()
    }
    
    func updateFetchedResultsController()
    {
        do
        {
            try fetchedResultsController.performFetch()
            
            //update VC's pin collection
            if let pins = fetchedResultsController.fetchedObjects
            {
                self.pins = pins
            }
        }
        catch
        {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //MARK: HELPER FUNCTIONS
    func addPin(_ pin:Pin)
    {
        let newPin = MKPointAnnotation()
        newPin.coordinate.latitude = pin.latitude
        newPin.coordinate.longitude = pin.longitude
        mapView.addAnnotation(newPin)
    }
    
    func getPinByLocation(_ latitude: Double, _ longitude:Double) -> Pin
    {
        for pin in pins
        {
            if(pin.latitude == latitude && pin.longitude == longitude)
            {
                return pin
            }
        }
        
        print("Pin not found!")
        return Pin()
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
    
    //MARK: PREPARE FOR SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //set map view on PhotoAlbumVC to same region/center as current map
        if let vc = segue.destination as? PhotoAlbumVC
        {
            if let pinCoord = sender as? CLLocationCoordinate2D
            {
                //give the photo album view controller a region centered on the tapped pin
                let region = MKCoordinateRegion(center: pinCoord, latitudinalMeters: 3000, longitudinalMeters: 3000)
                vc.region = region
                
                //get the core data pin object that corresponds to tapped pin (needed to access attached pictures)
                vc.pin = getPinByLocation(pinCoord.latitude, pinCoord.longitude)
            }
        }
    }
}
