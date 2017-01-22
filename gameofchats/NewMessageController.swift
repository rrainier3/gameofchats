//
//  NewMessageController.swift
//  gameofchats
//
//  Created by RayRainier on 1/21/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

	let cellId = "cellId"
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in

		if let dictionary = snapshot.value as? [String: AnyObject] {
            	let user = User()
            
                // if you use this setter, your app will crash if your class
                // properties don't match up with the firebase dictionary keys
                user.setValuesForKeys(dictionary)
            
                // the proper is to do ff
                // user.name = dictionary["name"]
                // user.name = dictionary["email"]
            
                //print(user.name!, user.email!)
            
                // Add this user to the array of users[]
                self.users.append(user)
            
                // to avoid crash on reloadData() we have to call dispatch_asynch for background thread
            	DispatchQueue.main.async(execute: {
                	self.tableView.reloadData()
            	})
            }
        
            
            }, withCancel: nil)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // let us use a hack for now because we need to dequeue our cells for memory efficiency
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        return cell
    }

}
