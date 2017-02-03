//
//  NewMessageController.swift		- USERS LIST SCREEN
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
        
        // to be able to utilize a custom UserCell instead of default see UserCell implementation 
        // at the end of this file
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: {(snapshot) in

		if let dictionary = snapshot.value as? [String: AnyObject] {
            	let user = User()
            
                user.id = snapshot.key			// Grab the UID !!
            
                // if you use this setter, your app will crash if your class
                // properties don't match up with the firebase dictionary keys
                user.setValuesForKeys(dictionary)
            
                // the safer way to do is the ff
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
        // let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        // cell is giving UITableViewCell so we have to cast it to UserCell!
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        // overriding fonts
        cell.textLabel?.font = UIFont(name: "ProximaNova-Regular", size: 16)
        cell.detailTextLabel?.font = UIFont(name: "ProximaNova-Light", size: 12)

        
        if let profileImageUrl = user.profileImageUrl{
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: {
        
        	print("Dismiss Completed")
            // Goto Chat Log Controller!
            //self.messagesController?.showChatController()
            
            // Goto the improved Chat Log Controller!!            
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
            
        })
    }

}


