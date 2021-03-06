//
//  SelectRoleVC.swift
//  MIST
//
//  Created by Muhammad Doukmak on 12/26/16.
//  Copyright © 2016 Muhammad Doukmak. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging

class SelectRoleVC: UIViewController {
    var ref:FIRDatabaseReference?
    var didWarn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.ref = FIRDatabase.database().reference()
        if let user = FIRAuth.auth()?.currentUser {
            self.ref?.child("mist_2017_registered-user").child(user.uid).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! NSDictionary
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self.ref?.child("mist_2017_team").child((value.value(forKey: "team")! as? String)!).observe(.value, with: { (snapshot) in
                    let teamObject = snapshot.value as! NSDictionary
                    UserDefaults.standard.set(teamObject, forKey: "team")
                    self.performSegue(withIdentifier: "alreadyLoggedIn", sender: nil)
                })
            })
        } else {
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.isInternetAvailable() && !didWarn {
            let alert = UIAlertController(title: "No Internet Connection", message: "This app requires an internet connection to use most of its features. Please check your connection before you continue.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
            didWarn = true
        }
    }
    @IBAction func guestSelected(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "isGuest")
        self.performSegue(withIdentifier: "alreadyLoggedIn", sender: self)
        
    }
    @IBAction func studentSelected(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "isGuest")
    }
    @IBAction func coachSelected(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "isGuest")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "coach") {
            if segue.destination is LoginScreenVC {
                UserDefaults.standard.set("Coach", forKey: "role")
            } 
        } else if (segue.identifier == "student") {
            UserDefaults.standard.set("Student", forKey: "role")
        } else if (segue.identifier == "isGuest") {
            UserDefaults.standard.set(true, forKey: "isGuest")
            
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
