//
//  ViewController.swift
//  SeyoungARBasic
//
//  Created by YOUNG on 03/08/2017.
//  Copyright © 2017 YOUNG. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Photos

class MainViewController: UIViewController {
    
    var measure = Measure.sharedInstance

    @IBOutlet var sceneView: ARSCNView!
    
    let session = ARSession()
    var sessionConfig: ARWorldTrackingSessionConfiguration!
    
    var resetButton: UIButton!
    var mainView: MainView!
    // MARK: - Focus Square
    var focusSquare: FocusSquare?
    var screenCenter: CGPoint?
    
    var dragOnInfinitePlanesEnabled = false
    
    func setupFocusSquare() {
        focusSquare?.isHidden = true
        focusSquare?.removeFromParentNode()
        focusSquare = FocusSquare()
        sceneView.scene.rootNode.addChildNode(focusSquare!)
//        textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        setupFocusSquare()
        
        mainView = MainView(frame: UIScreen.main.bounds, targetViewController: self, resetSelector: #selector(resetMeasuring))
        self.view.addSubview(mainView)
        
        session.delegate = self
        
        measure.delegate = self
    }
    
    private func setupScene() {
        
        sceneView.delegate = self
        sceneView.session = session
        sceneView.automaticallyUpdatesLighting = false
        
        sceneView.preferredFramesPerSecond = 60
        /// Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        setupARSessionConfiguration()
        sceneView.session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
        
        DispatchQueue.main.async {
            self.screenCenter = self.sceneView.bounds.mid
        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    /// IBActions
    
    @IBAction func undo() {
        measure.undo()
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        /** Hit-test can have several options:
             - .existingPlane
             - .estimatedHorizontalPlane
             - .featurePoint
         
         */
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint])
        
        guard let hitResult = result.last else { return }
        let hitTransform = SCNMatrix4(hitResult.worldTransform)
        let hitVector = SCNVector3Make(hitTransform.m41, hitTransform.m42, hitTransform.m43)
        
        measure.addMeasureNode(newVector: hitVector)
    }
    
    func setupARSessionConfiguration() {
        sessionConfig = ARWorldTrackingSessionConfiguration()
        sessionConfig.planeDetection = .horizontal
        sessionConfig.isLightEstimationEnabled = true
    }
    
    
    @objc func getArea() {
        measure.getArea()
    }
    
    @objc func resetMeasuring() {
        measure.reset()
        disableAreaCalculation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func worldPositionFromScreenPosition(_ position: CGPoint,
                                         objectPos: SCNVector3?,
                                         infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
        
        // -------------------------------------------------------------------------------
        // 1. Always do a hit test against exisiting plane anchors first.
        //    (If any such anchors exist & only within their extents.)
        
        let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
        if let result = planeHitTestResults.first {
            
            let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
            let planeAnchor = result.anchor
            
            // Return immediately - this is the best possible outcome.
            return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
        }
        
        // -------------------------------------------------------------------------------
        // 2. Collect more information about the environment by hit testing against
        //    the feature point cloud, but do not return the result yet.
        
        var featureHitTestPosition: SCNVector3?
        var highQualityFeatureHitTestResult = false
        
        let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
        
        if !highQualityfeatureHitTestResults.isEmpty {
            let result = highQualityfeatureHitTestResults[0]
            featureHitTestPosition = result.position
            highQualityFeatureHitTestResult = true
        }
        
        // -------------------------------------------------------------------------------
        // 3. If desired or necessary (no good feature hit test result): Hit test
        //    against an infinite, horizontal plane (ignoring the real world).
        
        if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
            
            let pointOnPlane = objectPos ?? SCNVector3Zero
            
            let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
            if pointOnInfinitePlane != nil {
                return (pointOnInfinitePlane, nil, true)
            }
        }
        
        // -------------------------------------------------------------------------------
        // 4. If available, return the result of the hit test against high quality
        //    features if the hit tests against infinite planes were skipped or no
        //    infinite plane was hit.
        
        if highQualityFeatureHitTestResult {
            return (featureHitTestPosition, nil, false)
        }
        
        // -------------------------------------------------------------------------------
        // 5. As a last resort, perform a second, unfiltered hit test against features.
        //    If there are no features in the scene, the result returned here will be nil.
        
        let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
        if !unfilteredFeatureHitTestResults.isEmpty {
            let result = unfilteredFeatureHitTestResults[0]
            return (result.position, nil, false)
        }
        
        return (nil, nil, false)
    }
    
    func updateFocusSquare() {
        guard let screenCenter = screenCenter else { return }
        focusSquare?.unhide()
        if let focusSquare = focusSquare {
            if focusSquare.isHidden {
                
            }
            
        }
        
        let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
        if let worldPos = worldPos {
            focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
//            textManager.cancelScheduledMessage(forType: .focusSquare)
        }
    }
    
    func takeScreenshot() {
        guard mainView.screenshotButton.isEnabled else {
            return
        }
        
        let takeScreenshotBlock = {
            UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
            DispatchQueue.main.async {
                // Briefly flash the screen.
                let flashOverlay = UIView(frame: self.sceneView.frame)
                flashOverlay.backgroundColor = UIColor.white
                self.sceneView.addSubview(flashOverlay)
                UIView.animate(withDuration: 0.25, animations: {
                    flashOverlay.alpha = 0.0
                }, completion: { _ in
                    flashOverlay.removeFromSuperview()
                })
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            takeScreenshotBlock()
        case .restricted, .denied:
            let title = "Photos access denied"
            let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
//            textManager.showAlert(title: title, message: message)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    takeScreenshotBlock()
                }
            })
        }
    }

}

extension MainViewController: MeasureDelegate {
    func enableAreaCalculation() {
        mainView.getAreaButton.addTarget(self, action: #selector(getArea), for: .touchUpInside)
        mainView.getAreaButton.setTitleColor(.blue, for: .normal)
        mainView.getAreaButton.setTitleColor(.black, for: .highlighted)
    }
    
    func disableAreaCalculation() {
        mainView.getAreaButton.removeTarget(self, action: #selector(getArea), for: .touchUpInside)
        mainView.getAreaButton.setTitleColor(.gray, for: .normal)
        mainView.getAreaButton.setTitleColor(.gray, for: .highlighted)
    }
    
    func updateLabel(perimeter: Float, area: Float) {
        mainView.setLabelText(perimeter: perimeter, area: area)
    }
    
    var isAreaCalculationAvailable: Bool {
        return mainView.getAreaButton.titleColor(for: .normal)! == .gray
    }
}

extension MainViewController: ARSessionDelegate {
    
}


extension MainViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        addplaneGeo
    }
    
}
