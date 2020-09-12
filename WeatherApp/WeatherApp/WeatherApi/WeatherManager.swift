//
//  StickersManager.swift
//  seiosnativeapp
//
//  Created by bigstep on 09/07/20.
//  Copyright © 2020 bigstep. All rights reserved.
//
import Foundation


class WeatherManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = WeatherManager()
    private let defaults = UserDefaults.standard
    private let weatherApiKey = "83a1b4faa4a339d50db94ed32af26bfd"
    
    override init() {
        super.init()
    }
    func fetchCurrentTemprature(latitude: String, longitude: String, completion: @escaping (_ stickers: Any?) -> Void) {
             var urlParams = [String: String]()
             urlParams["appid"] = weatherApiKey
             urlParams["lat"] = latitude
             urlParams["lon"] = longitude
             urlParams["units"] = "Metric"
             makeRequest(usingTrendingApi: .currentTemprature, urlParams: urlParams) { (results) in
                 guard let results = results else { completion(nil); return }
                 if let data = results as? Any  {
                     completion(data)
                 } else {
                     completion(nil)
                 }
             }
         }
    
    private func makeRequest(usingTrendingApi api: WeatherAPI, urlParams: [String: String], completion: @escaping (_ results: [String: Any]?) -> Void) {
           if var components = URLComponents(string: api.getURL()) {
               components.queryItems = [URLQueryItem]()
               
               for (key, value) in urlParams {
                   components.queryItems!.append(URLQueryItem(name: key, value: value))
               }
               
               
               if let url = components.url {
                   var request = URLRequest(url: url)
                   request.httpMethod = api.getHTTPMethod()
                   
                   
                   let session = URLSession(configuration: .default)
                   let task = session.dataTask(with: request) { (results, response, error) in
                       
                       if let error = error {
                           print(error)
                           completion(nil)
                       } else {
                           if let response = response as? HTTPURLResponse, let results = results {
                               if response.statusCode == 200 || response.statusCode == 201 {
                                   do {
                                       if let resultsDict = try JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] {
                                           completion(resultsDict)
                                       }
                                   } catch {
                                       print(error.localizedDescription)
                                   }
                               }
                           } else {
                               completion(nil)
                           }
                       }
                       
                   }
                   
                   task.resume()
               }
           }
       }
}
