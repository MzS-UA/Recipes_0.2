//
//  ViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import UIKit
import Parse

class MainViewController: UIViewController {
    
    @IBOutlet weak var newRecipeTableView: UITableView!
    @IBOutlet weak var recomendRecipeTableView: UITableView!
    
    @IBOutlet weak var newRecipeTableHeight: NSLayoutConstraint!
    @IBOutlet weak var recomendRecipeTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var moreNewButton: MyButton!
    @IBOutlet weak var moreRecomendButton: MyButton!
    
    let defaults = UserDefaults.standard
    
    var recipes: [Recipe] = []
    var sortedNewRecipe: [Recipe] = []
    var recipesFeatured: [Recipe] = []
    var sortedFeatureRecipe: [Recipe] = []

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.newRecipeTableView.rowHeight = 100.0
        self.newRecipeTableView.delegate = self
        self.newRecipeTableView.dataSource = self
        newRecipeTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")

        self.recomendRecipeTableView.rowHeight = 100.0
        self.recomendRecipeTableView.delegate = self
        recomendRecipeTableView.dataSource = self
        recomendRecipeTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")

        checkVegan()
        
        self.moreNewButton.isEnabled = true
        self.moreNewButton.setTitle("Завантажити ще", for: .normal)
        self.moreNewButton.alpha = 1
        
        self.moreRecomendButton.isEnabled = true
        self.moreRecomendButton.setTitle("Завантажити ще", for: .normal)
        self.moreRecomendButton.alpha = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecipe()
    }
    
    func loadRecipe() {
        let query = PFQuery(className:"Recipe")
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            self.recipes = []
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
                       {
                        let newRecipe = Recipe(titleRecipe: titleRecipe, imageRecipe: imageRecipe, shortText: shortText, category: category, date: date, fullText: fullText, vegan: vegan, featured: featured, unicID: unicID)
                        self.recipes.append(newRecipe)
                        DispatchQueue.main.async {
                            self.newRecipeTableView.reloadData()
                            self.checkFeatured()
                            self.checkVegan()
                        }
                    }
                }
            }
        }
        
    }
    
    func checkVegan() {
        if defaults.bool(forKey: K.veganSettings) == true {
            sortedNewRecipe = recipes.filter { $0.vegan == true }
            sortedFeatureRecipe = recipesFeatured.filter { $0.vegan == true }

            newRecipeTableView.reloadData()
            recomendRecipeTableView.reloadData()
        } else {
            sortedNewRecipe = recipes
            sortedFeatureRecipe = recipesFeatured
            newRecipeTableView.reloadData()
            recomendRecipeTableView.reloadData()
        }
    }
    
    func checkFeatured() {
        recipesFeatured = recipes.filter { $0.featured == true }
    }
    
    
    // MARK: Category Button
    
    @IBAction func buttonCategoryPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "GoToGategory", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToGategory" {
            let destinationVC = segue.destination as! RecipeCategoryViewController
            if let button = sender as? UIButton {
                destinationVC.categoryTitle = button.title(for: .normal)
            }
        }
    }
    
    // MARK: Add more Recipe Button
    
    @IBAction func moreNewButtonPressed(_ sender: UIButton) {
        if K.newRecipeCount < sortedNewRecipe.count {
            K.newRecipeCount = K.newRecipeCount + K.addRecipeNumber
            self.newRecipeTableView.reloadData()
        } else {
            K.newRecipeCount = sortedNewRecipe.count
            self.moreNewButton.isEnabled = false
            self.moreNewButton.alpha = 0.4
            self.moreNewButton.setTitle("На цьому все", for: .normal)
            self.newRecipeTableView.reloadData()
        }
        
    }
    
    @IBAction func moreRecomendButtonPressed(_ sender: UIButton) {
        
        if K.recomendRecipeCount < sortedFeatureRecipe.count {
            K.recomendRecipeCount = K.recomendRecipeCount + K.addRecipeNumber
            self.recomendRecipeTableView.reloadData() }
        else {
            K.recomendRecipeCount = sortedFeatureRecipe.count
            self.moreRecomendButton.isEnabled = false
            self.moreRecomendButton.alpha = 0.4
            self.moreRecomendButton.setTitle("На цьому все", for: .normal)
            self.recomendRecipeTableView.reloadData()
        }
    }
    
    
}

// MARK: Table Data Source

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == newRecipeTableView {
            newRecipeTableHeight.constant = newRecipeTableView.rowHeight * CGFloat(K.newRecipeCount)
            self.view.layoutIfNeeded()
            return K.newRecipeCount
           
        } else if tableView == recomendRecipeTableView {
            recomendRecipeTableHeight.constant = recomendRecipeTableView.rowHeight * CGFloat(K.recomendRecipeCount)
            self.view.layoutIfNeeded()
            return K.recomendRecipeCount
        }
        return 0
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == newRecipeTableView {
            if(indexPath.row > sortedNewRecipe.count-1){
                    return UITableViewCell()
                  }
                else{
            let cell = newRecipeTableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as! RecipeTableViewCell
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell.selectedBackgroundView = backgroundView
            cell.RecipeCellLabel.text = sortedNewRecipe[indexPath.row].titleRecipe
                  
                    if let url = URL(string: sortedNewRecipe[indexPath.row].imageRecipe) {
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
        
        } else if tableView == recomendRecipeTableView {
            if(indexPath.row > sortedFeatureRecipe.count-1){
                    return UITableViewCell()
            }  else{
            let cell = recomendRecipeTableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as! RecipeTableViewCell
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.white
            cell.selectedBackgroundView = backgroundView
         cell.RecipeCellLabel.text = sortedFeatureRecipe[indexPath.row].titleRecipe
            if let url = URL(string: sortedFeatureRecipe[indexPath.row].imageRecipe) {
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
        return UITableViewCell()
    }

}

// MARK: Table Data Delegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == newRecipeTableView {
        
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.objectIdDetail = sortedNewRecipe[indexPath.row].unicID
        detailVC.imageDetail = sortedNewRecipe[indexPath.row].imageRecipe
        detailVC.detailTitle = sortedNewRecipe[indexPath.row].titleRecipe
        detailVC.shortTextDetal = sortedNewRecipe[indexPath.row].shortText
        detailVC.dateDetail = sortedNewRecipe[indexPath.row].date
        detailVC.fullDetail = sortedNewRecipe[indexPath.row].fullText
        detailVC.categoryButtonTitle = sortedNewRecipe[indexPath.row].category
        
        navigationController?.pushViewController(detailVC, animated: true)
        } else if tableView == recomendRecipeTableView {
            let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            detailVC.objectIdDetail = sortedFeatureRecipe[indexPath.row].unicID
            detailVC.imageDetail = sortedFeatureRecipe[indexPath.row].imageRecipe
            detailVC.detailTitle = sortedFeatureRecipe[indexPath.row].titleRecipe
            detailVC.shortTextDetal = sortedFeatureRecipe[indexPath.row].shortText
            detailVC.dateDetail = sortedFeatureRecipe[indexPath.row].date
            detailVC.fullDetail = sortedFeatureRecipe[indexPath.row].fullText
            detailVC.categoryButtonTitle = sortedFeatureRecipe[indexPath.row].category
//            detailVC.ingredienstDetail = sortedFeatureRecipe[indexPath.row].Ingredients
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

