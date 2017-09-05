//
//  MeasureDataAlbumNavigationController.swift
//  ARMeasure
//
//  Created by YOUNG on 04/09/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class MeasureDataAlbumNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let first = storyboard!.instantiateViewController(withIdentifier: "SessionList") as! SessionListViewController
        let second = storyboard!.instantiateViewController(withIdentifier: "Session") as! SessionViewController
        let third = storyboard!.instantiateViewController(withIdentifier: "Data") as! DataViewController
        
        let stack = [first, second, third]
        setViewControllers(stack, animated: true)
        pushViewController(third, animated: false)
    }
}

class MeasureDataAlbumViewController: UIViewController {
}
