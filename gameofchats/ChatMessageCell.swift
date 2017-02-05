//
//  ChatMessageCell.swift
//  gameofchats
//
//  Created by RayRainier on 2/5/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {

	let textView: UITextView = {
        
        let tv = UITextView()
        tv.text = "SAMPLE TEXT FOR NOW"
        tv.font = UIFont.systemFont(ofSize: 16)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.red
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
