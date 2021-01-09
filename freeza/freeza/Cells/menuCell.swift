//
//  menuCell.swift
//  freeza
//
//  Created by Carlos Alcala on 1/7/21.
//  Copyright © 2021 Zerously. All rights reserved.
//

import UIKit

class menuCell: UITableViewCell {
    
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var txtMenu: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setData(_ data:[String:AnyObject] ) {
        if let cellTxt = data["txtMenu"] as? String
        {
            self.txtMenu.text = cellTxt

        }
        if let cellImg = data["imgMenu"] as? String
        {
            self.imgMenu.image = UIImage(named: cellImg)

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
