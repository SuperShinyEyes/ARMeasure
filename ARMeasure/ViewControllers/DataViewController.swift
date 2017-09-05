//
//  DataViewController.swift
//  ARMeasure
//
//  Created by YOUNG on 04/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

protocol DataViewControllerDelegate: class {
    func DataViewControllerDidDelete(_ controller: DataViewController)
}

class DataViewController: UIViewController {

    weak var delegate: DataViewControllerDelegate?
    weak var data: MeasureData?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    func setupUI() {
        if data == nil {
            print("@DataViewController: data is nil")
            /// DataViewController is called from ARScene album button
            /// so it doesn't have any context. Get the latest data
            let realmManager = RealmManager.sharedInstance
            let sessionList = realmManager.realm.objects(MeasureSessionList.self).first!
            data = sessionList.sessions.last!.datum.last
            data = realmManager.currentDatum!.last
        }
        if let data = data {
            imageView.image = FileManagerWrapper.getImageFromDisk(name: data.screenshotName)
        }else {
            print("@DataViewController: data is still nil")
        }
//        for coords in data.worldCoordinates {
//            coords.
//        }
//        textView.text = data.worldCoordinates
    }
}
