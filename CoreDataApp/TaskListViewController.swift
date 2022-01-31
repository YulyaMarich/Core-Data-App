//
//  TaskListViewController.swift
//  CoreDataApp
//
//  Created by Julia on 30.01.2022.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    private let cellID = "cell"
    private var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setUpNavigationBar()
        tasks = storageManager.fetchData()
    }
    
    private func setUpNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(
            displayP3Red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        showCreateTaskAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func showCreateTaskAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.storageManager.save(task) { task in
                self.tasks.append(task)
                
                let indexPath = IndexPath(row: self.tasks.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        
        present(alert, animated: true)
    }
    
    private func showChangeTaskAlert( _ textFieldText: String, _ taskToChange: Task, _ indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit", message: "Edit your task", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let changedTask = alert.textFields?.first?.text, !changedTask.isEmpty else { return }
            self.storageManager.change(taskToChange, changedTask)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        alert.textFields?.first?.text = textFieldText
        
        present(alert, animated: true)
    }
}

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let taskToDelete = self.tasks[indexPath.row]
            print(taskToDelete)
            self.storageManager.delete(taskToDelete)
            self.tasks.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            let taskToChange = self.tasks[indexPath.row]
            guard let taskText = taskToChange.name else { return }
            self.showChangeTaskAlert(taskText, taskToChange, indexPath)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

