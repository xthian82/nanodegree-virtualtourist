//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Cristhian Recalde on 2/12/20.
//  Copyright © 2020 Cristhian Recalde. All rights reserved.
//

import UIKit
import MapKit

@IBDesignable class ViewController: UIViewController, MKMapViewDelegate {
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func selectPinTabLocation(_ sender: UITapGestureRecognizer) {
        print("tap pin selected")
    }
}

