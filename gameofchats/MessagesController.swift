//
//  MessagesController.swift
//  gameofchats
//
//  Created by RayRainier on 1/18/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let image = UIImage(named: "new_message_icon")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        
		checkIfUserIsLoggedIn()
        
    }
    
    func handleNewMessage() {
		        
    }
    
    func checkIfUserIsLoggedIn() {
        // check: user is not logged in!
        if FIRAuth.auth()?.currentUser?.uid == nil {
            
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
			let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {(snapshot) in
            	
                //print(snapshot)
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
            	}, withCancel: nil)
        	}
        
    }
    
    func handleLogout() {
    
    	// sign out this user!
        do {
        	
            try FIRAuth.auth()?.signOut()
            
        } catch let logoutError {
        	
            print(logoutError)
        }
        
        
    	let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
        
    }


}

