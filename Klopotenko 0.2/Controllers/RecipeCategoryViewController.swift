//
//  RecipeCategoryViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import Foundation
import UIKit
import Parse

class RecipeCategoryViewController: UIViewController {
    
    @IBOutlet weak var recipeCategoryTableView: UITableView!
    
    var categoryTitle: String?
    var recipes: [Recipe] = []
    var sortedCategoryRecipe: [Recipe] = []
    let defaults = UserDefaults.standard
    
    func loadRecipe() {
        let query = PFQuery(className:"Recipe")
        query.whereKey("category", equalTo: categoryTitle!)
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            self.recipes = []
            if let error = error {
                print(error.localizedDescription)
            } else if let objects = objects {
                print(objects.count)
                for object in objects {
                    if let titleRecipe = object["titleRecipe"] as? String,
                       let imageRecipe = object["imageRecipe"] as? String,
                       let shortText = object["shortText"] as? String,
                       let category = object["category"] as? String,
                       let fullText = object["fullText"] as? String,
                       let vegan = object["vegan"] as? Bool,
                       let date = object["date"] as? String,
                       let featured = object["featured"] as? Bool,
                       let unicID = object.objectId
                       {
                        let newRecipe = Recipe(titleRecipe: titleRecipe, imageRecipe: imageRecipe, shortText: shortText, category: category, date: date, fullText: fullText, vegan: vegan, featured: featured, unicID: unicID)
                        self.recipes.append(newRecipe)
                        
                        DispatchQueue.main.async {
                            self.recipeCategoryTableView.reloadData()
                            self.checkVegan()
                        }
                    }
                }
            }
        }
        
    }
    
    func checkVegan() {
        if defaults.bool(forKey: K.veganSettings) == true {
            sortedCategoryRecipe = recipes.filter { $0.vegan == true }
            recipeCategoryTableView.reloadData()
        } else {
            sortedCategoryRecipe = recipes
            recipeCategoryTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.recipeCategoryTableView.rowHeight = 100.0
        self.recipeCategoryTableView.delegate = self
        recipeCategoryTableView.dataSource = self
        recipeCategoryTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")

        checkVegan()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = categoryTitle
        
        loadRecipe()
        
        self.recipeCategoryTableView.rowHeight = 100.0
        self.recipeCategoryTableView.delegate = self
        recipeCategoryTableView.dataSource = self
        recipeCategoryTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")

    }
}

extension RecipeCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row > sortedCategoryRecipe.count-1){
                return UITableViewCell()
        }  else{
        let cell = recipeCategoryTableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as! RecipeTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
     cell.RecipeCellLabel.text = sortedCategoryRecipe[indexPath.row].titleRecipe
     
        if let url = URL(string: sortedCategoryRecipe[indexPath.row].imageRecipe) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.RecipeCellImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
     return cell
    }
    }
}


extension RecipeCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "GoToRecipe", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToRecipe", let catVC = segue.destination as? DetailViewController {
            if let indexPath = recipeCategoryTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                catVC.imageDetail = self.sortedCategoryRecipe[selectedRow].imageRecipe
                catVC.detailTitle = sortedCategoryRecipe[indexPath.row].titleRecipe
                catVC.shortTextDetal = sortedCategoryRecipe[indexPath.row].shortText
                catVC.dateDetail = sortedCategoryRecipe[indexPath.row].date
                catVC.fullDetail = sortedCategoryRecipe[indexPath.row].fullText
                catVC.categoryButtonTitle = categoryTitle
//                catVC.ingredienstDetail = newRecipes[indexPath.row].Ingredients
            }
        
    }
    
        }
    }
