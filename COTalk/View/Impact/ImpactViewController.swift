//
//  ImpactViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/9/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit
import SystemConfiguration

class ImpactViewController: UIViewController {

    
    class func isConnectedToNetwor() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    @IBOutlet weak var allCalls: UILabel!
    @IBOutlet weak var callStrike: UILabel!
    @IBOutlet weak var leftVoice: UILabel!
    @IBOutlet weak var generalTitle: UILabel!
    @IBOutlet weak var moreinfoButton: UIButton!
    @IBOutlet weak var madectcLabel: UILabel!
    @IBOutlet weak var madectct2: UILabel!
    @IBOutlet weak var secondaryView: UIView!
    @IBOutlet weak var unavaLabel: UILabel!
    @IBOutlet weak var unavaLabel2: UILabel!
    var totalImpact = 0
    fileprivate var didshowOnce = false
    fileprivate var unavahasChanged = 0
    fileprivate var contacthasChanged = 0
    fileprivate var voicehasChanged = 0
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
                // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if   ImpactViewController.isConnectedToNetwor() == true {
            DispatchQueue.main.async {
                //self.activityIndicator.startAnimating()
                self.howmanyCalls()
                
            }
            
            
        }else {
            
            
            
        }
       /* print("Device type\(UIDevice.current.model)")
        if UIDevice.current.model == "iPad"{
            moreinfoButton.isHidden = true
        }else{
            moreinfoButton.isHidden = false
        }*/
      
        secondaryView.layer.borderWidth = 1.0
        secondaryView.layer.borderColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        
        moreinfoButton.layer.cornerRadius = 25.0
        
        if let startedDate = UserDefaults.standard.object(forKey: "startDate"){
            
            
            let currentDate = Date()
            print("Started using date : \(startedDate as! Date)")
            print("Current using date : \(currentDate )")
            
            var diffcComponent = Calendar.current.dateComponents([.day,.month,.year,.hour,.minute], from: startedDate as! Date, to: currentDate)
            
            if didshowOnce == true{
                
                if let contct = UserDefaults.standard.object(forKey: "contact"){
                    if contct as! Int > contacthasChanged{
                        madectct2.text = "\(contct)"
                        totalImpact += contct as! Int
                        contacthasChanged = contct as! Int
                    }
                    
                }
                
                if let voice = UserDefaults.standard.object(forKey: "voicemail"){
                    if voice as! Int > voicehasChanged{
                        
                        leftVoice.text = "\(voice)"
                        totalImpact += voice as! Int
                        voicehasChanged = voice as! Int
                    }
                    
                }
                
                if let unavai = UserDefaults.standard.object(forKey: "unavailable"){
                    
                    if unavai as! Int > unavahasChanged{
                        unavaLabel2.text = "\(unavai)"
                        unavahasChanged = unavai as! Int
                        totalImpact += unavai as! Int
                    }
                    
                }
                
                callStrike.text = "\(totalImpact)"
                
            }else{
                didshowOnce = true
                if let contct = UserDefaults.standard.object(forKey: "contact"){
                    madectct2.text = "\(contct)"
                    totalImpact += contct as! Int
                    contacthasChanged = contct as! Int
                }else{
                    madectct2.text = "0"
                }
                
                if let voice = UserDefaults.standard.object(forKey: "voicemail"){
                    leftVoice.text = "\(voice)"
                    totalImpact += voice as! Int
                    voicehasChanged = voice as! Int
                }else{
                    leftVoice.text = "0"
                }
                
                if let unavai = UserDefaults.standard.object(forKey: "unavailable"){
                    unavaLabel2.text = "\(unavai)"
                    unavahasChanged = unavai as! Int
                    totalImpact += unavai as! Int
                }else{
                    unavaLabel2.text = "0"
                }
                
                callStrike.text = "\(totalImpact)"
            }
            
            
          /*  if diffcComponent.year! > 0 {
                generalTitle.text = "Your current weekly call streak is \(diffcComponent.year!) week in a row. You’re on a roll!"
            }else if diffcComponent.month! > 0 && diffcComponent.year! < 0{
                generalTitle.text = "Your current weekly call streak is \(diffcComponent.month!) months in a row. You’re on a roll!"
            }else if diffcComponent.day! > 0 && diffcComponent.year! < 0 && diffcComponent.month! < 0{
                generalTitle.text = "Your current weekly call streak is \(diffcComponent.day!) days in a row. You’re on a roll!"
            }else{
                generalTitle.text = "LET YOUR VOICE BE HEARD KEEP CALLING!"
            }*/
            
        }else{
            generalTitle.text = "LET YOUR VOICE BE HEARD \nKEEP CALLING!"
        }

        
        
    }
    
    fileprivate func howmanyCalls(){
        
        let network = Network()
        let url  = "https://cotalkus.com/index.php/services/list_calls"
        let body = ""
        
        network.NetworkRequest(url: url, body: body) { (response, error) in
            if error == nil {
            if let dictionary = response as? [String:Any]{
                DispatchQueue.main.async {
                    
                    if let calls = dictionary["calls"]{
                        self.allCalls.text = "Total COTalk Calls: \(calls)"
                    }
                    
                    
                }
            }
            
            }else{
                print(error?.localizedDescription)
            }
        }
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
