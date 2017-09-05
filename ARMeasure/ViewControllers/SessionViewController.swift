//
//  SessionViewController.swift
//  ARMeasure
//
//  Created by YOUNG on 04/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

protocol SessionViewControllerDelegate: class {
    
}
class SessionViewController: UITableViewController {
    
    // MARK: Realm
    var realmManager = RealmManager.sharedInstance
    weak var session: MeasureSession?
    var selectedData: MeasureData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Data")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return session?.datum.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Data", for: indexPath)
        guard let data: MeasureData = self.session?.datum[indexPath.row] else {
            return cell
        }
        
        cell.textLabel?.text = data.screenshotName
        cell.imageView?.image = FileManagerWrapper.getImageFromDisk(name: data.screenshotName) ?? nil
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
            let data = session?.datum[indexPath.row] else { return }
        selectedData = data
        performSegue(withIdentifier: "DataView", sender: nil)
        
    }
    
    
}

extension SessionViewController: DataViewControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DataView" {
//            let navigationController = segue.destination as! UINavigationController
//            let controller = navigationController.topViewController as! DataViewController
            let controller = segue.destination as! DataViewController
            
            controller.delegate = self
            controller.data = selectedData
        }
    }
    
    func DataViewControllerDidDelete(_ controller: DataViewController) {
        dismiss(animated: true, completion: nil)
    }
}
