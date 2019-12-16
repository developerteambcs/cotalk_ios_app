//
//  CallViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/9/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit
import SystemConfiguration

class CallViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
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

    @IBOutlet weak var repImageView: UIImageView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var stackContain: UIStackView!
    @IBOutlet weak var repTitle: UILabel!
    @IBOutlet weak var repPhone: UILabel!
    @IBOutlet weak var repName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var agentsArray = [Agents]()
    var callScript = ""
    var callTitle = ""
    var agentPhoto = ""
    var selectdId = 0
    let format = FormatString()
    let imageDownloader = ImageDownloader()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.5924921036, green: 0.5925064087, blue: 0.5924987197, alpha: 1)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print(selectdId)
        let current = agentsArray[selectdId]
        repName.text = "\(current.first_name) \(current.last_name)"
        repPhone.text = current.phone
        repTitle.text = current.type
        self.tableView.reloadData()
        self.repImageView.layer.cornerRadius = self.repImageView.frame.width / 2
        
        self.imageDownloader.imageURL = "https://cotalkus.com/library/images/agents/\(agentPhoto)"//self.uri
        self.imageDownloader.getBImage(imageId: "News") { image in
            func display_image(){
            
                self.repImageView.image = image
                
            }
            
            DispatchQueue.main.async(execute: display_image)
            
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callYourRep))
        repPhone.isUserInteractionEnabled = true
        repPhone.addGestureRecognizer(tapGesture)

        
    }

    override func viewDidAppear(_ animated: Bool) {
        print("Origin \(stackContain.frame.origin)")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "reptitleCell", for: indexPath) as! RepTilteTableViewCell
            
            cell.callTitle.text = callTitle
            
            // Configure the cell...
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "bodyCell", for: indexPath) as!  RepBodyTableViewCell
            
            // Configure the cell...
            print(format.giveSpaces(strChange: callScript))
            print(callScript)
            cell.callBody.text = callScript
            
            return cell
        }
    }
    
   /* func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var viewscrolled = scrollView.convert(stackContain.frame.origin, to: self.view).y + 42
        if(viewscrolled <= 72) {
            navigationController!.navigationBar.topItem!.title = repName.text
        }else if (viewscrolled >= 30){
            navigationController!.navigationBar.topItem!.title = " "
        }
    }*/
    @IBAction func makeCall(_ sender: UIBarButtonItem) {
        callYourRep()
    }
    
    @objc func callYourRep(){
        let current = agentsArray[selectdId]
        let alert = UIAlertController(title: "Ready?", message: "We’re about to place the call. When it starts dialing, turn on Speaker phone, then double tap home button and return to this app so you can read the script", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            print("tel://\(current.phone)")
            
            var  cleanedPhone = ""
            cleanedPhone = current.phone.replacingOccurrences(of: "(", with: "", options: .regularExpression, range: nil)
            cleanedPhone = cleanedPhone.replacingOccurrences(of: ")", with: "" , options: .regularExpression, range: nil)
            cleanedPhone = cleanedPhone.replacingOccurrences(of: " ", with: "", options: .regularExpression, range: nil)
            
            
            if let url = URL(string: "tel://\(cleanedPhone)") {
                DispatchQueue.main.async {
                    //UIApplication.shared.openURL(url)
                    
                    print("Should have call")
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
                
            }else{
                print("Error")
            }
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: Call Actions
    
    @IBAction func callUnavailable(_ sender: UIButton) {
        updateCallStatus(status: "unavailable")
        
        if let unavai = UserDefaults.standard.object(forKey: "unavailable"){
            var  val = unavai as! Int
            print("Previous Val\(val)")
            val += 1
            print(val)
            UserDefaults.standard.set(val, forKey: "unavailable")
        }else{
            UserDefaults.standard.set(1, forKey: "unavailable")
        }
        if selectdId < agentsArray.count - 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallVc") as! CallViewController
            vc.agentsArray = agentsArray
            vc.selectdId = selectdId + 1
            vc.callScript = self.callScript
            vc.callTitle = self.callTitle
            vc.agentPhoto = agentsArray[selectdId + 1].photo
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            successView.isHidden = false
        }
    }
    
    @IBAction func callVoiceMail(_ sender: UIButton) {
        updateCallStatus(status: "voicemail")
        UserDefaults.standard.set(0, forKey: "voicemail")
        if let voice = UserDefaults.standard.object(forKey: "voicemail"){
            var  val = voice as! Int
            print("Previous Val\(val)")
            val += 1
            UserDefaults.standard.set(val, forKey: "voicemail")
        }else{
            UserDefaults.standard.set(1, forKey: "voicemail")
        }
        if selectdId < agentsArray.count - 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallVc") as! CallViewController
            vc.agentsArray = agentsArray
            vc.selectdId = selectdId + 1
            vc.callScript = self.callScript
            vc.callTitle = self.callTitle
            vc.agentPhoto = agentsArray[selectdId + 1].photo
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            successView.isHidden = false
        }
    }
    
    @IBAction func callMadeContact(_ sender: UIButton) {
        updateCallStatus(status: "contact")
        if let contct = UserDefaults.standard.object(forKey: "contact"){
            var  val = contct as! Int
            print("Previous Val\(val)")
            val += 1
            UserDefaults.standard.set(val, forKey: "contact")
            
        }else{
            UserDefaults.standard.set(1, forKey: "contact")
        }
        if selectdId < agentsArray.count - 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallVc") as! CallViewController
            vc.agentsArray = agentsArray
            vc.selectdId = selectdId + 1
            vc.callScript = self.callScript
            vc.callTitle = self.callTitle
            vc.agentPhoto = agentsArray[selectdId + 1].photo
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            successView.isHidden = false
        }
    }
    
    
    @IBAction func skippedCall(_ sender: UIButton) {
        print(selectdId)
        if selectdId < agentsArray.count - 1 {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallVc") as! CallViewController
            vc.agentsArray = agentsArray
            vc.selectdId = selectdId + 1
            vc.callScript = self.callScript
            vc.callTitle = self.callTitle
            vc.agentPhoto = agentsArray[selectdId + 1].photo
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            successView.isHidden = false
        }
    }
    
    private func updateCallStatus(status:String){
        
        if   CallViewController.isConnectedToNetwor() == true {
            DispatchQueue.main.async {
                //self.activityIndicator.startAnimating()
                let current = self.agentsArray[self.selectdId]
                let url = "https://cotalkus.com/index.php/services/create_call"
                let body = "{\"status\": \"\(status)\",\"id_issue\": \"1\",\"id_agent\": \"\(current.agent_id)\"}"
                let network = Network()
                
                network.NetworkRequest(url: url, body: body) { (response, error) in
                    
                    if error == nil {
                        print("Success")
                    }
                }

                
            }
            
            
        }else {
            
            DispatchQueue.main.async(execute: {
                let alerts = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again later.",
                                               
                                               preferredStyle: .alert )
                alerts.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
                self.present(alerts, animated: true, completion: nil)
            });
            
        }
        
        
        
        
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
