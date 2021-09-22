//
//  FavoriteViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import Foundation
import UIKit
import CoreData
import SwipeCellKit

class FavoriteViewController: UIViewController {

    @IBOutlet weak var favTableView: UITableView!
    var recipeArray = [RecipeCore]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Улюблені"
        self.favTableView.dataSource = self
        self.favTableView.delegate = self
        self.favTableView.rowHeight = 100.0
        favTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")
        loadItems()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    func loadItems(with request: NSFetchRequest<RecipeCore> = RecipeCore.fetchRequest()) {
        do {
            recipeArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        favTableView.reloadData()
        
    }
    
    
    

}

extension FavoriteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favTableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as! RecipeTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        cell.selectedBackgroundView = backgroundView
        cell.delegate = self
        let recipe = recipeArray[indexPath.row]
        cell.RecipeCellLabel.text = recipe.title
        if let url = URL(string: recipe.image ?? "https://klopotenko.com/wp-content/uploads/2021/07/yak-vykorystovuvaty-lymon_sitewebukr.jpg") {
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

extension FavoriteViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion

            self.context.delete(self.recipeArray[indexPath.row])
            self.loadItems()
//            self.updateModel(at: indexPath)

        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }

}

extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let recipe = recipeArray[indexPath.row]
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailFavViewController") as! DetailFavViewController
        
        detailVC.imageDetail = recipe.image
        detailVC.detailTitle = recipe.title
        detailVC.shortTextDetal = recipe.shortText
        detailVC.fullDetail = recipe.fullText

        navigationController?.pushViewController(detailVC, animated: true)
        }
}
