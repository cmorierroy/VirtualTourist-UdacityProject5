//
//  TravelLocationsMapVC.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-04.
//

import UIKit
import MapKit

class TravelLocationsMapVC: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //add gesture recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(tapGesture:)))
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func mapTapped(tapGesture:UITapGestureRecognizer)
    {
        //convert tap to map coordinates
        let tappedLoc = tapGesture.location(in: mapView)
        let mapCoordinates = mapView.convert(tappedLoc, toCoordinateFrom: mapView)
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = mapCoordinates
        mapView.addAnnotation(newPin)
                
//                let newPin = Pin(context: dataController.viewContext)
//                newPin.latitude = pressedLocation.coordinate.latitude
//                newPin.longitude = pressedLocation.coordinate.longitude
//                try? dataController.viewContext.save()
    }


}

