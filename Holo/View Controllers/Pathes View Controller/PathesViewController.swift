//
//  PathesViewController.swift
//  Holo
//
//  Created by Stanislav Slipchenko on 26.09.2020.
//

import UIKit

class PathesViewController: UIViewController {

    @IBOutlet weak var pathesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pathesTableView.delegate = self
        pathesTableView.dataSource = self
    }
}

extension PathesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension PathesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pathes", for: indexPath) as! PathesTableViewCell
        
        cell.pathesLabel.text = String(indexPath.row)
        
        return cell
    }
}


