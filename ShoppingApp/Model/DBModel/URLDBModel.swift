//
//  DBModel.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 14/02/24.
//

import Foundation
import RealmSwift

class URLDBModel : Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uID: Int
    @Persisted var title: String
    @Persisted var desc : String
    @Persisted var createdAt : Date
    @Persisted var longURL : String
    @Persisted var shortURL : String
    @Persisted var qrImageData : Data
    @Persisted var isFav: Bool = false
    
    convenience init(uID: Int, title: String, desc: String, createdAt: Date, longURL: String, shortURL: String, qrImageData: Data, isFav: Bool) {
        self.init()
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




