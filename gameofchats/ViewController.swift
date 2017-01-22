//
//  ViewController.swift
//  gameofchats
//
//  Created by RayRainier on 1/18/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // check: user is not logged in!
        if FIRAuth.auth()?.currentUser?.uid == nil {
        
        	perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
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

