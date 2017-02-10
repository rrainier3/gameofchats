//
//  ChatLogController.swift		- CHAT SCREEN ONE-ON-ONE
//  gameofchats
//
//  Created by RayRainier on 1/29/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase


class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {

    var user: User? {
        didSet {
        
            navigationItem.title = user?.name
            
            observeMessages()		// We are observing this user's chat!
            
        }
    }
    
    var messages = [Message]()		// Let's construct an array container for this user's messages
    
    func observeMessages() {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            //print(snapshot)
            
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                //print(snapshot)
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                
                let message = Message()
                // potential of crashing if keys don't match :: HAS TO MAP TO CLASS

                message.setValuesForKeys(dictionary)
                
                // do we need to attempt filtering anymore? no :)
                self.messages.append(message)
                
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                
        	}, withCancel: nil)
            
        }, withCancel: nil)
    }

    // create the input text field
    lazy var inputTextField:UITextField = {
    
    	let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self 	// this will enable Return key on Send
        return textField
        
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)

		// Implementing inputAccessoryView Override below:
    }
    
    override var inputAccessoryView: UIView? {
        get {
            // return inputContainerView from lazy var above
            // if code below was placed here - the textField loses
            // reference so this is the fix
            return inputContainerView
        }
    }

	// this is needed or else inputAccessoryView will not appear!
	override var canBecomeFirstResponder: Bool { return true }
    
    
	lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
        // create uploadImage icon
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        
		containerView.addSubview(uploadImageView)
        
        // x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // create the send button
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // handle control event = TouchUpInside
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        // x,y,w,h
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: +24).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // create the input text field
        containerView.addSubview(self.inputTextField)
        
        // x,y,w,h
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.bottomAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 24).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        // create the separatorLine
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 230, g: 230, b: 230)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        // x, y, w, h
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        return containerView
    }()
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
 
 		let message = messages[indexPath.item]
        cell.textView.text = message.text
        
		setupCell(cell: cell, message: message)
        
        // lets modify the bubbleView's width somehow?
        
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
    
    	if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        if message.FromUid == FIRAuth.auth()?.currentUser?.uid {
            // outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            // incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    // Enable landscape mode if needed
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    	var height: CGFloat = 80
        // get estimated height somehow??
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        // we replaced view.frame.width to prevent landscape centering of text

		let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
        //return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
        
    // handle Send Button onclick event
    func handleSend() {
    
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
    	let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970

        let values = ["text": inputTextField.text!, "ToUid": toId, "FromUid": fromId!, "Timestamp": timestamp] as [String : Any]

        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            // clear input field after SEND/RETURN key
            self.inputTextField.text = nil
            
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(fromId!).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId!)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
