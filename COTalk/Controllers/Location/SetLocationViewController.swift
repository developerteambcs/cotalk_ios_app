//
//  SetLocationViewController.swift
//  COTalk
//
//  Created by BCS Media on 1/8/18.
//  Copyright © 2018 BCS Media. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation

class SetLocationViewController: UIViewController,CLLocationManagerDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var zipText: UITextField!
    @IBOutlet weak var submitB: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var locationB: UIButton!
    let locationManager = CLLocationManager()
    var updateDelegate : UpdateInformationDelegate?
    var updateTable : UpdateTableByZipDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        zipText.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        locationB.layer.cornerRadius = 25.0
        submitB.layer.cornerRadius = 25.0
        let border = CALayer()
        let width = CGFloat(1.5)
        border.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
        border.frame = CGRect(x: 0, y: lineView.frame.size.height - width, width: lineView.frame.width, height: 1.5)
        border.borderWidth = width
        lineView.layer.addSublayer(border)
        lineView.layer.masksToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func requestanduseLocation(_ sender: UIButton) {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            thereisNoLLocatAuth()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            getUsrLocation()
            break
        }
    }
    
    fileprivate func thereisNoLLocatAuth(){
        
        let alert = UIAlertController(title: "Location Services Off", message: "We don't have authorization to get your location, in order to get your Location go to Settings and enable Location Services On for COTalk", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        }))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            //disableMyLocationBasedFeatures()
            thereisNoLLocatAuth()
            break
            
        case .authorizedWhenInUse:
            //enableMyWhenInUseFeatures()
           // getUsrLocation()
            break
            
        case .notDetermined, .authorizedAlways:
            
            break
        }
    }
    
    func getUsrLocation(){
        self.activityIndicator.startAnimating()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocation(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
        print(location)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                let placeMark = placemarks?.last
               // print("\(String(describing: placeMark!.thoroughfare))\n\(String(describing: placeMark!.postalCode!)) \(String(describing: placeMark!.locality!))\n\(String(describing: placeMark!.country!))")
                if let nearlocale = placeMark!.thoroughfare! as? String{
                    print("Near Location \(nearlocale)")
                }
                
                //print("Postal Code \(String(describing: placeMark!.postalCode!))")
                
                if let zipCode = placeMark!.postalCode{
                    self.locationManager.stopUpdatingLocation()
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(zipCode, forKey: "slctdZip")
                        self.activityIndicator.stopAnimating()
                        if let delegate = self.updateDelegate{
                            delegate.getnewTopics()
                        }else if let otherdelegate = self.updateTable{
                            otherdelegate.updateViewZip()
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        let alert = UIAlertController(title: "Sorry", message: "We are unable to show topics outside the United States, but we are working hard to bring this app all over the world and support different causes.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.activityIndicator.stopAnimating()
        print(error)
    }
    @IBAction func saveZip(_ sender: UIButton) {
        UserDefaults.standard.set(zipText.text!, forKey: "slctdZip")
        self.activityIndicator.stopAnimating()
        if let delegate = self.updateDelegate{
            delegate.getnewTopics()
        }else if let otherdelegate = self.updateTable{
            otherdelegate.updateViewZip()
        }
        self.dismiss(animated: true, completion: nil)
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        view.endEditing(true)
    }
    
    
    @IBAction func NeedSupport(_ sender: UIButton) {
        
        if MFMailComposeViewController.canSendMail(){
            
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["admin@cotalkus.com"])
            composeVC.setSubject("We Need Support")
            self.present(composeVC, animated: true, completion: nil)
        }else {
            
            let reportview = UIAlertController(title: "You don't have an email account set up on your device.", message: "To send a new email please add an e-mail account to your iPhone.", preferredStyle: .alert)
            let oka = UIAlertAction(title: "Ok", style: .default, handler: nil)
            reportview.addAction(oka)
            self.present(reportview, animated: true, completion: nil)
            
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print(result)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
