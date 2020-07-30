//
//  ListsViewController.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/29/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import UIKit
import RealmSwift

class ListsViewController: UITableViewController {
    
    var lists: Results<List>?
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = lists?[indexPath.row].title ?? "Add more lists"
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
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ItemsViewController
            destinationVC.selectedList = lists?[selectedIndexPath.row]
        }
    }
    
}
