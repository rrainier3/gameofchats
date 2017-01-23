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
        
        // to be able to utilize a custom UserCell instead of default see UserCell implementation 
        // at the end of this file
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
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
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
//        cell.imageView?.image = UIImage(named: "nedstark")
//        cell.imageView?.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl{
            
            //cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
            let url = NSURL(string: profileImageUrl)
            
            URLSession.shared.dataTask(with: url as! URL, completionHandler: { (data, response, error) in
            
            	// download hit an error so lets return out
                if error != nil {
                    print(error!)
                    return
                }
            	
                DispatchQueue.main.async {
//                    cell.imageView?.image = UIImage(data: data!)
                }
            
            }).resume()
        
        }
        
        return cell
    }

}

class UserCell: UITableViewCell {

	let profileImageView: UIImageView = {
        let imageView = UIImageView()
		imageView.image = UIImage(named: "nedstark")
        imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        // x,y,width,height constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
