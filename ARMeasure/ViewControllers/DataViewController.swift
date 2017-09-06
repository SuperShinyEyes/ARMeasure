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
        setMostRecentData()
        setupUI()
    }
    
    /**
     Use case:
             User enters album and lands on DataView scene.
             Gets no data id from ViewController
     */
    func setMostRecentData() {
        if data == nil {
            data = RealmManager.sharedInstance.currentDatum?.last
        }
    }
    
    func setupUI() {
        guard let data = data else {
            Logger.log("@DataViewController: data is still nil", event: .error)
            return
        }
        imageView.image = FileManagerWrapper.getImageFromDisk(name: data.screenshotName)
//        for coords in data.worldCoordinates {
//            coords.
//        }
//        textView.text = data.worldCoordinates
    }
}
