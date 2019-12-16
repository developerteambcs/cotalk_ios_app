//
//  AgentTableViewCell.swift
//  COTalk
//
//  Created by BCS Media on 1/8/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit

class AgentTableViewCell: UITableViewCell {

    @IBOutlet weak var agentPhoto: UIImageView!
    @IBOutlet weak var agentPosition: UILabel!
    @IBOutlet weak var agentName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        agentPhoto.layer.cornerRadius = agentPhoto.frame.width / 2
        agentPhoto.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
