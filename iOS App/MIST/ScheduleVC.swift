//
//  ScheduleVC.swift
//  MIST
//
//  Created by Muhammad Doukmak on 12/27/16.
//  Copyright © 2016 Muhammad Doukmak. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseMessaging

class ScheduleVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Properties
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingString: UILabel!
    var items: [[String:Any]] = []
    var user: User!
    let dayArray = ["Friday","Saturday","Sunday"]
    let ref = FIRDatabase.database().reference(withPath: "mist_2017_event")
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    var scheduleItems:[[[String:Any]]] = [[],[],[]]
    var competitions:[String:Any]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        if let sched = UserDefaults.standard.value(forKey: "schedule") as? [[[String:Any]]] {
            if sched[0].isEmpty {
                self.myTable.isHidden = true
                self.loadingString.isHidden = false
                self.indicator.startAnimating()
                self.indicator.isHidden = false
            } else {
                self.scheduleItems = sched
                myTable.reloadData()
            }
        } else {
            self.myTable.isHidden = true
            self.loadingString.isHidden = false
            self.indicator.startAnimating()
            self.indicator.isHidden = false
        }
        let mistUser = UserDefaults.standard.value(forKey: "user") as! [String:Any]
        var registeredCompetitions:[String] = []
        if (mistUser["userType"] as! String == "competitor") {
            
            if let groupProject = mistUser["groupProject"] {
                if(groupProject as! String != "") {
                    registeredCompetitions.append(groupProject as! String)
                }
            }
            if let knowledge = mistUser["knowledge"] {
                if(knowledge as! String != "") {
                    registeredCompetitions.append(knowledge as! String)
                }
            }
            if let art = mistUser["art"] {
                if(art as! String != "") {
                    registeredCompetitions.append(art as! String)
                }
            }
            
            if let sports = mistUser["sports"] {
                if (sports as! String != "") {
                    registeredCompetitions.append(sports as! String)
                }
            }
            if let writing = mistUser["writing"] {
                if (writing as! String != "") {
                    registeredCompetitions.append(writing as! String)
                }
            }
            if let brackets = mistUser["brackets"] {
                if (brackets as! String != "") {
                    registeredCompetitions.append(brackets as! String)
                }
            }
        }
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var newSchedule:[[[String:Any]]] = [[],[],[]]
            for item in snapshot.children {
                let comp = Competition(snapshot: item as! FIRDataSnapshot)
                if (registeredCompetitions.contains(comp.name) || !comp.isCompetition /*comp.name == "Awards" || comp.name == "Lunch" || comp.name == "Dinner"*/) {
                    // User is registered for this competition
                    let formatter:DateFormatter = DateFormatter()
                    formatter.dateFormat="MM/dd/yy hh:mma"
                    formatter.timeZone = NSTimeZone.system
                    for location:[String:Any] in comp.locationArray {
                        var loc = location
                        loc["name"] = comp.name
                        let dateString = "\(location["date"]!)/17 \(location["startTime"]!)"
                        let date = formatter.date(from: dateString)
                        loc["date"] = date
                        let dformatter:DateFormatter = DateFormatter()
                        dformatter.timeZone = NSTimeZone.system
                        dformatter.dateFormat = "EEEE"
                        newSchedule[self.dayArray.index(of: dformatter.string(from: date!))!].append(loc)
                    }
                }
            }
            newSchedule[0].sort(by: {
                ($0["date"] as! Date) < ($1["date"] as! Date)
            })
            newSchedule[1].sort(by: {
                ($0["date"] as! Date) < ($1["date"] as! Date)
            })
            newSchedule[2].sort(by: {
                ($0["date"] as! Date) < ($1["date"] as! Date)
            })
            self.scheduleItems = newSchedule
            self.myTable.reloadData()
            self.myTable.isHidden = false
            self.loadingString.isHidden = true
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            UserDefaults.standard.set(newSchedule, forKey: "schedule")
            
        })
        FIRAuth.auth()!.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(data: user)
        }
        // Do any additional setup after loading the view.
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MISTTableViewCell
        cell.nameLabel?.text = "\((self.scheduleItems[indexPath.section][indexPath.row]["startTime"] as! String).replacingOccurrences(of: "am", with: "").replacingOccurrences(of: "pm", with: ""))-\(self.scheduleItems[indexPath.section][indexPath.row]["endTime"] as! String): \(self.scheduleItems[indexPath.section][indexPath.row]["name"] as! String)"
        var room = ""
        if let roomArray = self.scheduleItems[indexPath.section][indexPath.row]["roomNums"] as? [String] {
            for roomString in roomArray {
                room = room + roomString
                if roomString != roomArray.last! {
                    room = room + ", "
                }
            }
        }
        cell.numberLabel?.text = "\((self.scheduleItems[indexPath.section][indexPath.row]["location"] as! String)) \(room)"
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dayArray[section]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.scheduleItems[section].count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if let building = self.scheduleItems[indexPath.section][indexPath.row]["location"] as? String {
                delegate.showPin = building
            }
            self.tabBarController?.selectedIndex = 0
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
