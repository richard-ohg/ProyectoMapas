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

    @IBOutlet weak var sourceTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var myMap: MKMapView!
    
    var parserJson: Locations!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMap.delegate = self
//        Create region for zoom in CU
        let center = CLLocationCoordinate2D(latitude: 19.324621, longitude: -99.182536)
        let region = MKCoordinateRegion(center: center , span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03));
        myMap.setRegion(region, animated: true);
        
        parserJson = loadJson(fileName: "Locations")
//        for x in parserJson.locations {
//            print(x)
//        }
        createMarkers(arrayLocations: parserJson.locations)
    }
    
    
    @IBAction func createRoute(_ sender: UIButton) {
        let source = sourceTextField.text!
        let destination = destinationTextField.text!
        
        if source.isEmpty || destination.isEmpty{
            let alert = UIAlertController(title: "Error", message: "No debes dejar campos vacios", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(actionOk)
            present(alert, animated: true)
            return
        }
        
        guard let filterSource = parserJson.locations.filter({$0.title.lowercased().contains(source.lowercased())}).first else{
            let alert = UIAlertController(title: "Not Found", message: "No se encontró el origen, verifica que se encuentre entre los 20 lugares disponibles o este bien escrito", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(actionOk)
            present(alert, animated: true)
            return
        }

        guard let filterDestination = parserJson.locations.filter({$0.title.lowercased().contains(destination.lowercased())}).first else{
            let alert = UIAlertController(title: "Not Found", message: "No se encontró el destino, verifica que se encuentre entre los 20 lugares disponibles o este bien escrito", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(actionOk)
            present(alert, animated: true)
            return
        }
        
        print("From: \(filterSource) to: \(filterDestination) ")
        
        let startLocation = CLLocationCoordinate2D(latitude: filterSource.latitud, longitude: filterSource.longitud)
        let endLocation = CLLocationCoordinate2D(latitude: filterDestination.latitud, longitude: filterDestination.longitud)
        
        let startPlacemark = MKPlacemark(coordinate: startLocation);
        let endPlacemark = MKPlacemark(coordinate: endLocation);
        
        let routeRequest = MKDirections.Request();
        routeRequest.source = MKMapItem(placemark: startPlacemark)
        routeRequest.destination = MKMapItem(placemark: endPlacemark)
        routeRequest.transportType = .walking
        
        let directions = MKDirections(request: routeRequest);
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let directionsResponse = response else {
                return
            }
            let route = directionsResponse.routes.first
            self.myMap.addOverlay(route!.polyline)
            
            // Create area between A and B point
            let area = route?.polyline.boundingMapRect
            self.myMap.setRegion(MKCoordinateRegion(area!), animated: true)
        }
        
            
    }
    
//    Function for create Annotations in Map
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
    
//    Function for parser json from file
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
    
    // When an overlay is added (addOverlay()), this method is called
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let line = MKPolylineRenderer(overlay: overlay)
        line.strokeColor = .blue
        line.lineWidth = 6.0
        return line
    }

}

