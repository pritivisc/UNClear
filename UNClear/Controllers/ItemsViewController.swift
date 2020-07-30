//
//  MainTableViewController.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/27/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import UIKit
import RealmSwift

class ItemsViewController: UITableViewController {
    
    var items: Results<Item>?
    let realm = try! Realm()
    var selectedList: List? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let currentItem = items?[indexPath.row]
        cell.textLabel?.text = currentItem?.title ?? "Add more tasks to do"
        cell.accessoryType = currentItem?.isChecked ?? false ? .checkmark : .none
        return cell
    }
    
    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    item.isChecked = !item.isChecked
                })
            } catch {
                print("Error while updating check mark: \(error.localizedDescription)")
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - Funtionality
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "What would you like to achieve today?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //print("\(textField.text ?? "Not") Added Successfully")
            if let text = textField.text, let currentList = self.selectedList {
                do {
                    try self.realm.write({
                        let newItem = Item()
                        newItem.title = text
                        currentList.items.append(newItem)
                        self.tableView.reloadData()
                    })
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Task Description"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    func loadItems() {
        items = selectedList?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate methods

extension ItemsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
