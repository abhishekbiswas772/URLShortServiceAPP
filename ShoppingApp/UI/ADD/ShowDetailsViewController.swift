//
//  ShowDetailsViewController.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 14/02/24.
//

import UIKit
import QRCode
import ProgressHUD
import RealmSwift

protocol ShowDetailsViewControllerDelegate: AnyObject {
    func didDismissDetailsViewController()
    func removeModelAndReload(model: URLModel)
}

class ShowDetailsViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var copyQr: UIButton!
    @IBOutlet weak var downloadQR: UIButton!
    @IBOutlet weak var shareQR: UIButton!
    @IBOutlet weak var longURL: UILabel!
    @IBOutlet weak var shortURL: UILabel!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descText: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var stackViewLabel: UIStackView!
    @IBOutlet weak var stackViewLabel2: UIStackView!
    @IBOutlet weak var stackVW1: UIView!
    @IBOutlet weak var stackVW2: UIView!
    @IBOutlet weak var shortBtnCopy: UIButton!
    @IBOutlet weak var longBtnCopy: UIButton!
    @IBOutlet weak var shortShareBtn: UIButton!
    @IBOutlet weak var longShareBtn: UIButton!
    
    public var model : URLModel?
    public weak var delegate: ShowDetailsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepForSetup()
        self.favBtn.addTarget(self, action: #selector(favAction(_ :)), for: .touchUpInside)
        self.copyQr.addTarget(self, action: #selector(copyQrCodeAction(_ :)), for: .touchUpInside)
        self.shortBtnCopy.addTarget(self, action: #selector(copyQrCodeAction(_ :)), for: .touchUpInside)
        self.longBtnCopy.addTarget(self, action: #selector(longBtnCopyAction(_ :)), for: .touchUpInside)
        self.shareQR.addTarget(self, action: #selector(shareQRAction(_ :)), for: .touchUpInside)
        self.shortShareBtn.addTarget(self, action: #selector(shareQRAction(_ :)), for: .touchUpInside)
        self.longShareBtn.addTarget(self, action: #selector(longBtnshareQRAction(_ :)), for: .touchUpInside)
        self.downloadQR.addTarget(self, action: #selector(saveQRAction(_ :)), for: .touchUpInside)
        self.deleteBtn.addTarget(self, action: #selector(removeURL(_ :)), for: .touchUpInside)
    }
    
    @objc func copyQrCodeAction(_ sender: UIButton){
        self.utilyCopyFuncs(targetText: model?.shortURL ?? "")
    }
    
    @objc func longBtnCopyAction(_ sender: UIButton){
        self.utilyCopyFuncs(targetText: model?.longURL ?? "")
    }
    
    @objc func shareQRAction(_ sender: UIButton){
        self.utilityShareFuncs(targetText: model?.shortURL ?? "")
    }
    
    @objc func longBtnshareQRAction(_ sender: UIButton){
        self.utilityShareFuncs(targetText: model?.longURL ?? "")
    }
    
    @objc func saveQRAction(_ sender: UIButton){
        guard let imgData = model?.qrImageData,
              let uiImage = UIImage(data: imgData) else {return}
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        ConstantResoures.makeAlert(controller: self, message: "QR Saved in photo library", title: "Alert!") {
            print("QR is saved to Photo Lib")
        }
    }
    
    @objc func removeURL(_ sender: UIButton){
        DispatchQueue.global(qos: .background).async {
            do {
                ProgressHUD.animate("Removing the URL")
                guard let model = self.model else {return}
                let realm = try Realm()
                let allURLModels = realm.objects(URLDBModel.self).filter("uID == %@", model.uID ?? 0)
                try realm.write {
                    realm.delete(allURLModels)
                }
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate?.removeModelAndReload(model: model)
                    }
                }
            } catch {
                print("Error in deleting from the db: \(error)")
                ConstantResoures.makeAlert(controller: self, message: "Failed To Delete the URL", title: "Alert!!") {
                    print("URL Deleted")
                }
            }
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
            }
        }
    }
    
    private func utilyCopyFuncs(targetText : String) {
        UIPasteboard.general.string = model?.shortURL ?? ""
        ConstantResoures.makeAlert(controller: self, message: "URL Copied", title: "Alert!") {
            print("URL Copied")
        }
    }
    
    private func utilityShareFuncs(targetText: String){
        let linkToShare = [targetText]
        let activityController = UIActivityViewController(activityItems: linkToShare, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    private func prepForSetup() {
        ProgressHUD.animate("Loading URL")
        self.stackVW1.layer.cornerRadius = 15
        self.stackVW2.layer.cornerRadius = 15
        self.stackVW1.backgroundColor = .lightGray
        self.stackVW2.backgroundColor = .lightGray
        guard let model = model else {return}
        if(model.isFav){
            self.favBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        }else{
            self.favBtn.setImage(UIImage.init(systemName: "star"), for: .normal)
        }
        let doc = QRCode.Document(utf8String: model.shortURL ?? "", errorCorrection: .high)
        let genImage = doc.uiImage(CGSize(width: 200, height: 200))
        DispatchQueue.main.async {
            self.qrImageView.layer.cornerRadius = 10
            self.qrImageView.clipsToBounds = true
            self.qrImageView.image = UIImage(data: genImage?.pngData() ?? Data())
        }
        self.titleText.text = model.title ?? ""
        self.descText.text = model.desc ?? ""
        self.nameLabel.text = model.title ?? ""
        self.longURL.text = model.longURL ?? ""
        self.shortURL.text = model.shortURL ?? ""
        
        var dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE.MMM.d.yyyy"
        let formattedDate : String = dateFormatter.string(from: model.createdAt ?? Date())
        self.createdDate.text = formattedDate
        ProgressHUD.dismiss()
    }
    
    
    @objc func favAction(_ sender: UIButton){
        guard let model = model else {return}
        if (model.isFav) {
            model.isFav = false
            self.favBtn.setImage(UIImage.init(systemName: "star"), for: .normal)
        }else{
            model.isFav = true
            self.favBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        }
        delegate?.didDismissDetailsViewController()
        self.saveUpdatedDB(model)
    }
    
    private func saveUpdatedDB(_ model: URLModel){
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
    
}
