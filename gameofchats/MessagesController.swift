//
//  MessagesController.swift		- USERS MESSAGES HISTORY SCREEN
//  gameofchats
//
//  Created by RayRainier on 1/18/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

	var user : User?
    
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
		checkIfUserIsLoggedIn()
        
        observeMessages()

    }


	func observeMessages() {
        
        let ref = FIRDatabase.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
        
        	if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message()
//                message.setValuesForKeys(dictionary)  <-- crashing : below is safer ->
				message.fromId = (dictionary["FromUid"] as! String)
                message.text = dictionary["Text"] as! String?
                message.timestamp = (dictionary["Timestamp"] as! NSNumber)
                message.toId = (dictionary["ToUid"] as! String)
                
                self.messages.append(message)

                // this will crash bec of background thread, so lets call this on
                // dispatch_asynch main thread
                //DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                //})
/*
	Here is Kelvin Fok solution for above DispatchQueue not working
    
                 OperationQueue.main.addOperation {
                 self.tableView.reloadData()
                 }﻿

*/

                print(message.text!)
                
            }
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let message = self.messages[indexPath.row]
        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
    
    func handleNewMessage() {
		let newMessageController = NewMessageController()
        
        newMessageController.messagesController = self
        
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        // check: user is not logged in!
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
				fetchUserAndSetupNavBarTitle()
        	}
        
    }
    
    func fetchUserAndSetupNavBarTitle() {

		guard let uid = FIRAuth.auth()?.currentUser?.uid else {
        
        	// for some reason uid = nil
            return
        }
        
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {(snapshot) in
            
            //print(snapshot)
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
    
    	let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //titleView.backgroundColor = UIColor.red
        
        let containerView = UIView()	// we need this view to resolve the issue of truncating title nav
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        // x,y, width, height constraints
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // x, y, width, height
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

		containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        // enable navigation bar titleView to trigger tap -> showChatController!
        //
        // Note: we don't need this anymore since we enable the navigationBarItem.right to go
        // 			to ChatLogController
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))

    }
    
    // We implement func showChatControllerForUser(user: User) and go to ChatLogController!
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    
    func showChatController() {
        
        // segue to ChatLogController programmatically!
        //
        // collectionViewLayout param is needed bec the call crashes because the target UICollectionViewController expects layout
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    func handleLogout() {
    
    	// sign out this user!
        do {
        	
            try FIRAuth.auth()?.signOut()
            
        } catch let logoutError {
        	
            print(logoutError)
        }
        
        
    	let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
        
    }


}

