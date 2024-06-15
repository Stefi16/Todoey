import UIKit
import CoreData
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var itemArray = [ToDoCategory]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let navbar = navigationController?.navigationBar {
            navbar.backgroundColor = UIColor(hexString: "1D9BF6")
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let safeText = textField.text {
                let category = ToDoCategory(context: self.context)
                category.name = safeText
                
                self.itemArray.append(category)
                self.saveItems()
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField() { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving items \(error)")
        }
    }
    
    private func loadItems(with request: NSFetchRequest<ToDoCategory> = ToDoCategory.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error loading items \(error)")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destionationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destionationVC.selectedCategory = itemArray[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.name
        
        if let hexColorString = item.color {
            cell.backgroundColor = UIColor(hexString: hexColorString)
        } else {
            cell.backgroundColor = UIColor.randomFlat()
            itemArray[indexPath.row].color = cell.backgroundColor?.hexValue()
            self.saveItems()
        }
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        saveItems()
        
        itemArray.remove(at: indexPath.row)
    }
}
