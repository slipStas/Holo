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
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium
        dateFormatter.dateStyle = DateFormatter.Style.medium
        
        /// for russian language
        /// dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "HH:mm  EEE, d MMMM"
        
        cell.pathesLabel.text = String(format: "%.0f", routsArray[indexPath.row].routeLength) + " meters " + (routsArray[indexPath.row].time ?? "0:0") + " sec."// + String(describing: routsArray[indexPath.row].coordinates?.count)
        cell.dateLabel.text = dateFormatter.string(from: routsArray[indexPath.row].date ?? Date())
        
        return cell
    }
}


