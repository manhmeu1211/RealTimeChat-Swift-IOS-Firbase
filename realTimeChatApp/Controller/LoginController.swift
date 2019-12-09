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

    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var uiButtonLogin: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    
    var messageController : ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        navigationItem.setHidesBackButton(true, animated: true)
        setUpButton()
        dissmissKeyBoard()
        setUpKeyBoardObservers()
        loading.isHidden = true
        imgLogo.image = UIImage(named: "Chat.png")
    }
    
      // MARK: - Func
    
    func dissmissKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
                     view.addGestureRecognizer(tap)
    }
    
     @objc func dismissKeyboard() {
         view.endEditing(true)
     }

   
    func setUpButton() {
        uiButtonLogin.layer.borderWidth = 2
               uiButtonLogin.layer.cornerRadius = 5
               uiButtonLogin.layer.backgroundColor = UIColor.systemOrange.cgColor
               uiButtonLogin.layer.shadowColor = UIColor.systemOrange.cgColor
               uiButtonLogin.layer.borderColor = UIColor.systemOrange.cgColor
    }
    
    func setUpKeyBoardObservers() {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(handleKeyBoardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
          
        
    @objc func handleKeyBoardShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInset
    }
          
        
    @objc func handleKeyBoardHide(notification : Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
   
    
      // MARK: - IBAction
    
    
    @IBAction func btnLogin(_ sender: Any) {
        loading.isHidden = false
        loading.startAnimating()
        guard let email = txtEmail.text, let pass = txtPassword.text else {return}
        print(email, pass)
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error != nil {
                return
            }
            self.messageController?.fectUserAndSetUpNavBarTitle()
            let vc = ViewController()
            self.loading.stopAnimating()
            self.loading.isHidden = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        let vc = RegisterViewController()
        present(vc, animated: true, completion: nil)
    }
    
    
}
