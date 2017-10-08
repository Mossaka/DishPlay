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
    @IBOutlet var parentView: UIView!
	
	var spinner: UIActivityIndicatorView?
    
    public var restuarantName = ""
    @IBOutlet var sceneView: ARSCNView!
	
	private var allNodes: [SCNNode] = []
	private var cardNumbers = 0
	private var touch: UITouch!
	private var imageView: UIView!
    
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
        
        print(restuarantName)
        parentView.sendSubview(toBack: sceneView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureReconize:)))
        view.addGestureRecognizer(tapGesture)

//		let httpHeader = ["Ocp-Apim-Subscription-Key": "36d7f5aceb124a0f9bc50c2bf6023699"]
//		Alamofire.request("https://api.cognitive.microsoft.com/bing/v7.0/SpellCheck",
//						  method: .get,
//						  parameters: ["text":"califnia"], headers: httpHeader).responseJSON {
//
//							response in
//
//							print("success")
//							if let result = response.result.value as? [String: Any] {
//								let json = JSON(arrayLiteral: result)
//								print(json)
//								print(json["flaggedTokens"])
//								for (_, subJSON):(String, JSON) in json["flaggedTokens"] {
//									print("in here")
//									let newName = self.dishName.replacingOccurrences(of: subJSON["token"].string!, with: subJSON["suggestions"][0]["suggestion"].string!)
//									print(newName)
//									self.dishName = newName
//								}
//							}
//
//			}
    }
    
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		touch = touches.first
		let nodeResults = sceneView.hitTest(touch.location(in: sceneView), options: nil)
		for result in nodeResults {
			if allNodes.contains(result.node) {
				result.node.runAction(SCNAction.wait(duration: 0.5), completionHandler: {
					print("touched")
					result.node.parent!.physicsBody!.velocity = SCNVector3.init(0,10,0)
					self.allNodes.remove(at: self.allNodes.index(of: result.node)!)
				})
				self.textView.alpha = 0.5
				self.cardNumbers = 0
				break
			}
		}
	}
	
	
	func touches() {
		print("create card!")
		let results = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
		guard let hitFeature = results.last else { return }
		let hitTransform = SCNMatrix4(hitFeature.worldTransform)
		let hitPosition = SCNVector3Make(hitTransform.m41,
										 hitTransform.m42,
										 hitTransform.m43)
		
		let billboardConstraint = SCNBillboardConstraint()
		billboardConstraint.freeAxes = SCNBillboardAxis.Y
		
		let imageRatio = image!.size.height/image!.size.width
		let imageToDisplay = image!
		let imageview = UIImageView(image: imageToDisplay)
		
		//Set up card view
		imageView = UIView(frame: imageview.frame)
		imageView.backgroundColor = .clear
		imageView.alpha = 1.0
		
		imageView.addSubview(imageview)

		let backNode = SCNNode()
		let box = SCNBox(width: 0.14, height: 0.14*imageRatio, length: 0.01, chamferRadius: 0.005)
		box.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.2)
		backNode.geometry = box
		
		let closeNode = SCNNode()
		let closeSphere = SCNSphere(radius: 0.006)
		closeSphere.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
		closeNode.geometry = closeSphere
		
		let infoNode = SCNNode()
		let infoGeometry = SCNPlane(width: 0.13, height: 0.13*imageRatio)
		infoNode.position = hitPosition
		infoGeometry.firstMaterial?.diffuse.contents = imageView
		infoNode.geometry = infoGeometry
		
		let dishNameNode = SCNNode()
		let nameNodeGeometry = SCNPlane(width: 0.13, height: 0.02)
		
		let nameView = UIView(frame: CGRect(x: 0, y: 0, width: 130, height: 20))
		nameView.backgroundColor = .clear
		nameView.alpha = 0.6
		
		let dishNameTag = UILabel(frame: CGRect(x: 0, y: 0, width: 130, height: 20))
		dishNameTag.textAlignment = .center
		dishNameTag.text = dishName
		dishNameTag.font = UIFont(name: "Italic", size: 50)
		dishNameTag.adjustsFontSizeToFitWidth = true
		dishNameTag.backgroundColor = .yellow
		nameView.addSubview(dishNameTag)
		nameNodeGeometry.firstMaterial?.diffuse.contents = nameView
		dishNameNode.geometry = nameNodeGeometry
		
		let orderNode = SCNNode()
		let orderSphere = SCNSphere(radius: 0.006)
		orderSphere.firstMaterial?.diffuse.contents = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
		orderNode.geometry = orderSphere

		infoNode.addChildNode(dishNameNode)
		infoNode.addChildNode(closeNode)
		infoNode.addChildNode(orderNode)
		infoNode.constraints = [billboardConstraint]
		closeNode.position.y += Float(infoGeometry.height/2)
		closeNode.position.x += Float(infoGeometry.width/2)
		dishNameNode.position.y += Float(infoGeometry.height*0.7)
		orderNode.position.y += Float(infoGeometry.height/2)
		orderNode.position.x -= Float(infoGeometry.width/2)
		infoNode.addChildNode(backNode)
		sceneView.scene.rootNode.addChildNode(infoNode)
		
		let physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: infoNode))
		infoNode.physicsBody = physicsBody
		
		
		textView.alpha = 0.0
		cardNumbers = 1
		self.allNodes.append(closeNode)
		self.allNodes.append(orderNode)
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
            print("Dish name is \(newValue)")
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
				  encoding: URLEncoding.default,
                  headers: headers).responseJSON {
					(response:DataResponse<Any>) in
					
					switch(response.result) {
					case .success(_):
						
						
						if let JSON = response.result.value as? [String: Any] {
							print("hahaha")
							//print(JSON)
							//take URLs from the json into an ImagesURLsArray
							let value = JSON["value"] as? [[String: AnyObject]]
							//for imageValue in value! {
							if let imageValue = value {
								if imageValue.count > 0 {
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
			if cardNumbers == 0 {
				fetchImage()
			}
        }
    }
    
	private func fetchImage() {
		if let url = imageURL {
			spinner = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2, width: 0.2, height: 0.2))
			self.view.addSubview(spinner!)
			spinner?.startAnimating()
			DispatchQueue.global(qos: .userInitiated).async {
				[weak self] in
				let urlContents = try? Data(contentsOf: url)
				if let imageData = urlContents, url == self?.imageURL {
					DispatchQueue.main.async {
						self?.image = UIImage(data: imageData)
						//self.performSegue(withIdentifier: "fromARtoImage", sender: self)
					}
				}
			}
		}
	}
	
	private var image: UIImage?
	{
		didSet {
			if image != nil {
				touches()
				spinner?.stopAnimating()
			} else {
				cardNumbers = 0
			}
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
        let rect = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y-sceneView.frame.origin.y, width: textView.frame.size.width, height: textView.frame.size.height)
        let croppedImage = image.crop(rect:rect, scale: scale)
        let imageData = UIImagePNGRepresentation(croppedImage)!
        let headers = [
            "Content-Type": "application/octet-stream",
            "Ocp-Apim-Subscription-Key": "b33063f266204f2ca7b6760363f33333",
            "language":"en"
        ]
        var setence = ""
        Alamofire.upload(imageData, to: "https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=en", method: .post, headers: headers).responseJSON {
            (response:DataResponse<Any>) in
            if let result = response.result.value as? [String:Any] {
                let json = JSON(arrayLiteral: result)
                for (key, subJSON):(String, JSON) in json[0]["regions"][0] {
                    if key == "lines" {
                        for (_, line): (String, JSON) in subJSON {
                            for (key1, subJSON1):(String, JSON) in line {
                                if key1 == "words" {
                                    for (_, word): (String, JSON) in subJSON1 {
                                        for (key2, subJSON2):(String, JSON) in word {
                                            if key2 == "text" {
                                                print("subJSON2 is \(subJSON2)")
                                                if let word = subJSON2.string {
                                                    setence += " \(word)"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                self.dishName = setence
				/*
                let httpHeader = ["Ocp-Apim-Subscription-Key": "af934b444d5342898a667099424b7841"]
                Alamofire.request("https://api.cognitive.microsoft.com/bing/v5.0/spellcheck",
                                  method: .get,
								  parameters: ["text":"califnia"], headers: httpHeader).responseJSON {
									
                    (response:DataResponse<Any>) in
                    switch(response.result) {
                    case .success(_):
						print("success")
                        if let result = response.result.value as? [String: Any] {
							let json = JSON(arrayLiteral: result)
							print(json)
							print(json["flaggedTokens"])
                            for (_, subJSON):(String, JSON) in json["flaggedTokens"] {
								print("in here")
                                let newName = self.dishName.replacingOccurrences(of: subJSON["token"].string!, with: subJSON["suggestions"][0]["suggestion"].string!)
								print(newName)
								self.dishName = newName
                            }
                        }
                    case .failure(_):
                        if let errorNum = response.response?.statusCode {
                            let stringErrorNum = "{\"error\": \(errorNum)}"
                            print(stringErrorNum)
                        }

                    }*/
				
            }
        }
        /*
        if let tessract = G8Tesseract(language: "eng") {
            tessract.delegate = self
            
            tessract.image = croppedImage
            tessract.recognize()
            print("Recognized text: \(tessract.recognizedText)")
            
            dishName = tessract.recognizedText.trim()
        }*/
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
	
//	func scaleToNewSize(heightPlusWidth: CGFloat) -> UIImage {
//		var scaledImageRect = CGRect(x: 0, y: 0, width: 0, height: 0)
//		let newSize = CGSize(width: heightPlusWidth/(self.size.width+self.size.height)*self.size.width, height: heightPlusWidth/(self.size.width+self.size.height)*self.size.height)
//		scaledImageRect.size = newSize
//		scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
//		scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
//
//		UIGraphicsBeginImageContextWithOptions( newSize, false, 0 )
//		draw(in: scaledImageRect)
//		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//		UIGraphicsEndImageContext()
//
//		return scaledImage!
//	}
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}
