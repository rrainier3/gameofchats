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
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?

/*	THIS WAS NOT PROPERLY MAPPED TO FIREBASE snapshot
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
 */
    
    func chatPartnerId() -> String? {
    
    	return FromUid == FIRAuth.auth()?.currentUser?.uid ? ToUid : FromUid
    }
/*
	Introduce new init() to avoid crashing due to adding props
*/
	init(dictionary: [String: AnyObject]) {
        super.init()
        
        FromUid = dictionary["FromUid"] as? String
    	Timestamp = dictionary["Timestamp"] as? NSNumber
        ToUid = dictionary["ToUid"] as? String
        text = dictionary["text"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
    }
    
}
