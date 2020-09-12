//
//  WeatherInfoViewController.swift
//  WeatherApp
//
//  Created by bigstep on 12/09/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class WeatherInfoViewController: UIViewController {
    var cityLabel: UILabel?
    var streetLabel: UILabel?
    var weatherLabel: UILabel?
    var city = ""
    var  street = ""
    var weather = ""
    var latitude = ""
    var longitude = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        cityLabel = UILabel()
        cityLabel?.backgroundColor = .white
        cityLabel?.textColor = .black
        view.addSubview(cityLabel!)
        cityLabel?.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            cityLabel?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        } else {
            cityLabel?.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 100).isActive = true
        }
        cityLabel?.leftAnchor.constraint(equalTo: self.view!.leftAnchor).isActive = true
        cityLabel?.rightAnchor.constraint(equalTo: self.view!.rightAnchor).isActive = true
        cityLabel?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        cityLabel?.textAlignment = .center
        
        streetLabel = UILabel()
        streetLabel?.backgroundColor = .white
        streetLabel?.textColor = .black
        view.addSubview(streetLabel!)
        streetLabel?.translatesAutoresizingMaskIntoConstraints = false
        streetLabel?.topAnchor.constraint(equalTo: self.cityLabel!.bottomAnchor, constant: 3).isActive = true
        streetLabel?.leftAnchor.constraint(equalTo: self.view!.leftAnchor).isActive = true
        streetLabel?.rightAnchor.constraint(equalTo: self.view!.rightAnchor).isActive = true
        streetLabel?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        streetLabel?.textAlignment = .center
        
        weatherLabel = UILabel()
        weatherLabel?.backgroundColor = .white
        weatherLabel?.textColor = .black
        view.addSubview(weatherLabel!)
        weatherLabel?.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel?.topAnchor.constraint(equalTo: self.streetLabel!.bottomAnchor, constant: 3).isActive = true
        weatherLabel?.leftAnchor.constraint(equalTo: self.view!.leftAnchor).isActive = true
        weatherLabel?.rightAnchor.constraint(equalTo: self.view!.rightAnchor).isActive = true
        weatherLabel?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        weatherLabel?.textAlignment = .center
        weatherLabel?.text = "Fetching data. Please wait...."
        
        self.getCurrentTemp(lat: latitude, long: longitude)
        
    }
    
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
                                    self.cityLabel?.text = "City: \(self.city)"
                                    self.streetLabel?.text = "Street: \(self.street)"
                                    self.weatherLabel?.text = "Temprature: \(currentTemprature)°C"
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
}
