//
//  ShopListViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import Foundation
import UIKit
import CoreData
import ChameleonFramework

class ShopListViewController: UIViewController {

    var itemArray = [IngridientCore]()
    
    var secondArray:[SumIndredient] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var sunListTable: UITableView!
    @IBOutlet weak var shopListTableView: UITableView!
    @IBOutlet weak var deleteButtonLabel: MyButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        shopListTableView.dataSource = self
        shopListTableView.delegate = self
        shopListTableView.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")
        sunListTable.dataSource = self
        sunListTable.delegate = self
        sunListTable.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")
        loadItems()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        shopListTableView.dataSource = self
//        shopListTableView.delegate = self
//        shopListTableView.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")
//        loadItems()
        
    }
    
    func loadItems(with request: NSFetchRequest<IngridientCore> = IngridientCore.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }

        shopListTableView.reloadData()
        self.sunListTable.reloadData()
        sumItems()

    }
    
    func sumItems(){
        let keypathExp = NSExpression(forKeyPath: "quanity") // can be any column
        let expression = NSExpression(forFunction: "sum:", arguments: [keypathExp])

        let sumDesc = NSExpressionDescription()
        sumDesc.expression = expression
        sumDesc.name = "sum"
        sumDesc.expressionResultType = .integer32AttributeType

        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "IngridientCore")

        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["title"]
        fetchRequest.propertiesToFetch = ["title", sumDesc]
        fetchRequest.resultType = .dictionaryResultType
        self.secondArray = []
        do {
            let fetchedData = try context.fetch(fetchRequest)
//            print(fetchedData.count)
            for object in fetchedData {
                if let title = object.value(forKey: "title") as? String,
                   let quanity = object.value(forKey: "sum") as? Int
                   {
                    let newIngridient = SumIndredient(title: title, quanity: quanity)
                    self.secondArray.append(newIngridient)

                    DispatchQueue.main.async {
                        self.sunListTable.reloadData()

                    }
                }
            }

            } catch {
                    print("Error fetching data from context \(error)")
                }

        sunListTable.reloadData()
    }

    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.shopListTableView.reloadData()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        var textFieldName = UITextField()
        var textFieldNQuanity = UITextField()
        
        let alert = UIAlertController(title: "Додати товар", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Додати", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert

            
            let newItem = IngridientCore(context: self.context)
            newItem.title = textFieldName.text!
            if let quanityLabel = textFieldNQuanity.text,
            let intValue = Int(quanityLabel) {
            newItem.quanity = Int32(intValue)
            } else {
            print("додано не число")
                }

            newItem.checked = false
            self.itemArray.append(newItem)
            
            self.saveItems()
            self.sumItems()
        }
        

        
        alert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Додати товар"
            textFieldName = nameTextField
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Кількість"
            textFieldNQuanity = alertTextField
            
        }
        
        
        alert.addAction(action)
        
        present(alert, animated: true, completion:{
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
         })
        
//        present(alert, animated: true, completion: nil)
        
    }
    

    @objc func dismissOnTapOutside(){
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        for index in (0 ..< itemArray.count) where itemArray[index].checked == true {
            context.delete(itemArray[index]) 
        }
        
        sender.backgroundColor = UIColor.flatGreen()
        sender.setTitle("Видалено!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //Bring's sender's opacity back up to fully opaque.
            sender.backgroundColor = UIColor.flatRed()
            sender.setTitle("Видалити зі списку", for: .normal)
        }
        
        self.saveItems()
        loadItems()

    }
    

}

extension ShopListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == shopListTableView {
            return itemArray.count
        } else if tableView == sunListTable {
            return secondArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == shopListTableView {
            if(indexPath.row > itemArray.count-1){
                    return UITableViewCell()
                  }
                else{
        let cell = shopListTableView.dequeueReusableCell(withIdentifier: "IngridientTableViewCell", for: indexPath) as! IngridientTableViewCell
        let ingridient = itemArray[indexPath.row]
        cell.ingridientCellLabel?.text = ingridient.title
        cell.ingridientQuanityLabel?.text = String(ingridient.quanity)
        cell.accessoryType = ingridient.checked ? .checkmark : .none
     return cell
                }
        } else if tableView == sunListTable {
            if(indexPath.row > secondArray.count-1){
                    return UITableViewCell()
            }  else{
                let cell = shopListTableView.dequeueReusableCell(withIdentifier: "IngridientTableViewCell", for: indexPath) as! IngridientTableViewCell
                let ingridient = secondArray[indexPath.row]
                cell.ingridientCellLabel?.text = ingridient.title
                cell.ingridientQuanityLabel?.text = String(ingridient.quanity)
                cell.accessoryType = .none
             return cell
            }
    }
        return UITableViewCell()
    }

}

extension ShopListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if  tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }

            itemArray[indexPath.row].checked = !itemArray[indexPath.row].checked
                        
           saveItems()
            
            tableView.deselectRow(at: indexPath, animated: true)

    }
}
