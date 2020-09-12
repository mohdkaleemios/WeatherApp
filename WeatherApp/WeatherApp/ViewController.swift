//
//  ViewController.swift
//  WeatherApp
//
//  Created by bigstep on 12/09/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class ViewController: UIViewController {
    var map: MKMapView?
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    var currentPlacemark: CLPlacemark?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMapView()
        map!.delegate = self
        locationManager.delegate = self
        configureLocationServices()
    }
    
    func setUpMapView() {
        map = MKMapView()
        self.view.addSubview(map!)
        map?.delegate = self
        map?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            map?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 3).isActive = true
            map?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            map?.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 3).isActive = true
            map?.bottomAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        map?.leftAnchor.constraint(equalTo: self.view!.leftAnchor).isActive = true
        map?.rightAnchor.constraint(equalTo: self.view!.rightAnchor).isActive = true
    }
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.map!.setRegion(coordinateRegion, animated: true)
        
        let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        
        self.map!.showsUserLocation = true
        self.map!.showsBuildings = true
        self.map!.addAnnotation(pointAnnotation)
        self.map!.centerCoordinate = coordinate
        self.map!.selectAnnotation(pointAnnotation, animated: true)
         map?.isUserInteractionEnabled = true
        map!.isZoomEnabled = false
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ViewController.doubleTapped(_:)))
        gestureRecognizer.numberOfTapsRequired = 2
        map!.addGestureRecognizer(gestureRecognizer)
       
        
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationManager.location!) { (placemarks, error) in
            if (error != nil){
                //print("error in reverseGeocode")
            }
            if placemarks != nil {
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count>0{
                    let placemark = placemarks![0]
                    if let placemark = placemark as? CLPlacemark {
                        self.currentPlacemark = placemark
                        self.getCurrentTemp(lat: "\(coordinate.latitude)", long: "\(coordinate.longitude)")
                    }
                }
            }
        }
        
    }

    
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}



//current temp work
extension ViewController {
    func getCurrentTemp(lat: String, long: String) {
        WeatherManager.shared.fetchCurrentTemprature(latitude: lat, longitude: long, completion: { (weatherResponse) in
            if let weather = weatherResponse {
                DispatchQueue.main.async { [unowned self] in
                    if let weatherRes = weather as? NSDictionary {
                        if let tempResponse = weatherRes["main"] as? NSDictionary {
                            print(tempResponse)
                            if let currentTemp = tempResponse["temp"] as? NSNumber {
                                var currentTemprature = "\(currentTemp)"
                                let array = currentTemprature.components(separatedBy: ".")
                                if array.count > 0 {
                                    currentTemprature = array[0]
                                    self.displayWeather(temprature: currentTemprature, placemark: self.currentPlacemark!)
                                }
                            }
                        }
                    }
                }
            } else {
                print("error in translation")
            }
        })
    }
    
    func displayWeather(temprature: String, placemark: CLPlacemark) {
        let alertController = UIAlertController(title: "Hey!! Welcome to my weather app", message:
            "Street:  \(placemark.thoroughfare!)\nCity:  \(placemark.subAdministrativeArea!)\nTemprature:  \(temprature)°C", preferredStyle: UIAlertController.Style.alert)
           alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel,handler: nil))
           self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController {
 
    @objc func doubleTapped(_ sender:UITapGestureRecognizer)
    {
       
        print("doubletapped")
        let location = sender.location(in: map!)
        let coordinate = map!.convert(location, toCoordinateFrom: map!)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        map!.addAnnotation(annotation)
        
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { (placemarks, error) in
            if (error != nil){
                //print("error in reverseGeocode")
            }
            if placemarks != nil {
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count>0{
                    let placemark = placemarks![0]
                    if let placemark = placemark as? CLPlacemark {
                        let vc = WeatherInfoViewController()
                        vc.latitude = "\(coordinate.latitude)"
                        vc.longitude = "\(coordinate.longitude)"
                        vc.city = placemark.subAdministrativeArea ?? ""
                        vc.street = placemark.thoroughfare ?? ""
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
        
        
    }

}
