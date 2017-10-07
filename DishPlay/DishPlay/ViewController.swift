//
//  ViewController.swift
//  DishPlay
//
//  Created by Jiaxiao Zhou on 10/6/17.
//  Copyright © 2017 CalHack. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Alamofire
import TesseractOCR
import SwiftyJSON


class ViewController: UIViewController, ARSCNViewDelegate, G8TesseractDelegate{

    
    @IBOutlet var sceneView: ARSCNView!
	
	var allNodes: [SCNNode] = []
	var cardNumbers = 0
	var touch: UITouch!
	

    
    @IBOutlet weak var textView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureReconize:)))
        view.addGestureRecognizer(tapGesture)

    }
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		touch = touches.first
		let nodeResults = sceneView.hitTest(touch.location(in: sceneView), options: nil)
		for result in nodeResults {
			if allNodes.contains(result.node) {
				result.node.runAction(SCNAction.wait(duration: 0.5), completionHandler: {
					result.node.parent?.removeFromParentNode()
					self.allNodes.remove(at: self.allNodes.index(of: result.node)!)
					self.cardNumbers = 0
				})
			}
			
			for node in allNodes {
				if result.node == node.parent {
					return
				}
			}
		}
//		guard let touch = touches.first else { return }
//		var hitOnCard = false
//		let nodeResults = sceneView.hitTest(touch.location(in: sceneView), options: nil)
//		for result in nodeResults {
//			if allNodes.contains(result.node) {
//				hitOnCard = true
//				result.node.runAction(SCNAction.wait(duration: 0.5), completionHandler: {
//					result.node.parent?.removeFromParentNode()
//					self.allNodes.remove(at: self.allNodes.index(of: result.node)!)
//					self.cardNumbers = 0
//				})
//			}
//			for node in allNodes {
//				if result.node == node.parent {
//					return
//				}
//			}
//		}
//		if !hitOnCard && image != nil && cardNumbers == 0 {
//			cardNumbers = 1
//			let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
//			guard let hitFeature = results.last else { return }
//			let hitTransform = SCNMatrix4(hitFeature.worldTransform)
//			let hitPosition = SCNVector3Make(hitTransform.m41,
//											 hitTransform.m42,
//											 hitTransform.m43)
//
//			let billboardConstraint = SCNBillboardConstraint()
//			billboardConstraint.freeAxes = SCNBillboardAxis.Y
//
//			let backNode = SCNNode()
//			// backNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
//			let plaque = SCNBox(width: 0.14, height: 0.1, length: 0.01, chamferRadius: 0.005)
//			plaque.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.6)
//			backNode.geometry = plaque
//			// backNode.position = hitPosition
//
//			//Set up card view
//			let imageView = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
//			imageView.backgroundColor = .clear
//			imageView.alpha = 1.0
//
//			let circleLabel = UILabel(frame: CGRect(x: imageView.frame.width - 144, y: 48, width: 96, height: 96))
//			circleLabel.layer.cornerRadius = 48
//			circleLabel.clipsToBounds = true
//			circleLabel.backgroundColor = .red
//			imageView.addSubview(circleLabel)
//
//			let imageToDisplay = image
//			//let imageview = UIImageView(image: image)
//			//imageView.addSubview(imageview)
//
//			let infoNode = SCNNode()
//			//infoNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
//			let infoGeometry = SCNPlane(width: 0.13, height: 0.09)
//			infoGeometry.firstMaterial?.diffuse.contents = imageToDisplay
//			infoNode.geometry = infoGeometry
//			infoNode.position = hitPosition
//			backNode.constraints = [billboardConstraint]
//			infoNode.constraints = [billboardConstraint]
//			infoNode.addChildNode(backNode)
//			sceneView.scene.rootNode.addChildNode(infoNode)
//			self.allNodes.append(backNode)
//		}
	}
	
	func touches() {
		print("create card!")
		//guard let touch = touchesMade?.first else { return }
//		var hitOnCard = false
//		let nodeResults = sceneView.hitTest(touch.location(in: sceneView), options: nil)
//		for result in nodeResults {
//			if allNodes.contains(result.node) {
//				hitOnCard = true
//				result.node.runAction(SCNAction.wait(duration: 0.5), completionHandler: {
//					result.node.parent?.removeFromParentNode()
//					self.allNodes.remove(at: self.allNodes.index(of: result.node)!)
//					self.cardNumbers = 0
//				})
//			}
//			for node in allNodes {
//				if result.node == node.parent {
//					return
//				}
//			}
//		}
		let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
		guard let hitFeature = results.last else { return }
		let hitTransform = SCNMatrix4(hitFeature.worldTransform)
		let hitPosition = SCNVector3Make(hitTransform.m41,
										 hitTransform.m42,
										 hitTransform.m43)
		
		let billboardConstraint = SCNBillboardConstraint()
		billboardConstraint.freeAxes = SCNBillboardAxis.Y
		
		let backNode = SCNNode()
		let plaque = SCNBox(width: 0.14, height: 0.1, length: 0.01, chamferRadius: 0.005)
		plaque.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.6)
		backNode.geometry = plaque
		
		//Set up card view
		let imageView = UIView(frame: CGRect(x: 0, y: 0, width: 800, height: 600))
		imageView.backgroundColor = .clear
		imageView.alpha = 1.0
		
//		let circleLabel = UILabel(frame: CGRect(x: imageView.frame.width - 144, y: 48, width: 96, height: 96))
//		circleLabel.layer.cornerRadius = 48
//		circleLabel.clipsToBounds = true
//		circleLabel.backgroundColor = .red
//		imageView.addSubview(circleLabel)
		
		let imageToDisplay = image
