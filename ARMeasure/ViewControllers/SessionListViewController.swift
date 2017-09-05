//
//  AllSessionViewController.swift
//  ARMeasure
//
//  Created by YOUNG on 04/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class SessionListViewController: UITableViewController {
    
    // MARK: Realm
    var realmManager = RealmManager.sharedInstance
    var selectedSession: MeasureSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Session")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmManager.realm.objects(MeasureSessionList.self).first?.sessions.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Session", for: indexPath)
        
        let session: MeasureSession = realmManager.realm.objects(MeasureSessionList.self).first!.sessions[indexPath.row]
        cell.textLabel?.text = session.id
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
            let session: MeasureSession = realmManager.realm.objects(MeasureSessionList.self).first?.sessions[indexPath.row]
            else { return }
        
        selectedSession = session
        performSegue(withIdentifier: "SessionView", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SessionView" {
//            let navigationController = segue.destination as! UINavigationController
//            let controller = navigationController.topViewController as! SessionViewController
            let controller = segue.destination as! SessionViewController
//            let controller = navigationController.topViewController as! SessionViewController
            
            controller.session = selectedSession
        }
    }
}
