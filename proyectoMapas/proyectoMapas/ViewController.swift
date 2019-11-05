//
//  ViewController.swift
//  proyectoMapas
//
//  Created by Ricardo Hernández González on 04/11/19.
//  Copyright © 2019 unam. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var source: UITextField!
    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var myMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMap.delegate = self
        let center = CLLocationCoordinate2D(latitude: 19.324621, longitude: -99.182536)
        let region = MKCoordinateRegion(center: center , span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02));
        myMap.setRegion(region, animated: true);
        
        let parserJson = loadJson(fileName: "Locations")!
//        for x in arrayLocations!.locations {
//            print(x.title)
//        }
        createMarkers(arrayLocations: parserJson.locations)
    }

    func createMarkers(arrayLocations: [Location]){
        for item in arrayLocations {
            let myAnnotation = CustomAnnotation();
            myAnnotation.coordinate = CLLocationCoordinate2D(latitude: item.latitud, longitude: item.longitud)
            myAnnotation.title = item.title
            myAnnotation.subtitle = item.subtitle
            myAnnotation.imageURL = item.photo
    
            myMap.addAnnotation(myAnnotation)
        }
    }
    
    func loadJson(fileName: String) -> Locations?{
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Locations.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PinAnnotationView")
        
        if pinAnnotationView == nil {
            pinAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "PinAnnotationView")
            
            // Callout is a popover above the pin
            pinAnnotationView?.canShowCallout = true
            
        } else {
            // Reusing from recycled annotations
            pinAnnotationView?.annotation = annotation
        }
        
        if let pinAnnotation = annotation as? CustomAnnotation {
            pinAnnotationView?.image = UIImage(named: pinAnnotation.imageURL)
        }
        
        return pinAnnotationView
        
    }

}

