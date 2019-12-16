//
//  DirectoryViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/31/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit
import SystemConfiguration

protocol UpdateTableByZipDelegate {
    func updateViewZip()
}

class DirectoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UpdateTableByZipDelegate {

    
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
    
    
    
    @IBOutlet weak var notfoundIndicator: UILabel!
    @IBOutlet weak var indicatorLabel: UILabel!
    @IBOutlet weak var primaryFilter: UISegmentedControl!
    @IBOutlet weak var secondFilter: UISegmentedControl!
    @IBOutlet weak var searchByZip: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var allmembers = [Agents]()
    var assemblyMembers = [Agents]()
    var councilMembers = [Agents]()
    var senateMembers = [Agents]()
    fileprivate var numofCells = 0
    var selectedOPT = ""
    var agent = Agents()
    fileprivate var chachedImages = [String:UIImage]()
    fileprivate var imageDownloader = ImageDownloader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if   DirectoryViewController.isConnectedToNetwor() == true {
            DispatchQueue.main.async {
                //self.activityIndicator.startAnimating()
                self.downloadCateogries()
                
            }
            
            
        }else {
            
            DispatchQueue.main.async(execute: {
                let alerts = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again later.",
                                               
                                               preferredStyle: .alert )
                alerts.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
                self.present(alerts, animated: true, completion: nil)
            });
            
        }
        
        // Do any additional setup after loading the view.
       // downloadCateogries()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        searchByZip.layer.cornerRadius = 25.0
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numofCells == 0{
            notfoundIndicator.isHidden = false
            notfoundIndicator.text = "No \(selectedOPT) information found for this Zip Code"
        }else {
            notfoundIndicator.isHidden = true
        }
        return numofCells
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "memberCell") as! MemberTableViewCell
        var current = Agents()
        cell.tag = indexPath.row
        if selectedOPT == "All" {
            current = allmembers[indexPath.row]
        }else if selectedOPT == "Assembly" {
            current = assemblyMembers[indexPath.row]
        }else if selectedOPT == "Council" {
            current = councilMembers[indexPath.row]
        }else{
            current = senateMembers[indexPath.row]
        }
        
        cell.memberName.text = "\(current.first_name) \(current.last_name)"
        cell.memberType.text = "\(current.type)"
        
        if current.photo != "" {
            if let img = chachedImages[current.photo]{
                cell.memberImage.image = img
                cell.activityIndicator.stopAnimating()
            }else{
                print(current.photo)
                self.imageDownloader.imageURL = "https://cotalkus.com/library/images/agents/\(current.photo)"
                self.imageDownloader.getBImage(imageId: "News") { image in
                    func display_image(){
                        
                        if cell.tag == indexPath.row{
                            cell.activityIndicator.stopAnimating()
                            cell.memberImage.image = image
                            self.chachedImages[current.photo] = image
                        }else{
                            cell.memberImage.image = #imageLiteral(resourceName: "User")
                            cell.activityIndicator.stopAnimating()
                        }
                        
                    }
                    
                    DispatchQueue.main.async(execute: display_image)
                    
                }
                
                
            }
            
        }else{
            cell.activityIndicator.stopAnimating()
            cell.memberImage.image = #imageLiteral(resourceName: "User")
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var current = Agents()
        
        if selectedOPT == "All" {
            current = allmembers[indexPath.row]
        }else if selectedOPT == "Assembly" {
            current = assemblyMembers[indexPath.row]
        }else if selectedOPT == "Council" {
            current = councilMembers[indexPath.row]
        }else{
            current = senateMembers[indexPath.row]
        }
        
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
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func primaryControl(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1{
            searchByZip.isHidden = false
            if let setzipcode = UserDefaults.standard.object(forKey: "slctdZip"){
                searchByZip.setTitle("Zip: \(setzipcode)", for: .normal)
                indicatorLabel.isHidden = true
                tableView.isHidden = false
                secondFilter.isHidden = false
                downloadbyZip(zip: setzipcode as! String)
                //getTopics(zip: "\(setzipcode)")
            }else{
                tableView.isHidden = true
                secondFilter.isHidden = true
                indicatorLabel.text = "Set your location in order to show topics near your area."
                indicatorLabel.isHidden = false
            }
        }else {
            
            if DirectoryViewController.isConnectedToNetwor(){
                
                DispatchQueue.main.async {
                    self.downloadCateogries()
                }
                
                
            }else{
                
                DispatchQueue.main.async {
                    let uialert = UIAlertController(title: "No Internet Connection", message: "We were unable to download the directory because it looks like you are not connected to the internet. Please make sure you have WI-FI on or you Cellular Data Activated for this app.", preferredStyle: .alert)
                    uialert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                    self.present(uialert, animated: true, completion: nil)
                }
                
            }
            
            tableView.isHidden = false
            secondFilter.isHidden = false
            searchByZip.isHidden = true
            indicatorLabel.isHidden = true
        }
    }
    
    @IBAction func secondaryControl(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            numofCells = allmembers.count
            selectedOPT = "All"
            chachedImages.removeAll()
            self.tableView.reloadData()
        }else if sender.selectedSegmentIndex == 1{
            numofCells = assemblyMembers.count
            selectedOPT = "Assembly"
            chachedImages.removeAll()
            self.tableView.reloadData()
        }else if sender.selectedSegmentIndex == 2{
            numofCells = councilMembers.count
            selectedOPT = "Council"
            chachedImages.removeAll()
            self.tableView.reloadData()
        }else{
            numofCells = senateMembers.count
            selectedOPT = "Senate"
            chachedImages.removeAll()
            self.tableView.reloadData()
        }
        
    
    }
    
    @IBAction func setZip(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetLocation") as! SetLocationViewController
        vc.updateTable = self
        self.present(vc, animated: true, completion: nil)
    }
    
   
    
    func updateViewZip(){
        if let setzipcode = UserDefaults.standard.object(forKey: "slctdZip"){
            searchByZip.setTitle("Zip: \(setzipcode)", for: .normal)
            indicatorLabel.isHidden = true
            tableView.isHidden = false
            secondFilter.isHidden = false
            if   DirectoryViewController.isConnectedToNetwor() == true {
                DispatchQueue.main.async {
                    //self.activityIndicator.startAnimating()
                    self.downloadbyZip(zip: "\(setzipcode)")
                    
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
    
    fileprivate func downloadbyZip(zip:String){
        
        let network = Network()
        let url = "https://cotalkus.com/index.php/services/directory_by_zip"
        let body = "{\"zip\":\"\(zip)\"}"
        network.NetworkRequest(url: url, body: body) { (response, error) in
            if error == nil {
                if let dictionary = response as? [String:Any]{
                    self.chachedImages.removeAll()
                     self.allmembers.removeAll()
                     self.assemblyMembers.removeAll()
                     self.councilMembers.removeAll()
                     self.senateMembers.removeAll()
                    for agent in dictionary["agents"] as! [Any] {
                        let insideAgent = agent as! [String:Any]
                        self.agent.first_name = insideAgent["first_name"] as! String
                        self.agent.last_name = insideAgent["last_name"] as! String
                        self.agent.phone = insideAgent["phone"] as! String
                        self.agent.type = insideAgent["type"] as! String
                        self.agent.photo = insideAgent["photo"] as! String
                        if "\(insideAgent["type"]!)" ==  "Assemblyman" || "\(insideAgent["type"]!)" ==  "Assemblyman " || "\(insideAgent["type"]!)" ==  "Assemblyman   "{
                            self.assemblyMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Assemblywoman" || "\(insideAgent["type"]!)" ==  "Assemblywoman "{
                            self.assemblyMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Assemblymember" || "\(insideAgent["type"]!)" ==  "Assemblymember  " || "\(insideAgent["type"]!)" ==  "Assemblymember " {
                            self.assemblyMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Council" || "\(insideAgent["type"]!)" ==  "Council  " || "\(insideAgent["type"]!)" ==  "Council   " || "\(insideAgent["type"]!)" ==  "Council "{
                            print(insideAgent["type"]!)
                            self.councilMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Senator" || "\(insideAgent["type"]!)" ==  "Senator  " || "\(insideAgent["type"]!)" ==  "Senator " || "\(insideAgent["type"]!)" ==  "Senator   "{
                            self.senateMembers.append(self.agent)
                        }else{
                            print("Unexpected Member dont know what to do next, just like michelle obama whe she got the gift from melania trump.")
                        }
                        
                        self.allmembers.append(self.agent)
                        self.agent = Agents()
                    }
                }
            }
            
            DispatchQueue.main.async {
                if self.selectedOPT != ""{
                    if self.selectedOPT == "Assembly"{
                        self.numofCells = self.assemblyMembers.count
                        self.tableView.reloadData()
                        
                    }else if self.selectedOPT == "Council"{
                        self.numofCells = self.councilMembers.count
                        self.tableView.reloadData()
                    }else if self.selectedOPT == "Senate"{
                        self.numofCells = self.senateMembers.count
                        self.tableView.reloadData()
                    }else {
                        self.numofCells = self.allmembers.count
                        self.tableView.reloadData()
                    }
                    
                }else {
                    self.selectedOPT = "All"
                    self.numofCells = self.allmembers.count
                    self.tableView.reloadData()
                }
                
            }


        }
        
    }
    
    
    fileprivate func downloadCateogries(){
        
        let network = Network()
        let url = "https://cotalkus.com/index.php/services/directory"
        let body = ""
        network.NetworkRequest(url: url, body: body) { (response, error) in
            if error == nil {
                if let dictionary = response as? [String:Any]{
                    self.allmembers.removeAll()
                    self.assemblyMembers.removeAll()
                    self.councilMembers.removeAll()
                    self.senateMembers.removeAll()
                    self.chachedImages.removeAll()
                    for agent in dictionary["agents"] as! [Any] {
                        let insideAgent = agent as! [String:Any]
                        self.agent.first_name = insideAgent["first_name"] as! String
                        self.agent.last_name = insideAgent["last_name"] as! String
                        self.agent.phone = insideAgent["phone"] as! String
                        self.agent.type = insideAgent["type"] as! String
                        self.agent.photo = insideAgent["photo"] as! String
                        if "\(insideAgent["type"]!)" ==  "Assemblyman" || "\(insideAgent["type"]!)" ==  "Assemblyman " || "\(insideAgent["type"]!)" ==  "Assemblyman   "{
                            self.assemblyMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Assemblywoman" || "\(insideAgent["type"]!)" ==  "Assemblywoman "{
                            self.assemblyMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Assemblymember" || "\(insideAgent["type"]!)" ==  "Assemblymember  " || "\(insideAgent["type"]!)" ==  "Assemblymember " {
                            self.assemblyMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Council" || "\(insideAgent["type"]!)" ==  "Council  " || "\(insideAgent["type"]!)" ==  "Council   " || "\(insideAgent["type"]!)" ==  "Council "{
                            print(insideAgent["type"]!)
                            self.councilMembers.append(self.agent)
                        }else if "\(insideAgent["type"]!)" ==  "Senator" || "\(insideAgent["type"]!)" ==  "Senator  " || "\(insideAgent["type"]!)" ==  "Senator " || "\(insideAgent["type"]!)" ==  "Senator   "{
                            self.senateMembers.append(self.agent)
                        }else{
                            print("Unexpected Member dont know what to do next, just like michelle obama whe she got the gift from melania trump.")
                        }
                        self.allmembers.append(self.agent)
                        self.agent = Agents()
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                if self.selectedOPT != ""{
                    if self.selectedOPT == "Assembly"{
                        self.numofCells = self.assemblyMembers.count
                        self.tableView.reloadData()
                        
                    }else if self.selectedOPT == "Council"{
                        self.numofCells = self.councilMembers.count
                        self.tableView.reloadData()
                    }else if self.selectedOPT == "Senate"{
                        self.numofCells = self.senateMembers.count
                        self.tableView.reloadData()
                    }else {
                        self.numofCells = self.allmembers.count
                        self.tableView.reloadData()
                    }
                    
                }else {
                    self.selectedOPT = "All"
                    self.numofCells = self.allmembers.count
                    self.tableView.reloadData()
                }
                
            }
            
        }
    }
    
    
    
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
