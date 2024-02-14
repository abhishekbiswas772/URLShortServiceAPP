//
//  APICaller.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 07/02/24.
//

import Foundation
import UIKit

@frozen
public enum APIMethod: String {
    case get
    case post
}

final class APICaller {
    public static let shared = APICaller()

    func genericAPICaller(withURL url: String, withAPIMethods methods: String, body: [String: Any], completion: @escaping (([String: Any]?) -> Void)) {
        guard let request = self.makeRequest(url: url, method: methods, body: body) else {
            completion(nil)
            return
        }
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    completion(json)
                } catch {
                    print("JSON error: \(error.localizedDescription)")
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }

    private func makeRequest(url: String, method: String, body: [String: Any]) -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.uppercased()
        if !body.isEmpty {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error encoding JSON: \(error.localizedDescription)")
                return nil
            }
        }
        
        return request
    }
}
