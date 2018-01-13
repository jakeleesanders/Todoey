//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jake Sanders on 1/6/18.
//  Copyright © 2018 Jake Sanders. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    // Persistent storage realm
    let realm = try! Realm()
    
    // Array of items in the todo list
    var todoItems: Results<Item>?
    
    // Category selected by user
    var selectedCategory : Category? {
        didSet {
            tableView.rowHeight = 80.0

            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Debug print the applications document directory
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}
        guard let colorHex = selectedCategory?.color else { fatalError() }
        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
        let navBarContrastColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        title = selectedCategory?.name
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = navBarContrastColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : navBarContrastColor]
        searchBar.barTintColor = navBarColor
    }

    override func viewWillDisappear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")}
        
        guard let originalColor = UIColor(hexString: "1D9BF6") else { fatalError() }
        
        navBar.barTintColor = originalColor
        navBar.tintColor = FlatWhite()
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : FlatWhite()]
    }
    
    //MARK: - Tableview Datasource Methods
    
    // Returns the total number of rows in our table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    // Loads the contents of a cell (row)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let item = todoItems?[indexPath.row] {
            if let currentCategory = selectedCategory {
                let categoryColor = UIColor(hexString: currentCategory.color )
                let darkPercentage = CGFloat(indexPath.row) / CGFloat(todoItems!.count) * 0.5
                if let color = categoryColor?.darken(byPercentage: darkPercentage) {
                    cell.backgroundColor = color
//                    cell.backgroundColor = GradientColor(UIGradientStyle.leftToRight, frame: cell.bounds, colors: [color, categoryColor!])
                    cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                }
            }
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    // Toggle checkmark
                    item.done = !item.done
//                    realm.delete(item)
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        // Redraw so checkmark will change
        tableView.reloadData()
        
        // Deselect so the row doesn't remain highlighted
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // what will happen once the user clicks the Add Item button on our UIAlert

            // Add the new item
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write() {
                        // Create new item
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving item to realm, \(error)")
                }
            }
            
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
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        do {
            try self.realm.write() {
                if let itemForDeletion = todoItems?[indexPath.row] {
                    self.realm.delete(itemForDeletion)
                }
            }
        } catch {
            print("Error deleting item, \(error)")
        }
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

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

