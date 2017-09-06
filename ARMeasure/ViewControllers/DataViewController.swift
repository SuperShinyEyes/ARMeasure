//
//  DataViewController.swift
//  ARMeasure
//
//  Created by YOUNG on 04/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import SwiftyJSON
import SceneKit

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
    
    /**
     Share a single measure session
     When sharing an image, share it via URL not UIImage.
     If you share UIImage,
         - image name will get lost, and
         - image will be compressed (size is 10%)
         - but resolution is same
     */
    @IBAction func share(_ sender: UIBarButtonItem) {
        guard let data: MeasureData = data else {
            Logger.log("No data to share", event: .error)
            return
        }
        
        guard let imageFileURL: URL = FileManagerWrapper.getPathWithFileName(
            FileName: data.screenshotName,
            format: ImageFormat.png.rawValue
            ) else {
            Logger.log("Image url doesn't exist: \(data.screenshotName)", event: .error)
            return
        }
        
        /// 1. Convert data into JSON
        let worldCoordinates: [[Float]] = data.worldCoordinates.map { c in
            return [c.x,c.y,c.z]
        }
        Logger.log("worldCoordinates: \(worldCoordinates)", event: .verbose)
        
        let screenCoordinates: [[Float]] = data.screenCoordinates.map { c in
            return [c.x,c.y]
        }
        Logger.log("screenCoordinates: \(screenCoordinates)", event: .verbose)
        
        
        var json: JSON = [
            "worldCoordinates": worldCoordinates,
            "screenCoordinates": screenCoordinates
        ]
        
        /// 2. Get path for JSON in local drive
        guard let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
        }
        
        let saveFileURL = path.appendingPathComponent("test.json")
        
        /// 4. Get screenshot
        json["screenShotName"].stringValue = data.screenshotName
        
        /// 3. Write JSON to local drive
        let jsonData = try! json.rawData()
        try! jsonData.write(to: saveFileURL, options: .atomic)


        let activityVC = UIActivityViewController(activityItems: ["measure data", saveFileURL, imageFileURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view

        self.present(activityVC, animated: true, completion: nil)
    }
}
