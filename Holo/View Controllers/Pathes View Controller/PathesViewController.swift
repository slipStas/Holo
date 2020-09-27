//
//  PathesViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 26.09.2020.
//

import UIKit

class PathesViewController: UIViewController {
    
    var coordinatesArray: [CoordinatesCoreData] = []
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
            self.coordinatesArray = try context.fetch(CoordinatesCoreData.fetchRequest())
            print(self.coordinatesArray.count)
        } catch {
            
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
        self.coordinatesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pathes", for: indexPath) as! PathesTableViewCell
        
        cell.pathesLabel.text = String(coordinatesArray[indexPath.row].latitude) + " " + String(coordinatesArray[indexPath.row].longitude)
        
        return cell
    }
}


