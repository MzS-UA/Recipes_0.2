//
//  DetailViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import Foundation
import UIKit
import CoreData
import Parse

class DetailViewController: UIViewController {
    

    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var detailDateLabel: UILabel!
    @IBOutlet weak var detailButtonLabel: UIButton!
    @IBOutlet weak var detailImage: UIImageView!
    @IBOutlet weak var detailShortTextLabel: UILabel!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var detailFullText: UILabel!
    @IBOutlet weak var addToShopingListLabel: UIButton!
    
    var objectIdDetail: String?
    var detailTitle: String?
    var imageDetail: String?
    var shortTextDetal: String?
    var dateDetail: String?
    var fullDetail: String?
    var categoryButtonTitle: String?
    var ingredienstDetail: [Indredient] = []
    var objectNumber: String?
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var itemArray = [IngridientCore]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadIngridient()
        self.detailTableView.rowHeight = 50.0
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailTableView.rowHeight = 50.0
        detailTableView.dataSource = self
        detailTableView.delegate = self
        detailTableView.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")
        
        detailTitleLabel.text = detailTitle
        detailDateLabel.text = dateDetail
        detailButtonLabel.setTitle(categoryButtonTitle, for: .normal)
        detailShortTextLabel.text = shortTextDetal
        detailFullText.text = fullDetail
        loadIngridient()
        
        
        if let url = URL(string: imageDetail ?? "https://klopotenko.com/wp-content/uploads/2021/07/yak-vykorystovuvaty-lymon_sitewebukr.jpg") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self.detailImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
    
    
    func loadIngridient() {
        let query = PFQuery(className:"Ingridients")
        query.whereKey("recipe", equalTo: PFObject(withoutDataWithClassName: "Recipe", objectId: objectIdDetail))
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            self.ingredienstDetail = []
            if let error = error {
                print(error.localizedDescription)
            } else if let objects = objects {
                for object in objects {
                    if let title = object["name"] as? String,
                       let checked = object["checked"] as? Bool,
                       let quanity = object["quanity"] as? Int
                       {
                        let newIngridient = Indredient(title: title, quanity: quanity, checked: checked)
                        self.ingredienstDetail.append(newIngridient)
                        
                        DispatchQueue.main.async {
                            self.detailTableView.reloadData()

                        }
                    }
                }
            }
        }
        
    }

    @IBAction func buttonCategoryPressed(_ sender: UIButton) {
        let buttonTitle = sender.title(for: .normal)
        let gotoVC = storyboard?.instantiateViewController(withIdentifier: "RecipeCategoryViewController") as! RecipeCategoryViewController
        gotoVC.categoryTitle = buttonTitle
        navigationController?.pushViewController(gotoVC, animated: true)
    }
    
  

    
    @IBAction func addToShopingListPressed(_ sender: UIButton) {
       

        
        for index in (0 ..< ingredienstDetail.count) where ingredienstDetail[index].checked == true {
            let newIngredient = IngridientCore(context: self.context)
            newIngredient.title = ingredienstDetail[index].title
            newIngredient.quanity = Int32(ingredienstDetail[index].quanity)
            newIngredient.checked = false
            ingredienstDetail[index].checked = false

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
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.detailTableView.reloadData()
    }
    

    @IBAction func favoritePressed(_ sender: UIBarButtonItem) {
        self.checkFav()

    }
    
    func checkFav(with request: NSFetchRequest<RecipeCore> = RecipeCore.fetchRequest(), predicate: NSPredicate? = nil) {

        let recipePredicate = NSPredicate(format: "title MATCHES %@", detailTitle!)
            request.predicate = recipePredicate

        do {
            let arrData = try context.fetch(request)
            if arrData.count > 0 {
                print("Record already exist")
                } else {
                let newFavRecipe = RecipeCore(context: self.context)
                    newFavRecipe.title = detailTitle
                    newFavRecipe.image = imageDetail
                    newFavRecipe.shortText = detailShortTextLabel.text
                    newFavRecipe.fullText = detailFullText.text
                    for index in (0 ..< ingredienstDetail.count) {
                    let newIngridientFavRecipe = RecipeIngridient(context: self.context)
                    newIngridientFavRecipe.name = ingredienstDetail[index].title
                        newIngridientFavRecipe.quanity = Int32(ingredienstDetail[index].quanity)
                    newIngridientFavRecipe.chech = false
                    newIngridientFavRecipe.parent = newFavRecipe
                    }
                    self.saveItems()
                }

        } catch {
            print("Error fetching data from context \(error)")
        }

    }
    
}

extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailTableView.dequeueReusableCell(withIdentifier: "IngridientTableViewCell", for: indexPath)
            as! IngridientTableViewCell
        let ingridient = ingredienstDetail[indexPath.row]
        cell.ingridientCellLabel.text = ingridient.title
        cell.ingridientQuanityLabel.text = String(ingridient.quanity)
        cell.accessoryType = ingridient.checked ? .checkmark : .none
        
        
     return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewHeightConstraint.constant = detailTableView.rowHeight * CGFloat(ingredienstDetail.count)
        return ingredienstDetail.count
    }
}

extension DetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        ingredienstDetail[indexPath.row].checked = !ingredienstDetail[indexPath.row].checked

        
       saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
