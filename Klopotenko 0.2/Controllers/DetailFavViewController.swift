//
//  DetailFavViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 16.08.2021.
//

import Foundation
import UIKit
import CoreData

class DetailFavViewController: UIViewController {
    @IBOutlet weak var detailFavTitle: UILabel!
    @IBOutlet weak var detailFavImage: UIImageView!
    @IBOutlet weak var detailFavShortText: UILabel!
    @IBOutlet weak var detailFavTableView: UITableView!
    @IBOutlet weak var detailFavFullText: UILabel!
    @IBOutlet weak var addFavButton: UIButton!
    @IBOutlet weak var favTableHeight: NSLayoutConstraint!
    

    var detailTitle: String?
    var imageDetail: String?
    var shortTextDetal: String?
    var dateDetail: String?
    var fullDetail: String?
    
    var ingridientArray = [RecipeIngridient]()
    var itemArray = [IngridientCore]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.detailFavTableView.rowHeight = 50.0
        detailFavTableView.dataSource = self
        detailFavTableView.delegate = self
        detailFavTableView.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")
        
        
        detailFavTitle.text = detailTitle
        detailFavShortText.text = shortTextDetal
        detailFavFullText.text = fullDetail
        
        
        if let url = URL(string: imageDetail ?? "https://klopotenko.com/wp-content/uploads/2021/07/yak-vykorystovuvaty-lymon_sitewebukr.jpg") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.detailFavImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        loadIngridient()
        
    }
    
    
    func loadIngridient(with request: NSFetchRequest<RecipeIngridient> = RecipeIngridient.fetchRequest(), predicate: NSPredicate? = nil) {

        let recipePredicate = NSPredicate(format: "parent.title MATCHES %@", detailTitle!)
            request.predicate = recipePredicate

        do {
            ingridientArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }

        detailFavTableView.reloadData()

    }
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.detailFavTableView.reloadData()
    }
    
    @IBAction func addToShopingFromFav(_ sender: UIButton) {
        
        for index in (0 ..< ingridientArray.count) where ingridientArray[index].chech == true {
            let newIngredient = IngridientCore(context: self.context)
            newIngredient.title = ingridientArray[index].name
            newIngredient.quanity = Int32(ingridientArray[index].quanity)
            newIngredient.checked = false
            ingridientArray[index].chech = false

        }
        
        self.saveItems()
        
        sender.backgroundColor = .systemGreen
        sender.setTitle("Додано!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //Bring's sender's opacity back up to fully opaque.
            sender.backgroundColor = .systemRed
            sender.setTitle("Додати до покупок", for: .normal)
        }
    }
    
}

extension DetailFavViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailFavTableView.dequeueReusableCell(withIdentifier: "IngridientTableViewCell", for: indexPath)
            as! IngridientTableViewCell
        let ingridient = ingridientArray[indexPath.row]
        cell.ingridientCellLabel.text = ingridient.name
        cell.ingridientQuanityLabel.text = String(ingridient.quanity)
        cell.accessoryType = ingridient.chech ? .checkmark : .none
        
        
     return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favTableHeight.constant = detailFavTableView.rowHeight * CGFloat(ingridientArray.count)
        return ingridientArray.count
    }
    
}

extension DetailFavViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        ingridientArray[indexPath.row].chech = !ingridientArray[indexPath.row].chech

        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
