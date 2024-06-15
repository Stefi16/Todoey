import UIKit
import CoreData
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var itemArray = [ToDoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: ToDoCategory? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        let currentItem = itemArray[indexPath.row]
        cell.textLabel?.text = currentItem.title
        
        if let cellsColor = UIColor(hexString: selectedCategory?.color ?? "")?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = cellsColor
            cell.textLabel?.textColor = ContrastColorOf(cellsColor, returnFlat: true)
        }
        
        cell.accessoryType = currentItem.done ? .checkmark : .none
        saveItems()
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let color = UIColor(hexString: selectedCategory?.color ?? "") ?? UIColor.randomFlat()
        
        if let navbar = navigationController?.navigationBar {
            navbar.backgroundColor = color
            navbar.tintColor = ContrastColorOf(color, returnFlat: true)
            searchBar.barTintColor = color
            
            title = selectedCategory?.name
            navbar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(color, returnFlat: true)]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        itemArray[indexPath.row].done.toggle()
        tableView.reloadData()
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            if let safeText = textField.text {
                let item = ToDoItem(context: self.context)
                item.title = safeText
                item.done = false
                item.parentCategory
                = self.selectedCategory
                
                self.itemArray.append(item)
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
            print(error)
        }
    }
    
    private func loadItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate: NSPredicate? = nil) {
        let catPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [additionalPredicate, catPredicate])
        } else {
            request.predicate = catPredicate
        }
        
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching from context\(error.localizedDescription)")
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        context.delete(itemArray[indexPath.row])
        saveItems()
        
        itemArray.remove(at: indexPath.row)
    }
}

//MARK: UISearchBarDelegate
extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            tableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
