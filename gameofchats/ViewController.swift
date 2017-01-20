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
        
//        let ref = FIRDatabase.database().reference(fromURL: "https://gameofchats-5dc27.firebaseio.com/")
//        
//        ref.updateChildValues(["someValue": 123456])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
    }
    
    func handleLogout() {
    
    	let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
        
    }


}

