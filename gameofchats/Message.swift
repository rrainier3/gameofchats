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
  
    var FromUid: String?
    var Timestamp: NSNumber?
    var ToUid: String?
    var text: String?
    
    var imageUrl: String?

/*	THIS WAS NOT PROPERLY MAPPED TO FIREBASE snapshot
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
 */
    
    func chatPartnerId() -> String? {
    
    	return FromUid == FIRAuth.auth()?.currentUser?.uid ? ToUid : FromUid

// Let's implement a one line code above
//
//        if fromId == FIRAuth.auth()?.currentUser?.uid {
//            return toId
//        } else {
//            return fromId
//        }
    }
    
}
