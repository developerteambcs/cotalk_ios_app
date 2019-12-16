//
//  ViewController.swift
//  COTalk
//
//  Created by BCS Media on 12/28/17.
//  Copyright © 2017 BCS Media. All rights reserved.
//

import UIKit
import SystemConfiguration

protocol UpdateInformationDelegate {
    func getnewTopics()
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UpdateInformationDelegate {
    
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
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var zipButton: UIButton!
    fileprivate var topic = Topics()
    fileprivate let newtworking = Network()
    @IBOutlet weak var tableView: UITableView!
    var topicforZip = [Topics]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let setzipcode = UserDefaults.standard.object(forKey: "slctdZip"){
            zipButton.setTitle("Zip: \(setzipcode)", for: .normal)
            if   ViewController.isConnectedToNetwor() == true {
                DispatchQueue.main.async {
                    //self.activityIndicator.startAnimating()
                    self.getTopics(zip: "\(setzipcode)")
                    
                }
                
                
            }else {
                
                DispatchQueue.main.async(execute: {
                    let alerts = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again later.",
                                                   
                                                   preferredStyle: .alert )
                    alerts.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alerts, animated: true, completion: nil)
                });
                
            }
            
        }else{
            indicatorLabel.text = "Set your location in order to show topics near your area."
        }
        
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let color = #colorLiteral(red: 0.3647058824, green: 0.3647058824, blue: 0.3647058824, alpha: 1)
        guard let customFont = UIFont(name: "ProximaNova-Regular", size: UIFont.labelFontSize) else {
            fatalError("""
        Failed to load the "ProximaNova-Regular" font.
        Make sure the font file is included in the project and the font name is spelled correctly.
        """
            )
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:color,NSAttributedString.Key.font:customFont]
        
        zipButton.layer.cornerRadius = 25.0
                
        
    }

    //MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicforZip.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell")
        let tpc = topicforZip[indexPath.row]
        cell?.detailTextLabel?.text = tpc.description
        cell?.textLabel?.text = tpc.name
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let current = topicforZip[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailLocation") as! DetailLocationTableViewController
        vc.topicID = current.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: TableView DataSource
    
    fileprivate func getTopics(zip:String){
        self.activityIndicator.startAnimating()
        let url = "https://cotalkus.com/index.php/services/list_topics_v2"
        let body = ""//"{\"zip\":\"\(zip)\"}"
        newtworking.NetworkRequest(url: url, body: body) { (response, error) in
            if error == nil{
                if let dictionary = response as? [String:Any]{
                    //print(dictionary)
                    
                    for topics in dictionary["topics"] as! [Any]{
                        print(topics)
                        let topici = topics as! [String:Any]
                        self.topic.name = topici["title"] as! String
                        self.topic.description = topici["sumary"] as! String
                        self.topic.id = topici["id_issue"] as! String
                        self.topicforZip.append(self.topic)
                        self.topic = Topics()
                    }
                }else{
                    print("ERROR")
                }
            }else{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func presentZipVc(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetLocation") as! SetLocationViewController
        vc.updateDelegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func getnewTopics() {
        
        topicforZip.removeAll()
        self.tableView.reloadData()
        if let setzipcode = UserDefaults.standard.object(forKey: "slctdZip"){
            zipButton.setTitle("Zip: \(setzipcode)", for: .normal)
            indicatorLabel.text = "What are the issues that most concern you as a Correction Officer?"
            getTopics(zip: "\(setzipcode)")
        }else{
            indicatorLabel.text = "Set your location in order to show topics near your area."
        }
        
        print("iscalled")
    }
    
    
    
    
   
    
    
    
    
    
    
}

