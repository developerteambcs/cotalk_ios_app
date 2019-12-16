//
//  RepBodyTableViewCell.swift
//  COTalk
//
//  Created by BCS Media on 1/3/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit

class RepBodyTableViewCell: UITableViewCell {

    @IBOutlet weak var callBody: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
