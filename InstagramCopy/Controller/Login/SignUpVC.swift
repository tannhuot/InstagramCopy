//
//  SignUpVC.swift
//  InstagramCopy
//
//  Created by Huot on 11/7/19.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    // MARK: - Properties
    var imageSelected = false {
        didSet{
            formValidation()
        }
    }
    
    let profilePhotoBtn: UIButton = {
       let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        btn.addTarget(self, action: #selector(handlSelectProfilePhoto), for: .touchUpInside)
        return btn
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .rgb(red: 149, green: 204, blue: 244)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Login", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 17, green: 154, blue: 237)]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        btn.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        return btn
    }()
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        //Profile Photo
        view.addSubview(profilePhotoBtn)
        profilePhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        profilePhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //StackView
        configureViewComponets()
        
        //already have acc button
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 10, paddingRight: 20, width: 0, height: 80)
    }
    // MARK: - Handlers
    @objc func handleSignUp() {
        // properties
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        guard let userName = userNameTextField.text?.lowercased() else { return }
        showProgressIndicator(view: self.view, title: "Processing...")
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            //handle error
            if let error = error {
                hideProgressIndicator(view: self.view)
                print("Failed to create user", error.localizedDescription)
            }
            
            // upload profile image
            guard let profileImg = self.profilePhotoBtn.imageView?.image else {
                hideProgressIndicator(view: self.view)
                return
                
            }
            guard let uploadData =  profileImg.jpegData(compressionQuality: 0.3) else {
                hideProgressIndicator(view: self.view)
                return
                
            }
            let fileName = NSUUID().uuidString
            Storage.storage().reference().child("profile_image").child(fileName).putData(uploadData, metadata: nil, completion: { (metadata, error) in
                // handle error
                if let error = error {
                    hideProgressIndicator(view: self.view)
                    print("Failed to upload image to Firebase Storage with error", error.localizedDescription)
                }
                
                // profile image url
                Storage.storage().reference().child("profile_image").child(fileName).downloadURL(completion: { (url, error) in
                    if let error = error {
                        hideProgressIndicator(view: self.view)
                        print("failed to get image url", error.localizedDescription)
                        return
                    }
                    
                    if let url = url?.absoluteString {
                        let dictionaryValues = ["name": fullName,
                                                "username": userName,
                                                "profileImageUrl": url]
                        
                        let values = [user?.user.uid: dictionaryValues]
                        // save user info to database
                        Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                            hideProgressIndicator(view: self.view)
                            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
                            // configure view controllers in mainTabVC
                            mainTabVC.configureViewControllers()
                            // dismiss login controller
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            })
        }
    }

    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func formValidation() {
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullNameTextField.hasText,
            userNameTextField.hasText,
            imageSelected == true else {
                signUpButton.isEnabled = false
                signUpButton.backgroundColor = .rgb(red: 149, green: 204, blue: 244)
                return
        }
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = .getActiveButtonColor
    }
    
    @objc func handlSelectProfilePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func configureViewComponets() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField,userNameTextField, passwordTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        stackView.anchor(top: profilePhotoBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 240)
    }
}

extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //selected image
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        imageSelected = true
        //set ProfilePhoto with selected image
        profilePhotoBtn.layer.cornerRadius = profilePhotoBtn.frame.width/2
        profilePhotoBtn.layer.masksToBounds = true
        profilePhotoBtn.layer.borderColor = UIColor.black.cgColor
        profilePhotoBtn.layer.borderWidth = 2
        profilePhotoBtn.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}
