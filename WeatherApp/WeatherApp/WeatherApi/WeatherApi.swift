//
//  WeatherApi.swift
//  WeatherApp
//
//  Created by bigstep on 12/09/20.
//  Copyright © 2020 bigstep. All rights reserved.
//

import Foundation

enum WeatherAPI {
    case currentTemprature
    func getURL() -> String {
        var urlString = ""
        switch self {
        case .currentTemprature:
            urlString = "https://api.openweathermap.org/data/2.5/weather"
        }
        return urlString
    }
    
    func getHTTPMethod() -> String {
        return "GET"
    }
}
