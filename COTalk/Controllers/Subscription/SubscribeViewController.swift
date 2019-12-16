//
//  SubscribeViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/11/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit
import SystemConfiguration

class SubscribeViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate,UIPickerViewDataSource {
    
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
    @IBOutlet weak var firstnameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var categoryText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    let network = Network()
    var categoryID = [""]
    var categoryName = ["----- Choose Category -----"]
    var selectedCategory = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstnameText.delegate = self
        lastnameText.delegate = self
        ageText.delegate = self
        genderText.delegate = self
        emailText.delegate = self
        categoryText.delegate = self
        
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        categoryText.inputView = categoryPicker
        
        if   DirectoryViewController.isConnectedToNetwor() == true {
            DispatchQueue.main.async {
                //self.activityIndicator.startAnimating()
                self.getCategories()
                
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        submitButton.layer.cornerRadius = 25.0
        cancelButton.layer.cornerRadius = 25.0
       
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submittAction(_ sender: UIButton) {
        if firstnameText.text! != "" && lastnameText.text != "" && emailText.text! != "" && categoryText.text! != ""{
           sendSubscription()
        }else{
            let alert = UIAlertController(title: "Required Information", message: "Please make sure you filled all required fields marked with *", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    fileprivate func sendSubscription(){
        activityIndicator.startAnimating()
        let url = "https://cotalkus.com/index.php/services/subscription"
        let body = "{\"first_name\": \"\(firstnameText.text!)\",\"last_name\": \"\(lastnameText.text!)\",\"gender\": \"\(genderText.text!)\",\"age\": \"\(ageText.text!)\",\"email\": \"\(emailText.text!)\",\"id_location\": \"1\",\"id_category\": \"\(selectedCategory)\"}"
        let network = Network()
        
        network.NetworkRequest(url: url, body: body) { (response, error) in
            
            
            if error == nil{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Thank You!", message: "Thank you for subscribing to CATEGORY NAME, we'll keep you up to date via E-mail so you can stay informed and keep helping your comunity.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }else{
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Something went wrong.", message: "An unexpected error occured while submitting your information", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.firstnameText) {
            self.lastnameText.becomeFirstResponder()
        }else if (textField == self.lastnameText) {
            self.ageText.becomeFirstResponder()
            
        } else if (textField == self.ageText) {
            self.genderText.becomeFirstResponder()
        }else if (textField == self.genderText) {
            self.emailText.becomeFirstResponder()
            
        } else if (textField == self.emailText) {
            self.categoryText.becomeFirstResponder()
        }else{
            
            print("what?")
            textField.resignFirstResponder()
            //deregisterFromKeyboardNotifications()
            
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryName[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = row
        categoryText.text = categoryName[row]
    }
    
    fileprivate func getCategories(){
        
        let url = "https://cotalkus.com/index.php/services/list_categories"
        let body = ""
        
        network.NetworkRequest(url: url, body: body) { (response, error) in
            if error == nil {
                if let dictionary = response as? [String:Any]{
                    
                    for category in dictionary["categories"] as! [Any]{
                        
                        let categoryChild = category as? [String:Any]
                        self.categoryID.append(categoryChild!["id"] as! String)
                        self.categoryName.append(categoryChild!["name_category"] as! String)
                    }
                    
                    print(self.categoryID)
                }
            }else{
                print(error?.localizedDescription)
            }
           
        }
    }
}
