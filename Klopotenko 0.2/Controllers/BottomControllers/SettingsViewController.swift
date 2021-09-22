//
//  SettingsViewController.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var saveButtonLabel: MyButton!
    @IBOutlet weak var settingsTableView: UITableView!
    
    var settingsArray: [MySettings] =
    [
        MySettings(name: K.veganSettings, check: false),
        MySettings(name: K.noSugarSettings, check: false)
    ]
    let defaults = UserDefaults.standard
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingsTableView.delegate = self
        self.settingsTableView.dataSource = self
        settingsTableView.register(UINib(nibName: "IngridientTableViewCell", bundle: nil), forCellReuseIdentifier: "IngridientTableViewCell")

        settingsArray = [
        
        MySettings(name: K.veganSettings, check: defaults.bool(forKey: K.veganSettings)),
        MySettings(name: K.noSugarSettings, check: defaults.bool(forKey: K.noSugarSettings))
        ]

    }


    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        for index in (0 ..< settingsArray.count) where settingsArray[index].check == true {
            self.defaults.setValue(true, forKey: settingsArray[index].name)
        }
        for index in (0 ..< settingsArray.count) where settingsArray[index].check == false {
            self.defaults.setValue(false, forKey: settingsArray[index].name)
        }
        
        sender.backgroundColor = .systemGreen
        sender.setTitle("Збережено!", for: .normal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //Bring's sender's opacity back up to fully opaque.
            sender.backgroundColor = .systemRed
            sender.setTitle("Зберегти", for: .normal)
        }
        
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTableView.dequeueReusableCell(withIdentifier: "IngridientTableViewCell", for: indexPath) as! IngridientTableViewCell
        
        cell.ingridientCellLabel.text = settingsArray[indexPath.row].name
        
        cell.accessoryType = settingsArray[indexPath.row].check ? .checkmark : .none
     return cell
    }
    

}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }

        settingsArray[indexPath.row].check = !settingsArray[indexPath.row].check
            
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
