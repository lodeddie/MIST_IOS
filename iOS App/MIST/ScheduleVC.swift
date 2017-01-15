//
//  ScheduleVC.swift
//  MIST
//
//  Created by Muhammad Doukmak on 12/27/16.
//  Copyright © 2016 Muhammad Doukmak. All rights reserved.
//

import UIKit

class ScheduleVC: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
                // Do any additional setup after loading the view.
    }
    
    

    
    @IBAction func viewSchedule(_ sender: UIButton) {
        if let url = URL(string: "http://www.mistatlanta.com/s/School-Permission-Form.pdf") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func segChanged(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            self.performSegue(withIdentifier: "unwindToMIST", sender: self)
            
            self.segment.selectedSegmentIndex = 1
            // Send USER DATA HERE
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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