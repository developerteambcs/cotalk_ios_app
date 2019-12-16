//
//  MemberTableViewCell.swift
//  COTalk
//
//  Created by BCS Media on 2/1/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberType: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        memberImage.layer.cornerRadius = memberImage.frame.height / 2
        memberImage.clipsToBounds = true
        activityIndicator.startAnimating()
        memberImage.image = #imageLiteral(resourceName: "User")
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
