//
//  ChatLogController.swift		- CHAT SCREEN ONE-ON-ONE
//  gameofchats
//
//  Created by RayRainier on 1/29/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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

/*
		Avoiding crashes with modified Message::class
        
                let message = Message()
                // potential of crashing if keys don't match :: HAS TO MAP TO CLASS

                message.setValuesForKeys(dictionary)
*/
                // Note -> Message(dictionary: dictionary) new arg1
                self.messages.append(Message(dictionary: dictionary))
                
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
    // create the progressView for upload
    lazy var progressView: UIProgressView = {
    
    	let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        return progressView
    }()

    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupKeyboardObserver()

		// Implementing inputAccessoryView:UIView Override below:
    }

    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
    }
    
    func handleKeyboardDidShow() {

    	if messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
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
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
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
        
        // create the progressView
        containerView.addSubview(self.progressView)
        
        // x,y,w,h
        self.progressView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        self.progressView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        self.progressView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        self.progressView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        return containerView
    }()
    
    func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    	if let videoUrl = info[UIImagePickerControllerMediaURL] {

			// we selected a video!
            handleVideoSelectedForUrl(url: videoUrl as! NSURL)
            
        } else {
        
            // we selected an image!
			handleImageSelectedForInfo(info: info as [String : AnyObject])
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    private func handleVideoSelectedForUrl(url: NSURL) {

        let filename = NSUUID().uuidString + ".mp4"
        
        // lets store video in message_videos!
        let uploadTask = FIRStorage.storage().reference().child("message_videos").child(filename).putFile(url as URL, metadata: nil, completion: {(metadata, error) in
            
            if error != nil {
                print("Failed to upload video:", error!)
                return
            }
            
            if let videoUrl = metadata?.downloadURL()?.absoluteString {
                
                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    
                    self.uploadToFirebaseStorageUsingImage(thumbnailImage, completion: { (imageUrl) in
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                        
                    })
                }
            }
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
        
        	self.progressView.isHidden = false
            self.progressView.setProgress(self.progressView.progress + 0.1, animated: true)
        	
            // This can now be commented out with our UIProgressView impl
/*
        	if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
*/
        }
        
        uploadTask.observe(.success) { (snapshot) in
        
        	self.progressView.isHidden = true
            //self.progressView.removeFromSuperview() -- don't know if we need to

/*			This can now be commented out with our UIProgressView impl

            self.navigationItem.title = self.user?.name
*/
        }
    }
    
    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage? {
    
    	let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
        	let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil	)
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
    }
    
    private func handleImageSelectedForInfo(info: [String: AnyObject]) {

        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
            //print(editedImage)
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
            
            //print((originalImage)
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            uploadToFirebaseStorageUsingImage(selectedImage, completion: { (imageUrl) in
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
            
            
        }
    }
/*
     func hardProcessingWithString(input: String, completion: (result: String) -> Void) {
     ...
     completion("we finished!")
     }
*/
    
    fileprivate func uploadToFirebaseStorageUsingImage(_ image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
       
    	let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image: ", error!)
                }
                
                // On Success
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    completion(imageUrl)
                }
            })
        }
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
            
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: Any]) {
    
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = NSDate().timeIntervalSince1970
        
        var values: [String: Any] = ["ToUid": toId, "FromUid": fromId!, "timestamp": timestamp]
        
        // Append properties dictionary onto values[] array
        // key $0, value $1
        properties.forEach {(values[$0] = $1)}
        
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
    
    // handle Send Button onclick event
    func handleSend() {
        
        // fix to not accept blanks!
        guard let input = inputTextField.text, input.characters.count > 0 else { return }
        
        let properties = ["text": inputTextField.text!]
        
        sendMessageWithProperties(properties: properties)
        
	}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    
        dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        // give this cell a chatLogController reference
        cell.chatLogController = self
 
 		let message = messages[indexPath.item]
        cell.textView.text = message.text
        
		setupCell(cell: cell, message: message)
        
        if let text = message.text {
            // lets modify the bubbleView's width somehow?
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            // fall here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        // display Play button if videoUrl=true
        cell.playButton.isHidden = message.videoUrl == nil
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
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    
    // Enable landscape mode if needed
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    	var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // h1/w1 = h2/w2
            // solve for h1
            // h1 = h2 / w2 * w1	note: 200 = bubbleWidth
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        // we replaced view.frame.width to prevent landscape centering of text

		let width = UIScreen.main.bounds.width
        
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // Our custom zooming logic
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
    
    	self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
    
    
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        // enable tap-gesture by enabling user-interaction
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
        	blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
        	blackBackgroundView?.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                // turn off the inputContainerView!
                self.inputContainerView.alpha = 0
                
                // math h2/w2 = h1/w1
                // h2 = h1 / w2 * w1
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: {(completed) in
            		// do nothing
            })
        }
    }
    
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            // need to animate back out to controller
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
			
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
}
