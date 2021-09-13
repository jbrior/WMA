//
//  ViewController.swift
//  WMA
//
//  Created by Jesse Brior on 9/13/21.
//

import UIKit

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let newRecordBtn: UIButton = {
        let b = UIButton()
        b.setTitle("add new meal", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = .link
        b.layer.cornerRadius = 25
        b.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        return b
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(customCell.self,
                       forCellReuseIdentifier: "cell")
        table.layer.borderWidth = 1
        table.layer.borderColor = UIColor.blue.cgColor
        
        return table
    }()
    
    private var model = [MealItems]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WMA"
        getAllItems()
        tableView.delegate = self
        tableView.dataSource = self
        
        // add subviews
        view.addSubview(newRecordBtn)
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        newRecordBtn.frame = CGRect(x: 0, y: 200, width: view.frame.width - 75, height: 50)
        newRecordBtn.center.x = view.center.x
        
        let tvHeight = (view.bottom - 100) - (newRecordBtn.bottom + 20)
        tableView.frame = CGRect(x: 0, y: newRecordBtn.bottom + 20, width: view.frame.width - 75, height: tvHeight)
        tableView.center.x = view.center.x
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Meal",
                                      message: "Enter your meal.",
                                      preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            
            self?.createItem(meal: text)
        }))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = model[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.food
        cell.detailTextLabel?.text = "\(model.dateAdded!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = model[indexPath.row]
        let sheet = UIAlertController(title: "Edit",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit",
                                          message: "Edit Meal",
                                          preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.food
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newFood = field.text, !newFood.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newMeal: newFood)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        
        present(sheet, animated: true)
    }
    
    func getAllItems() {
        
        do {
            model = try context.fetch(MealItems.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("error fetching all items")
        }
    }
    
    func createItem(meal: String) {
        let newItem = MealItems(context: context)
        newItem.food = meal
        newItem.dateAdded = Date()
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            print("error creating new item")
        }
    }
    
    func deleteItem(item: MealItems) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            print("error deleting new item")
        }
    }
    
    func updateItem(item: MealItems, newMeal: String) {
        item.food = newMeal
        
        do {
            try context.save()
            getAllItems()
        }
        catch {
            print("error updating new item")
        }
    }
}

class customCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
    
    public var height: CGFloat {
        return self.frame.size.height
    }
    
    public var top: CGFloat {
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
    
    func addBackground() {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "bg")
        
        imageViewBackground.contentMode = .scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
