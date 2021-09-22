//
//  SearchViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 19.08.2021.
//

import Foundation
import UIKit
import Parse

class SearchViewController: UIViewController {
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    var recipeArray = [Recipe]()
    var sortedRecipe: [Recipe] = []
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.searchTableView.rowHeight = 100.0
        self.searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")

        checkVegan()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecipe()
        self.searchTableView.rowHeight = 100.0
        self.searchTableView.delegate = self
        self.searchTableView.dataSource = self
        self.mySearchBar.delegate = self
        self.mySearchBar.placeholder = "Введіть назву страви"
        searchTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")
    }

//MARK - Model Manupulation Methods
    
func loadRecipe() {
    let query = PFQuery(className:"Recipe")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
        self.recipeArray = []
        if let error = error {
        print(error.localizedDescription)
        } else if let objects = objects {
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
                    { let newRecipe = Recipe(titleRecipe: titleRecipe, imageRecipe: imageRecipe, shortText: shortText, category: category, date: date, fullText: fullText, vegan: vegan, featured: featured, unicID: unicID)
                        self.recipeArray.append(newRecipe)
                        DispatchQueue.main.async {
                            self.searchTableView.reloadData()
                            self.checkVegan()
                        }
                    }
                }
            }
        }
        
    }
    
    func checkVegan() {
        if defaults.bool(forKey: K.veganSettings) == true {
            sortedRecipe = recipeArray.filter { $0.vegan == true }

            searchTableView.reloadData()
        } else {
            sortedRecipe = recipeArray
            searchTableView.reloadData()
        }
    }
    
    
}

//MARK: - Tableview Datasource Methods

extension SearchViewController: UITableViewDataSource {

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedRecipe.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if(indexPath.row > sortedRecipe.count-1){
            return UITableViewCell()
          }
        else{
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as! RecipeTableViewCell
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.white
    cell.selectedBackgroundView = backgroundView
    
    let recipe = sortedRecipe[indexPath.row]

    cell.RecipeCellLabel.text = recipe.titleRecipe
          
    if let url = URL(string: recipe.imageRecipe) {
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
//MARK: - TableView Delegate Methods
extension SearchViewController: UITableViewDelegate {
 func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var recipe = sortedRecipe[indexPath.row]

    if defaults.bool(forKey: K.veganSettings) == true {
        recipe = sortedRecipe[indexPath.row]
    } else {
        recipe = recipeArray[indexPath.row]
        }
    
    let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
    
    detailVC.objectIdDetail = recipe.unicID
    detailVC.imageDetail = recipe.imageRecipe
    detailVC.detailTitle = recipe.titleRecipe
    detailVC.shortTextDetal = recipe.shortText
    detailVC.dateDetail = recipe.date
    detailVC.fullDetail = recipe.fullText
    detailVC.categoryButtonTitle = recipe.category
    
    navigationController?.pushViewController(detailVC, animated: true)
    
 }
}

//MARK: - Search bar methods

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        let searchedText = searchBar.text?.uppercased()
        
        sortedRecipe = sortedRecipe.filter { $0.titleRecipe.contains(searchedText!) }

        searchTableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadRecipe()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            let searchedText = searchBar.text?.uppercased()
            
            sortedRecipe = sortedRecipe.filter { $0.titleRecipe.contains(searchedText!) }

            searchTableView.reloadData()
        }
    }
}








