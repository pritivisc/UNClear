//
//  MainTableViewController.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/27/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ItemsViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var items: Results<Item>?
    var selectedList: List? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet weak var plusBB: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let col = selectedList?.bgColor {
            guard let navBar = navigationController?.navigationBar else {
                fatalError()
            }
            title = selectedList!.title
            if let navBarColor = UIColor(hexString: col){
                navBar.barTintColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                plusBB.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                searchBar.barTintColor = navBarColor
            }
        }
        
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let currentItem = items?[indexPath.row]
        cell.textLabel?.text = currentItem?.title ?? "Add more tasks to do"
        cell.accessoryType = currentItem?.isChecked ?? false ? .checkmark : .none
        if let current = selectedList {
            cell.backgroundColor = UIColor(hexString: current.bgColor)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(items!.count)))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.tintColor = cell.textLabel?.textColor
        }
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
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write({
                self.realm.delete(self.items![indexPath.row])
            })
        } catch {
            print(error)
        }
    }
    
    func loadItems() {
        items = selectedList?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - UISearchBarDelegate methods

extension ItemsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
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
