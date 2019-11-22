//
//  LoginController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/19/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    
    
 
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var uiButtonLogin: UIButton!
    
    @IBOutlet weak var imgLogo: UIImageView!
    var messageController : ViewController?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        setUpButton()
        txtUserName.isHidden = true
        imgLogo.image = UIImage(named: "Chat.png")
        
        dismissKeyboard()
      
    }
    
    func dissmissKeyBoard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
                     view.addGestureRecognizer(tap)
    }
    
     @objc func dismissKeyboard() {
         view.endEditing(true)
     }

   
    func setUpButton(){
        
        uiButtonLogin.layer.borderWidth = 2
               uiButtonLogin.layer.cornerRadius = 5
               uiButtonLogin.layer.backgroundColor = UIColor.systemOrange.cgColor
               uiButtonLogin.layer.shadowColor = UIColor.systemOrange.cgColor
               uiButtonLogin.layer.borderColor = UIColor.systemOrange.cgColor
    }
    
    @IBAction func btnLogin(_ sender: Any) {
        guard let email = txtEmail.text, let pass = txtPassword.text else {return}
        
        print(email, pass)
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error != nil {
                return
            }
            self.messageController?.fectUserAndSetUpNavBarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        
        let vc = RegisterViewController()
        present(vc, animated: true, completion: nil)
    }
}
