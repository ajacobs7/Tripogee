//
//  GooglePlacesRequest.swift
//  Tripogee
//
//  Created by Austin Jacobs on 3/2/17.
//  Copyright © 2017 Austin Jacobs. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GooglePlacesRequest {

    func getCities(for search: String, with completion: @escaping ([String]) -> Void){
        let api_search = search.replacingOccurrences(of: " ", with: "+")
        let requestString = "\(Constants.URLPrefix)/autocomplete/json?input=\(api_search)&types=(cities)\(Constants.postfix)"
        let url = URL(string: requestString)
    
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                let places = json?["predictions"] as! [[String : Any]]
                var matches: [String] = []
                for place in places {
                    if let name = place["description"] as? String {
                        matches.append(name)
                    }
                }
                DispatchQueue.main.async {
                    completion(matches)
                }
            } catch {
                print("JSON error")
            }
        }
        task.resume()
    }

    func getPOI(for city: String, with completion: @escaping ([[String: Any]]) -> Void) {
        let api_search = city.replacingOccurrences(of: " ", with: "+")
        let requestString = "\(Constants.URLPrefix)/textsearch/json?query=\(api_search)+point+of+interest\(Constants.postfix)"
        let url = URL(string: requestString)
    
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
                if json?["status"] as! String == "OK" {
                    let matches = json?["results"] as? [[String : Any]]
                    DispatchQueue.main.async {
                        completion(matches!)
                    }
                }
            } catch {
                print("JSON error")
            }
        }
        task.resume()
    }
    
    func getImage(for reference: String, with width: Int, using completion: @escaping (Data?) -> Void) {
        let request = "\(Constants.URLPrefix)/photo?maxwidth=\(width)&photoreference=\(reference)\(Constants.postfix)"
        let url = URL(string: request)
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            DispatchQueue.main.async {
                completion(data)
            }
        }
        task.resume()
    }

    private struct Constants {
        static let key = "AIzaSyB2vmrieKPBL8ir7cU9XJMAjzFxITIYIhQ"
        static let postfix = "&language=en&key=\(key)"
        static let URLPrefix = "https://maps.googleapis.com/maps/api/place"
    }

}
