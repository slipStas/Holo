//
//  PathesViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 26.09.2020.
//

import UIKit

class PathesViewController: UIViewController {
    
    var routsArray: [Route] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var pathesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        load()
        pathesTableView.reloadData()
        
        pathesTableView.delegate = self
        pathesTableView.dataSource = self
    }
    
    func load() {
        do {
            self.routsArray = try context.fetch(Route.fetchRequest())
            print(self.routsArray.count)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension PathesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PathesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.routsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pathes", for: indexPath) as! PathesTableViewCell
        
        cell.pathesLabel.text = String(routsArray[indexPath.row].routeLength) + " " + (routsArray[indexPath.row].time ?? "0:0") + " " + String(describing: routsArray[indexPath.row].coordinates?.count)
        
        return cell
    }
}


