//
//  OrderedlistViewController.swift
//  DishPlay
//
//  Created by Jiaxiao Zhou on 10/8/17.
//  Copyright © 2017 CalHack. All rights reserved.
//

import UIKit

class OrderedlistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    public var orderedCards = [Card]()
    
    @IBOutlet weak var orderedlistTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderedlistTableView.dataSource = self
        self.orderedlistTableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.orderedCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        guard let cell = orderedlistTableView.dequeueReusableCell(withIdentifier: "orderedCell", for: indexPath as IndexPath) as? TableViewCell
            else {
                fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        cell.nameLabel.text = orderedCards[indexPath.row].name
        cell.photo.image = orderedCards[indexPath.row].image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
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
