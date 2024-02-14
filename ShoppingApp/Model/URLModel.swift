//
//  URLModel.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 13/02/24.
//

import Foundation


class URLModel {
    var uID : Int?
    var title: String?
    var desc : String?
    var createdAt : Date?
    var longURL : String?
    var shortURL : String?
    var qrImageData : Data?
    var isFav: Bool = false
    
    init(uID: Int? = nil, title: String? = nil, desc: String? = nil, createdAt: Date? = nil, longURL: String? = nil, shortURL: String? = nil, qrImageData: Data? = nil, isFav: Bool) {
        self.uID = uID
        self.title = title
        self.desc = desc
        self.createdAt = createdAt
        self.longURL = longURL
        self.shortURL = shortURL
        self.qrImageData = qrImageData
        self.isFav = isFav
    }
}
