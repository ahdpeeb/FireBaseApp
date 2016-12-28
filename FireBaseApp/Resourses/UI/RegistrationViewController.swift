//
//  RegistrationViewController.swift
//  FireBaseApp
//
//  Created by Nikola Andriiev on 23.12.16.
//  Copyright © 2016 Andriiev.Mykola. All rights reserved.
//

import UIKit
import Firebase
import Photos

class RegistrationViewController: UITableViewController {
    @IBOutlet var photoLibrary: UIButton!
    @IBOutlet var registration: UIButton!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var rightSwipe: UISwipeGestureRecognizer!
    
    fileprivate let imagePicker = UIImagePickerController()
    let imageStorage = FIRStorage.storage().reference(withPath: "avatarImages")
    var assetPhotoURL: URL? = nil
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureImagePicker()
    }
    
    // MARK: - Actions
    @IBAction func onPhotoLibraty(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onRegistration(_ sender: UIButton) {
        guard let email = emailTextField.text, let pass = passTextField.text else {
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: pass) { (user, error) in
            self.displayError(error)
            user.map { AppState.instance.user = User(userData: $0) }
            user.map { self.configurateUser($0) }
        }
    }
    
    @IBAction func onRightSwipe(_ sender: UISwipeGestureRecognizer) {
      _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Private methods
    private func configureImagePicker() {
        let picker = self.imagePicker
        picker.delegate = self
        picker.sourceType = .photoLibrary
    }
    
    func configurateUser(_ user: FIRUser) {
        let imageRef = self.avatarReference(fromUser: user)
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = self.nameTextField.text ?? (user.email?.components(separatedBy: "@")[0])
        changeRequest.photoURL = (imageRef?.fullPath).flatMap { return URL(string: $0) }
        imageRef.map { self.uploadToReference($0) }
        
        changeRequest.commitChanges() { (error) in
            self.displayError(error)
            let sharedUser =  AppState.instance.user
            sharedUser?.name = user.displayName
            sharedUser?.photoURL = user.photoURL
        }
    }
    
    private func avatarReference(fromUser user: FIRUser) -> FIRStorageReference? {
        guard let localULR = self.assetPhotoURL else { return nil }
        return imageStorage.child(user.uid + "." + localULR.pathExtension)
    }
    
    private func uploadToReference(_ reference : FIRStorageReference) {
        guard let assetURL = self.assetPhotoURL else { return }
        guard let asset = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil).firstObject else { return }
        PHImageManager.default().requestImage(for: asset,
                                        targetSize: CGSize(width: 200 , height: 200),
                                       contentMode: .aspectFill,
                                           options: nil)
        { (photo, info) in
            if let imageData = (photo.flatMap { return UIImagePNGRepresentation($0) }) {
                reference.put(imageData, metadata: nil, completion: { (metaData, error) in
                    self.displayError(error)
                })
            }
        }
    }
    
    private func displayError(_ error: Error?) {
        if let error = error {
            let controller = UIAlertController.errorController(massage: error.localizedDescription, alletAction: nil)
            self.present(controller, animated: true, completion: nil)
            return
        }
    }
}

extension RegistrationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.avatarImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.assetPhotoURL = info[UIImagePickerControllerReferenceURL] as? URL
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
