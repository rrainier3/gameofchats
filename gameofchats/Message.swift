//
//  Message.swift
//  gameofchats
//
//  Created by RayRainier on 1/30/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String? {
    
    	return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId

// Let's implement a one line code above
//
//        if fromId == FIRAuth.auth()?.currentUser?.uid {
//            return toId
//        } else {
//            return fromId
//        }
    }
    
}
