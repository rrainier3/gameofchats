//
//  ChatInputContainerView.swift
//  gameofchats
//
//  Created by RayRainier on 2/15/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit

class ChatInputContainerView: UIView, UITextFieldDelegate {

	var chatLogController: ChatLogController? {
    
    	// This didSet{} was a result of refactoring of ChatLogController
        didSet {
        
            sendButton.addTarget(chatLogController, action: #selector(ChatLogController.handleSend), for: .touchUpInside)
            
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: chatLogController, action: #selector(ChatLogController.handleUploadTap)))

        }
    }
    
    // create the input text field
    lazy var inputTextField:UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self 	// this will enable Return key on Send
        return textField
        
    }()
    
    // create the progressView for upload
    lazy var progressView: UIProgressView = {
        
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        return progressView
    }()
    
    // create the send button
    let sendButton: UIButton = {
    	let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        return sendButton
    }()
    

    // create uploadImageView
    let uploadImageView: UIImageView = {
    	let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
    	return uploadImageView
    }()

    
    override init(frame: CGRect) {
    	super.init(frame: frame)
        
        backgroundColor = .white
        
        // setup uploadImage icon
        addSubview(uploadImageView)
        
        // x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // setup the send button        
        addSubview(sendButton)
        
        // x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: centerYAnchor, constant: +24).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // create the input text field
        addSubview(self.inputTextField)
        
        // x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 24).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // create the separatorLine
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorLineView)
        // x, y, w, h
        separatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // create the progressView
        addSubview(self.progressView)
        
        // x,y,w,h
        self.progressView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.progressView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        chatLogController?.handleSend()
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
