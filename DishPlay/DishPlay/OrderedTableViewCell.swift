//
//  OrderedTableViewCell.swift
//  DishPlay
//
//  Created by Jiaxiao Zhou on 10/8/17.
//  Copyright © 2017 CalHack. All rights reserved.
//

import UIKit

class OrderedTableViewCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var rating: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
