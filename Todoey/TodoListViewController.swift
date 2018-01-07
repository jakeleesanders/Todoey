//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jake Sanders on 1/6/18.
//  Copyright © 2018 Jake Sanders. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    // Persistent storage
    let defaults = UserDefaults.standard

    /*
    ** Array of items in the todo list
    ** Note that the initial values below are only retained if
    ** itemArray has not yet been saved in persistent storage
    */
    var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]
    
    // Key for accessing itemArray in persistent storage
    let itemArrayKey = "TodoListArray"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // If itemArray has been saved in persistent storage, then load it
        if let items = defaults.array(forKey: itemArrayKey) as? [String] {
            itemArray = items
        }
    }

    //MARK: Tableview Datasource Methods
    
    // Returns the total number of rows in our table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    // Loads the contents of a cell (row)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Toggle checkmark
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        // Deselect so the row doesn't remain highlighted
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen once the user clicks the Add Item button on our UIAlert

            // Add new item to array
            self.itemArray.append(textField.text!)
            
            // Save itemArray in persistent storage
            self.defaults.set(self.itemArray, forKey: self.itemArrayKey)
            
            // Redraw the table to show the new item
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}

