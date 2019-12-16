//
//  GetInvolvedViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/11/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit

class GetInvolvedViewController: UIViewController {

    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var nextB: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(_ animated: Bool) {
        subtitle.numberOfLines = 0
        nextB.layer.cornerRadius = 25.0
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
