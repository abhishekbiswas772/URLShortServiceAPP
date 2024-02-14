//
//  AddURLViewController.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 14/02/24.
//

import UIKit
import QRCode
import ProgressHUD

protocol AddURLViewControllerDelegate {
    func updateAndAddURLData(model: URLModel) -> Void
}

class AddURLViewController: UIViewController {
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var descText: UITextField!
    @IBOutlet weak var addBtn: UIButton!

    
    public var delegate : AddURLViewControllerDelegate?
    private var shortURL : String?
    private var isFav : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBtn.addTarget(self, action: #selector(makeShortURL(_ :)), for: .touchUpInside)
        self.backBtn.addTarget(self, action: #selector(backAction(_ :)), for: .touchUpInside)
        self.favBtn.addTarget(self, action: #selector(favAction(_ :)), for: .touchUpInside)
    }
    
    
    @objc func backAction(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func favAction(_ sender: UIButton){
        if (isFav){
            self.isFav = false
            self.favBtn.setImage(UIImage.init(systemName: "star"), for: .normal)
        }else{
            self.isFav = true
            self.favBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        }
    }
    
    @objc func makeShortURL(_ sender : UIButton){
        ProgressHUD.animate("Genrating Short URL & QR")
        guard let uText = self.urlText.text,
              let tText = self.titleText.text,
              let dText = self.descText.text
        else {return}
        
        if (!uText.isEmpty && !tText.isEmpty && !dText.isEmpty){
            self.makeModelAndCallAPI(uText, tText, dText)
        }else{
            ConstantResoures.makeAlert(controller: self, message: "Please Check The Fields", title: "Alert!") {
                print("Errror Happened")
            }
        }
    }
    
    private func makeModelAndCallAPI(_ urlText: String, _ titleText: String, _ descText: String) -> Void {
        let finalURL: String = ConstantResoures.baseURL + ConstantResoures.serviceEndpoint + ConstantResoures.shortEndpoint
        let apiBody : [String: Any] = [
            "url" : urlText
        ]
        APICaller.shared.genericAPICaller(withURL: finalURL, withAPIMethods: APIMethod.post.rawValue, body: apiBody) { response in
            guard let response = response else {return}
            if let status = response["status"] as? Bool,
                let shortURL = response["short_url"] as? String {
                if (status){
                    DispatchQueue.main.async {
                        self.shortURL = shortURL
                        self.saveModelAndGenQR(self.shortURL ?? "", titleText, descText, urlText)
                    }
                }else{
                    ConstantResoures.makeAlert(controller: self, message: "Please Check The URL", title: "Alert!") {
                        print("Errror Happened")
                    }
                }
            }
        }
    }
    
    
    func saveModelAndGenQR(_ shortURL: String, _ titleText: String, _ descText: String, _ urlText: String){
        guard let shortURL = self.shortURL else {return}
        if (!shortURL.isEmpty){
            let doc = QRCode.Document(utf8String: shortURL, errorCorrection: .high)
            let genImage = doc.uiImage(CGSize(width: 100, height: 100))
            var counter : Int = UserDefaults.standard.integer(forKey: "counter")
            DispatchQueue.main.async {
                counter += 1
                let urlModel : URLModel = URLModel(uID: counter, title: titleText, desc: descText, createdAt: Date(), longURL: urlText, shortURL: shortURL, qrImageData: genImage?.pngData(), isFav: self.isFav)
                ProgressHUD.dismiss()
                self.dismiss(animated: true) {
                    UserDefaults.standard.setValue(counter, forKey: "counter")
                    self.delegate?.updateAndAddURLData(model: urlModel)
                }
            }
        }else{
            ConstantResoures.makeAlert(controller: self, message: "Please Check The URL", title: "Alert!") {
                print("Errror Happened")
            }
        }
    }
    

}
