//
//  ViewController.swift
//  ShoppingApp
//
//  Created by Abhishek Biswas on 07/02/24.
//

import UIKit
import RealmSwift
import ProgressHUD

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addURLBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var favBtn: UIButton!
    
    private var dataArray : [URLModel] = []
    private var sortedArray : [URLModel] = []
    
    private var selectedDataModel : URLModel?
    private var selectedIndexPath : IndexPath?

    
    override func viewDidLoad() {
        //temp perpose
        ProgressHUD.animate("Fetching All Previous Generated URL")
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(HomeTableViewCell.nib(), forCellReuseIdentifier: HomeTableViewCell.cellId)
        self.addURLBtn.addTarget(self, action: #selector(addAction(_ :)), for: .touchUpInside)
        self.prepForRealmFetch()
        self.favBtn.addTarget(self, action: #selector(favBtnAction(_ :)), for: .touchUpInside)
    }
    
    
    @objc func addAction(_ sender: UIButton){
        let addVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddURLViewController") as? AddURLViewController
        addVC?.modalPresentationStyle = .fullScreen
        addVC?.delegate = self
        self.present(addVC ?? UIViewController(), animated: true, completion: nil)
    }
    
    @objc func favBtnAction(_ sender: UIButton){
        
    }
    
    private func prepForRealmFetch() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let realm = try Realm()
                let allURLModels = realm.objects(URLDBModel.self)
                
                if !allURLModels.isEmpty {
                    var tempDataArray: [URLModel] = []
                    
                    for item in allURLModels {
                        let singleURLModel = URLModel(uID: item.uID, title: item.title, desc: item.desc, createdAt: item.createdAt, longURL: item.longURL, shortURL: item.shortURL, qrImageData: item.qrImageData, isFav: item.isFav)
                        tempDataArray.append(singleURLModel)
                    }
                    
                    DispatchQueue.main.async {
                        ProgressHUD.dismiss()
                        self?.dataArray = tempDataArray
                        self?.tableView.reloadData()
                    }
                } else {
                    ProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        UserDefaults.standard.setValue(0, forKey: "counter")
                    }
                }
            } catch(let err){
                DispatchQueue.main.async {
                    print(err.localizedDescription)
                    ConstantResoures.makeAlert(controller: self, message: "Cannot Fetch Model", title: "Alert!!") {
                        print("UI cannot be Updated")
                    }
                }
            }
        }
    }

}


extension HomeViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let homeCell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.cellId, for: indexPath) as? HomeTableViewCell
        homeCell?.bigURLText.text = self.dataArray[indexPath.row].longURL
        homeCell?.shortURLText.text = self.dataArray[indexPath.row].shortURL
        homeCell?.nameURL.text = self.dataArray[indexPath.row].title
        if (dataArray[indexPath.row].isFav){
            homeCell?.favBtn.setImage(UIImage.init(systemName: "star.fill"), for: .normal)
        }else{
            homeCell?.favBtn.setImage(UIImage.init(systemName: "star"), for: .normal)
        }
        homeCell?.urlDetails = self.dataArray[indexPath.row]
        homeCell?.qrImageView.image = UIImage(data: self.dataArray[indexPath.row].qrImageData ?? Data())
        return homeCell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.selectedDataModel = self.dataArray[indexPath.row]
        self.selectedIndexPath = indexPath
        let showVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowDetailsViewController") as? ShowDetailsViewController
        showVC?.model = self.dataArray[indexPath.row]
        showVC?.modalPresentationStyle = .popover
        showVC?.delegate = self
        self.present(showVC ?? UIViewController(), animated: true, completion: nil)
    }
}

extension HomeViewController: AddURLViewControllerDelegate {
    func updateAndAddURLData(model: URLModel) {
        self.dataArray.append(model)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let realm = try Realm()
                let dbModel = URLDBModel(uID: model.uID ?? 0, title: model.title ?? "", desc: model.desc ?? "", createdAt: model.createdAt ?? Date(), longURL: model.longURL ?? "", shortURL: model.shortURL ?? "", qrImageData: model.qrImageData ?? Data(), isFav: model.isFav)
                try realm.write {
                    realm.add(dbModel, update: .modified)
                }
            } catch {
                print("Error adding URLModel to Realm: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    ConstantResoures.makeAlert(controller: self, message: "Cannot Update DB", title: "Alert!!") {
                        print("DB cannot be Updated")
                    }
                }
            }
        }
    }
}



extension HomeViewController: ShowDetailsViewControllerDelegate {
    func removeModelAndReload(model: URLModel) {
        guard let indexPath = self.selectedIndexPath else {return}
        let dataToBeDeleted = self.dataArray[indexPath.row]
        if (dataToBeDeleted.uID == model.uID){
            self.dataArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }else{
            ConstantResoures.makeAlert(controller: self, message: "Failed to remove URL", title: "Alert!!") {
                print("URL Deleted Failed")
            }
        }
    }
    
    func didDismissDetailsViewController() {
        self.tableView.reloadData()
    }
}

