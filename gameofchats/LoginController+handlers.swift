//
//  LoginController+handlers.swift
//  gameofchats
//
//  Created by RayRainier on 1/22/17.
//  Copyright © 2017 RadiuSense. All rights reserved.
//

import UIKit

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
