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
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
//    {
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
//
//        if annotationView == nil
//        {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
//
//        }
//
////        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        annotationView?.canShowCallout = true
//
//        return annotationView
//    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {        
        //load album view
        performSegue(withIdentifier: "pinTapped", sender: view.annotation?.coordinate)
    }
    
    

//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
//    {
//        let url:URL?
//
//        if let subtitle = view.annotation?.subtitle!
//        {
//            url = URL(string: subtitle)
//            openURL(url:url)
//        }
//    }
}