//		let imageview = UIImageView(image: imageToDisplay)
//		imageView.addSubview(imageview)
		
		let closeNode = SCNNode()
		let closeSphere = SCNSphere(radius: 0.012)
		closeSphere.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
		closeNode.geometry = closeSphere
		
		let infoNode = SCNNode()
		let infoGeometry = SCNPlane(width: 0.13, height: 0.09)
		infoNode.rotation = SCNVector4.init(infoNode.rotation.x, infoNode.rotation.y, infoNode.rotation.z, -Float.pi/4)
		infoGeometry.firstMaterial?.diffuse.contents = imageToDisplay
		infoNode.geometry = infoGeometry
		infoNode.position = hitPosition
		closeNode.position.x = infoNode.position.x + Float(infoGeometry.width / 2)
		closeNode.position.y = infoNode.position.y + Float(infoGeometry.height / 2)
		backNode.constraints = [billboardConstraint]
		infoNode.constraints = [billboardConstraint]
		closeNode.constraints = [billboardConstraint]
		infoNode.addChildNode(closeNode)
		infoNode.addChildNode(backNode)
		sceneView.scene.rootNode.addChildNode(infoNode)
		print("Appear!")
		self.allNodes.append(closeNode)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    var dishName: String = "" {
        willSet {
            // run the image grapping thing
			if cardNumbers == 0 {
            let headers = [
                "Ocp-Apim-Subscription-Key": "293bdc29ef6540749d2db90d239bdc0e"
            ]
            var requestParams = [String:AnyObject]()
            requestParams["q"] = newValue as AnyObject?
            requestParams["count"] = 10 as AnyObject?
            requestParams["safeSearch"] = "Strict" as AnyObject?
            
            Alamofire.request("https://api.cognitive.microsoft.com/bing/v7.0/images/search",
              parameters: requestParams,
              encoding: URLEncoding.default, headers: headers).responseJSON {
                (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    
                    
                    if let JSON = response.result.value as? [String: Any] {
                        //print(JSON)
                        //take URLs from the json into an ImagesURLsArray
                        let value = JSON["value"] as? [[String: AnyObject]]
                        //for imageValue in value! {
                        if let imageValue = value {
                            if imageValue.count > 0 {
								self.cardNumbers = 1
                                self.imageURL = URL(string: (imageValue[0]["contentUrl"] as? String)!)
                                /*Alamofire.download((imageValue["contentUrl"] as? String)!)
                                 .responseData { response in
                                 if let data = response.result.value {
                                 let image = UIImage(data: data)
                                 }
                                 }*/
                                //}
                            }
                        }
                    }  else {
                        print("error with response.result.value")}
                case .failure(_):
                    if let errorNum = response.response?.statusCode {
                        let stringErrorNum = "{\"error\": \(errorNum)}"
                        print(stringErrorNum)
                    }
                }
            }
        }
		}
    }
    
    var imageURL: URL? {
        didSet {
			fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            let urlContents = try? Data(contentsOf: url)
            if let imageData = urlContents {
                image = UIImage(data: imageData)
                //self.performSegue(withIdentifier: "fromARtoImage", sender: self)
            }
        }
    }
    
    private var image: UIImage?
	{
		didSet {
			if image != nil {
				touches()
			} else {
				cardNumbers = 0
			}
			print(image == nil)
			print(cardNumbers)
		}
	}
    
    
    @objc
    func handleTap(gestureReconize: UITapGestureRecognizer) {
        guard sceneView.session.currentFrame != nil else {
            return
        }
        //guard let pointOfView = sceneView.pointOfView else { return }
        
        let image = sceneView.snapshot()
        let scale: CGFloat = image.size.width / sceneView.frame.size.width
        let rect: CGRect = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y-sceneView.frame.origin.y, width: textView.frame.size.width, height: textView.frame.size.height)
        let croppedImage = image.crop(rect:rect, scale: scale)
        // use Azure computer vision API
        /*
        var ocrParameters = [String:String]()
        ocrParameters["url"] = "https://i.stack.imgur.com/vrkIj.png"
        let headers = [
            "Content-Type": "application/json",
            "Ocp-Apim-Subscription-Key": "1b87ea699b16400c804b43a377a82484"
        ]
        Alamofire.request("https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/ocr", method: .post, parameters: [:], encoding: "{\"url\":\"https://i.stack.imgur.com/vrkIj.png\"}", headers: headers).responseJSON {
            (response:DataResponse<Any>) in
            
            switch(response.result) {
                case .success(_):
                    if let JSON = response.result.value as? [String: Any] {
                        print(JSON)
                    }
                case .failure(_):
                    if let errorNum = response.response?.statusCode {
                        let stringErrorNum = "{\"error\": \(errorNum)}"
                        print(stringErrorNum)
                    }
            }
        }*/
        
        if let tessract = G8Tesseract(language: "eng") {
            tessract.delegate = self
            
            tessract.image = croppedImage
            tessract.recognize()
            print("Recognized text: \(tessract.recognizedText)")
            
            dishName = tessract.recognizedText.trim()
        }
        //let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000, height: sceneView.bounds.height / 6000)
        //imagePlane.firstMaterial?.
        //imagePlane.
        
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract!) {
        print("Reconigtion progress: \(tesseract.progress) %")
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
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension UIImage {
    func crop( rect: CGRect, scale: CGFloat) -> UIImage {
        var rect = rect
        rect.origin.x*=scale
        rect.origin.y*=scale
        rect.size.width*=scale
        rect.size.height*=scale
 
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!)
        return image
    }
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
