//
//  MapExtension.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-09.
//

import Foundation
import MapKit

extension TravelLocationsMapVC : MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {        
        //load album view
        performSegue(withIdentifier: "pinTapped", sender: view.annotation?.coordinate)
    }
}
