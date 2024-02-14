//
//  ConstantResoures.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 14/02/24.
//

import Foundation
import UIKit


class ConstantResoures {
    public static let baseURL: String = "https://urlshort-ud24.onrender.com"
    public static let serviceEndpoint: String = "/api/v1/service"
    public static let shortEndpoint: String = "/shortener"
    
    
    public static func makeAlert(controller : UIViewController?, message: String, title: String, compleation: @escaping(() -> Void)) -> Void {
        DispatchQueue.main.async {
            let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                compleation()
            }))
            if let vc = controller {
                vc.present(alert, animated: true)
            }
        }
    }
}
