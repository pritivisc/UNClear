//
//  ListsViewController.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/29/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ListsViewController: SwipeTableViewController {
    
    var lists: Results<List>?
    @IBOutlet weak var plusBB: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError()
        }
        navBar.barTintColor = UIColor.systemPink
        plusBB.tintColor = UIColor.white
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = lists?[indexPath.row].title ?? "Add more lists"
        cell.backgroundColor = UIColor(hexString: lists?[indexPath.row].bgColor ?? UIColor.white.hexValue())
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        return cell
    }
    
    // MARK: - delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toItems", sender: tableView)
    }
    
    // MARK: - Funtionality
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add List", message: "Enter List Name Below", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text {
                let newList = List()
                newList.title = text
                newList.bgColor = UIColor.randomFlat().hexValue()
                self.save(list: newList)
            }
        }
        alert.addAction(action)
        alert.addTextField { (newTF) in
            newTF.placeholder = "List Name"
            textField = newTF
        }
        present(alert, animated: true)
    }
    
    // MARK: - Data Manipulation Methods
    
    func loadLists() {
        lists = realm.objects(List.self)
        tableView.reloadData()
    }
    
    func save(list: List) {
        do {
            try realm.write({
                realm.add(list)
            })
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write({
                self.realm.delete(self.lists![indexPath.row])
            })
        } catch {
            print(error)
        }
    }
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ItemsViewController
            destinationVC.selectedList = lists?[selectedIndexPath.row]
        }
    }
    
}
