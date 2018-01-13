//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jake Sanders on 1/7/18.
//  Copyright © 2018 Jake Sanders. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    // Persistent storage realm
    let realm = try! Realm()
    
    // Array of todo list categories
    var categories: Results<Category>?
    
    var emptyCategoryCount = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load categories from persistent storage
        loadCategories()
    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = categories?.count ?? emptyCategoryCount
        print("Num Category Cells: \(count) EmptyCount: \(emptyCategoryCount)")
        return max(count,emptyCategoryCount)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let count = categories?.count ?? 0

        var category : Category?
        
        print("indexPath.row:\(indexPath.row) count:\(count)")
        
        if ( indexPath.row < count ) {
            category = categories?[indexPath.row]
            emptyCategoryCount = 0
        }
        
        cell.textLabel?.text = category?.name ?? "No Categories Added Yet"
        cell.backgroundColor = UIColor(hexString: category?.color ?? "1D9BF6")
        
        print("Cell \(indexPath.row) text: \(cell.textLabel?.text)")
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            // what will happen once the user clicks the Add Category button on our UIAlert
            
            // Create new item
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            // Add new category
            self.save(category: newCategory)
            
            // Redraw the table to show the new category
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write() {
                realm.add(category)
            }
        }
        catch {
            print("Error saving category to realm, \(error)")
        }
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}

