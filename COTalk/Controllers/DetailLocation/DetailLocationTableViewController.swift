//
//  DetailLocationTableViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/3/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit
import SystemConfiguration

class DetailLocationTableViewController: UITableViewController {
    
    
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
    fileprivate var agentobj = Agents()
    fileprivate var agentsArray = [Agents]()
    fileprivate var topicDescription = ""
    fileprivate var topicName = ""
    fileprivate var topicScript = ""
    fileprivate var chachedImages = [String:UIImage]()
    fileprivate var imageDownloader = ImageDownloader()
    let formatText = TextFormatter()
    
    var topicID = ""
    var morethanEmpty = false
    let format = FormatString()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let setzipcode = UserDefaults.standard.object(forKey: "slctdZip"){
            
            if   DetailLocationTableViewController.isConnectedToNetwor() == true {
                DispatchQueue.main.async {
                    //self.activityIndicator.startAnimating()
                    self.getTopic(id: "\(self.topicID)", zip: "\(setzipcode)")
                    
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
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.5924921036, green: 0.5925064087, blue: 0.5924987197, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 2
        }else{
            if agentsArray.count > 0{
                morethanEmpty = true
                return agentsArray.count
            }else{
                morethanEmpty = false
                return 1
            }
            
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 0{
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath) as! TitleDetailTableViewCell
                
                cell.topicTitle.text = topicName
                
                // Configure the cell...
                
                return cell
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath) as! BodyDetailTableViewCell
                if topicDescription != ""{
                cell.topicDescription.attributedText = formatText.formatText(alltext: topicDescription)//topicDescription
                }
                // Configure the cell...
                
                return cell
            }
        }else{
            
            if morethanEmpty == true{
                let cell = tableView.dequeueReusableCell(withIdentifier: "repCell", for: indexPath) as! AgentTableViewCell
                
                let current = agentsArray[indexPath.row]
                cell.tag = indexPath.row
                cell.agentName.text = "\(current.first_name) \(current.last_name)"
                cell.agentPosition.text = current.type
                
                if current.photo != "" {
                    if let img = chachedImages[current.photo]{
                        cell.agentPhoto.image = img
                        
                    }else{
                        print(current.photo)
                        self.imageDownloader.imageURL = "https://cotalkus.com/library/images/agents/\(current.photo)"//self.uri
                        self.imageDownloader.getBImage(imageId: "News") { image in
                            func display_image(){
                                
                                if cell.tag == indexPath.row{
                                    cell.agentPhoto.image = image
                                    self.chachedImages[current.photo] = image
                                }else{
                                    cell.agentPhoto.image = #imageLiteral(resourceName: "User")
                                }
                                
                            }
                            
                            DispatchQueue.main.async(execute: display_image)
                            
                        }
                        
                        
                    }
                    
                }else{
                    
                    cell.agentPhoto.image = #imageLiteral(resourceName: "User")
                    
                }
                
                // Configure the cell...
                
                return cell
        
            }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "errorCell", for: indexPath)
                
                
            return cell
            
            }
            
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            let selected = agentsArray[indexPath.row]
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "CallVc") as! CallViewController
            vc.agentsArray = agentsArray
            vc.selectdId = indexPath.row
            vc.callScript = self.topicScript
            vc.callTitle = self.topicName
            vc.agentPhoto = selected.photo
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            
            
        }
        
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    private func getTopic(id:String,zip:String){
        activityIndicator.startAnimating()
        let url = "https://cotalkus.com/index.php/services/individual_topic_v2"
        
        let body = "{\"id\":\"\(id)\",\"zip\":\"\(zip)\"}"
        let network = Network()
        network.NetworkRequest(url: url, body: body) { (response, error) in
            if error == nil{
                
                if let dictionary = response as? [String:Any]{
                    
                    if let topic = dictionary["topic"] as? [String:Any]{
                        print("Topic Name \(String(describing: topic["name"]!))")
                        print("Topic Script \(String(describing: topic["script"]!))")
                        print("Topic Id \(String(describing: topic["id"]!))")
                        print("Topic Id_Category \(String(describing: topic["id_category"]!))")
                        print("Topic Description \(String(describing: topic["description"]!))")
                        self.topicDescription = self.format.giveSpaces(strChange: topic["description"]! as! String)
                        self.topicName = String(describing: topic["name"]!)
                        self.topicScript = String(describing: topic["script"]!)
                        
                    }else{
                        print("Data is not formatted in the correct format")
                    }
                    
                    
                    for agent in dictionary["agents"] as! [Any]{
                        
                        let agentinfo = agent as! [String:Any]
                        self.agentobj.first_name = agentinfo["first_name"] as! String
                        self.agentobj.last_name = agentinfo["last_name"] as! String
                        self.agentobj.phone = agentinfo["phone"] as! String
                        self.agentobj.type = agentinfo["type"] as! String
                        self.agentobj.agent_id = agentinfo["id"] as! String
                        self.agentobj.photo = agentinfo["photo"] as! String
                        self.agentsArray.append(self.agentobj)
                        self.agentobj = Agents()
                        
                    }
                    
                    
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
            print(response)
        }
        
    }
    
    
    
    
   

}
