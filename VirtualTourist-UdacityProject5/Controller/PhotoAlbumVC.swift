//
//  PhotoAlbumVC.swift
//  VirtualTourist-UdacityProject5
//
//  Created by Cédric Morier-Roy on 2020-11-13.
//

import UIKit
import MapKit

class PhotoAlbumVC: UIViewController
{
    
    @IBOutlet weak var mapView: MKMapView!
    var region:MKCoordinateRegion = MKCoordinateRegion()
    
    @IBOutlet weak var newCollectionButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool)
    {
        super.viewWillAppear(animated)
        mapView.region = region
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = region.center
        mapView.addAnnotation(newPin)
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }

}
