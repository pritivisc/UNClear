//
//  ListsViewController.swift
//  UNClear
//
//  Created by Pritivi S Chhabria on 7/29/20.
//  Copyright © 2020 Chiffonier Inc. All rights reserved.
//

import UIKit
import CoreData

class ListsViewController: UITableViewController {
    
    var lists = [List]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = lists[indexPath.row].title
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
                let newList = List(context: self.context)
                newList.title = text
                self.lists.append(newList)
                self.saveLists()
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
    
    func loadLists(with request: NSFetchRequest<List> = List.fetchRequest()) {
        do {
            lists = try context.fetch(request)
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    func saveLists() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        tableView.reloadData()
    }
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            let destinationVC = segue.destination as! ItemsViewController
            destinationVC.selectedList = lists[selectedIndexPath.row]
        }
    }
    
}
