//
//  NewMessageController.swift
//  gameofchats
//
//  Created by RayRainier on 1/21/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

}
