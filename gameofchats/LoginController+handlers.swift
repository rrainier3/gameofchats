//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by RayRainier on 1/22/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successfully authenticated user!
            
            // lets Save an image to Storage
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            
            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                
                storageRef.put(uploadData, metadata: nil, completion: {(metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                    }
                    
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]

					// lets Save user data to Firebase database!
                	self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                }
        
                    print(metadata!)
                    
             })  // storageReg.put
             
        }  // uploadData
            
            
        }) // FIRAuth.auth()?.creatUser
        
        
    }  // end of handleRegister()
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://gameofchats-5dc27.firebaseio.com/")
        
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            
            self.messagesController.fetchUserAndSetupNavBarTitle()
            
            self.dismiss(animated: true, completion: nil)
            
            print("Saved user successfully into Firebase db")
            
        })
    }

    
    func handleSelectProfileImageView() {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    	var selectedImageFromPicker: UIImage?
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
            //print(editedImage)
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
	        
            selectedImageFromPicker = originalImage
            
            //print((originalImage)
    	}
        
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        print("Canceled Picker!")
        dismiss(animated: true, completion: nil)
    }
    
}
