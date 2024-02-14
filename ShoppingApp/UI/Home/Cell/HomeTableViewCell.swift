//
//  HomeTableViewCell.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 13/02/24.
//

import UIKit
import RealmSwift

protocol HomeTableViewCellDelegate {
    func updateRealmDB(model: URLModel) -> Void
}


class HomeTableViewCell: UITableViewCell {
    
    public static let cellId = "HomeTableViewCell"
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var shortURLText: UILabel!
    @IBOutlet weak var bigURLText: UILabel!
    @IBOutlet weak var nameURL: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    
    public var urlDetails : URLModel?
    public var delegate : HomeTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.qrImageView.layer.cornerRadius = 10
        self.favBtn.addTarget(self, action: #selector(favAction(_ :)), for: .touchUpInside)
    }
    
    @objc func favAction(_ sender: UIButton){
        guard let model = self.urlDetails else {return}
        if(model.isFav){
            model.isFav = false
            self.favBtn.setImage(UIImage.init(systemName: "star"), for: .normal)
        }else{
            model.isFav = true
            self.favBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        }
        self.updateModelToDb(model)
    }
    
    private func updateModelToDb(_ model: URLModel) {
        DispatchQueue.global(qos: .background).async {
            do {
                let realm = try Realm()
                let allURLModels = realm.objects(URLDBModel.self).filter("uID == %@", model.uID ?? 0)
                
                if let urlModelToUpdate = allURLModels.first {
                    try realm.write {
                        urlModelToUpdate.isFav = model.isFav
                        realm.add(urlModelToUpdate, update: .modified)
                    }
                }
            } catch {
                print("Error in updating the db: \(error)")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    public static func nib() -> UINib {
        return UINib(nibName: "HomeTableViewCell", bundle: nil)
    }
    
}
