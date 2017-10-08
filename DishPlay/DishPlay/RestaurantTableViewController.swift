//
//  RestaurantTableViewController.swift
//  DishPlay
//
//  Created by Jiaxiao Zhou on 10/7/17.
//  Copyright © 2017 CalHack. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class RestaurantTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var resTableView: UITableView!
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var resNames = [String]()
    var resIds = [String]()
    var resImages = [UIImage]()
    
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.resTableView.dataSource = self
        self.resTableView.delegate = self
        locManager.requestWhenInUseAuthorization()
        indicator.startAnimating()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            getListOfRestaurants(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
            assert(resNames.count == resIds.count)
            print(self.resNames)
            self.resTableView.reloadData()

        }
        else {
            // segue to AR
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.resImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        guard let cell = resTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as? TableViewCell
        else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.nameLabel.text = resNames[indexPath.row]
        cell.photo.image = resImages[indexPath.row]
        
        if(indexPath.row == 7) {
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    func getListOfRestaurants(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        var restNames = [String]()
        var restIds = [String]()
        var resImages = [UIImage]()
        
        let headers = [
            "Accept": "application/json",
            "user-key": "5e5b9b93ef31a2c163bd291d3413f47b"
        ]
        
        let parameters = [
            "lat": Double(lat),
            "lon": Double(lon)
        ]
        let baseURL = "https://developers.zomato.com/api/v2.1/search"
        
        Alamofire.request(baseURL, method: .get,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers).responseJSON {
            (response:DataResponse<Any>) in
            if let JSON = response.result.value as? [String: Any] {
                //take URLs from the json into an ImagesURLsArray
                //print(JSON)
                let value = JSON["restaurants"] as? [[String: AnyObject]]
                for restuarantItem in (value)! {
                    let restuarnatInfo = restuarantItem["restaurant"] as? [String:AnyObject]
                    if let restuarantName = restuarnatInfo!["name"] {
                        self.imageURL = URL( string:restuarnatInfo!["featured_image"] as! String )
                        restNames.append(restuarantName as! String)
                        restIds.append(restuarnatInfo!["id"] as! String)
                    }
                }
                print(restNames)
                self.resNames = restNames
                self.resIds = restIds
                
                self.resTableView.reloadData()
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
                self.resImages.append( UIImage(data: imageData)! )
                //self.performSegue(withIdentifier: "fromARtoImage", sender: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var selectedID: String = ""
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedID = self.resIds[indexPath.row]
        // Segue to the second view controller
        self.performSegue(withIdentifier: "fromTableToAR", sender: self)
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // get a reference to the second view controller
        let secondViewController = segue.destination as! ViewController
        
        // set a variable in the second view controller with the data to pass
        secondViewController.restuarantName = selectedID
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
