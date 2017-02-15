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
  
    var fromUid: String?
    var toUid: String?
    var text: String?
    var timestamp: NSNumber?
    
    var imageUrl: String?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
    
    	return fromUid == FIRAuth.auth()?.currentUser?.uid ? toUid : fromUid
    }
/*
	Introduce new init() to avoid crashing due to adding props
*/
	init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromUid = dictionary["fromUid"] as? String
        toUid = dictionary["toUid"] as? String
        text = dictionary["text"] as? String
    	timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
    }
    
}
