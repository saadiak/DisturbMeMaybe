//
//  StatusViewController.swift
//  DisturbMeMaybe
//
//  Created by Safiyah Lakhany on 3/28/20.
//  Copyright © 2020 Safiyah Lakhany. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class StatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   
    let redColor = UIColor(red: 254, green: 97, blue: 88, alpha: 1)
    let orangeColor = UIColor(red: 255, green: 188, blue: 48, alpha: 1)
    let greenColor = UIColor(red: 37, green: 202, blue: 65, alpha: 1)
    
    
    @IBOutlet var tableView: UITableView!
    var familyUIDs: [String?] = []
    var familyNames: [String?] = []
    var familyStatuses: [String?] = []
    var familyavailability: [Int?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.query()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.familyNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let colorArray = [greenColor, orangeColor, redColor]
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "StatusCell") as! StatusTableViewCell
        cell.nameLabel.text = self.familyNames[indexPath.row] as? String
        cell.statusLabel.text = self.familyStatuses[indexPath.row] as? String
        
        //cell.availabilityImage.backgroundColor = colorArray[self.familyavailability[indexPath.row] ?? 0 - 1]
        let colorVal = self.familyavailability[indexPath.row]
        if colorVal == 1 {
            // green
            cell.availabilityImage.tintColor = UIColor.green
        } else if colorVal == 2 {
            // yellow
            cell.availabilityImage.tintColor = UIColor.yellow
        } else if colorVal == 3 {
            // red
            cell.availabilityImage.tintColor = UIColor.red
        }
        return cell
    }
    
    func query(){
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser
        let currentUid = user!.uid
        db.collection("users").whereField("uid", isEqualTo: currentUid).getDocuments{ (querySnapshot, error) in
            if querySnapshot?.documents.count != 0 {
             let document = querySnapshot!.documents[0]
             let familyID = document.data()["familyID"] as? String
             db.collection("familyID").whereField("FamilyID", isEqualTo: familyID).getDocuments{ (querySnapshot, error) in
                if querySnapshot?.documents.count != 0
                {
                let document = querySnapshot!.documents[0]
                self.familyUIDs = document.data()["FamilyMembers"] as! [String?]
                    if self.familyUIDs.count != 0 {
                        for uid in self.familyUIDs{
                            if uid != currentUid {
                            db.collection("users").whereField("uid", isEqualTo: uid).getDocuments{
                              (querySnapshot, error) in
                                if querySnapshot?.documents.count != 0 {
                                    let document = querySnapshot!.documents[0]
                                    let name = document.data()["name"] as? String
                                    let status = document.data()["status"] as? String
                                    let availability = document.data()["availability"] as? Int
                                    self.familyNames.append(name)
                                    self.familyStatuses.append(status)
                                    self.familyavailability.append(availability)
                                    self.tableView.reloadData()
                            }
                                }
                        }
                            
                        }
                        db.collection("users").whereField("uid", isEqualTo: currentUid).getDocuments{
                          (querySnapshot, error) in
                            if querySnapshot?.documents.count != 0{
                                let document = querySnapshot!.documents[0]
                                let name = document.data()["name"] as? String
                                let status = document.data()["status"] as? String
                                let availability = document.data()["availability"] as? Int
                                self.familyNames.insert(name, at: 0)
                                self.familyStatuses.insert(status, at: 0)
                                self.familyavailability.insert(availability, at: 0)
                                self.tableView.reloadData()
                                }
                                
                            }
                            
                        
                    }
              }
                }
             }
        }
    }

    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
