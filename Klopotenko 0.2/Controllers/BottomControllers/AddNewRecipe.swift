//
//  AddNewRecipe.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 20.08.2021.
//

import Foundation
import UIKit
import CoreData

class AddNewRecipe: UIViewController {

    @IBOutlet weak var AddIngridientTableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleTextLabel: UITextField!
    @IBOutlet weak var imageTextLabel: UITextField!
    @IBOutlet weak var shortTextLabel: UITextField!
    @IBOutlet weak var fullTextLabel: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var ingridientArray: [String] = []
    var arrayOfCell:[AddIngridientCell] = []
    var seconArray: [Indredient] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.AddIngridientTableView.rowHeight = 50.0
        AddIngridientTableView.dataSource = self
//        AddIngridientTableView.delegate = self
        AddIngridientTableView.register(UINib(nibName: "AddIngridientCell", bundle: nil), forCellReuseIdentifier: "AddIngridientCell")
    }
    
    @IBAction func plusButtonPressed(_ sender: UIButton) {
        arrayOfCell = []
        K.newRecipeCount += 1
//        let indexPath = IndexPath(row: K.newRecipeCount-1, section: 0)
//        AddIngridientTableView.beginUpdates()
//        AddIngridientTableView.insertRows(at: [indexPath], with: .automatic)
//        AddIngridientTableView.endUpdates()
//           view.endEditing(true)
//        self.AddIngridientTableView.scrollToRow(at: indexPath, at: .top, animated: true)
        tableViewHeight.constant += AddIngridientTableView.rowHeight
        self.view.layoutIfNeeded()
        self.AddIngridientTableView.reloadData()
        print(arrayOfCell.count)
    }
    
    @IBAction func minusButtonPressed(_ sender: UIButton) {
        arrayOfCell = []
        K.newRecipeCount = K.newRecipeCount - K.addRecipeNumber
        tableViewHeight.constant = tableViewHeight.constant - AddIngridientTableView.rowHeight
        self.AddIngridientTableView.reloadData()
//        print(arrayOfCell.count)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        seconArray = []
        
//        for cell in AddIngridientTableView.visibleCells {
//            if let indexPath = AddIngridientTableView.indexPath(for: cell) {
//                decorate(cell, at: indexPath)
//            }
//        }
        arrayOfCell.forEach { cell in
            let title = cell.titleIngridientText.text!
            let quanity = Int(cell.quanityIngridientText.text!)
            let newIngridient = Indredient(title: title, quanity: quanity ?? 0, checked: false)
            seconArray.append(newIngridient)
         }
        print(arrayOfCell.count)
//        print(seconArray)
        checkFav()

        let detailVC = storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.AddIngridientTableView.reloadData()
    }
    
    func checkFav(with request: NSFetchRequest<RecipeCore> = RecipeCore.fetchRequest(), predicate: NSPredicate? = nil) {

        let recipePredicate = NSPredicate(format: "title MATCHES %@", titleTextLabel.text!)
            request.predicate = recipePredicate

        do {
            let arrData = try context.fetch(request)
            if arrData.count > 0 {
                print("Record already exist")
                } else {
                let newFavRecipe = RecipeCore(context: self.context)
                    newFavRecipe.title = titleTextLabel.text
                    newFavRecipe.image = imageTextLabel.text
                    newFavRecipe.shortText = shortTextLabel.text
                    newFavRecipe.fullText = fullTextLabel.text
                    for index in (0 ..< seconArray.count) {
                    let newIngridientFavRecipe = RecipeIngridient(context: self.context)
                    newIngridientFavRecipe.name = seconArray[index].title
                        newIngridientFavRecipe.quanity = Int32(seconArray[index].quanity)
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

extension AddNewRecipe: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AddIngridientTableView.dequeueReusableCell(withIdentifier: "AddIngridientCell", for: indexPath) as! AddIngridientCell
        arrayOfCell.append(cell)
     return cell
    }
    
//    func decorate(_ cell: UITableViewCell, at indexPath: IndexPath) {
//        let cell = AddIngridientTableView.dequeueReusableCell(withIdentifier: "AddIngridientCell", for: indexPath) as! AddIngridientCell
//        arrayOfCell.append(cell)
//    }
//    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return K.newRecipeCount

    }
}

//extension AddNewRecipe: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//}
