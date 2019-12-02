//
//  RegisterV2Controller.swift
//  realTimeChatApp
//
//  Created by ManhLD on 12/2/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit

class RegisterV2Controller: UIViewController {

    @IBOutlet weak var btnRegisterUI: UIButton!
    

    @IBOutlet weak var imgRegister: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpButton()
        setUpKeyBoardObservers()
        imgRegister.image = UIImage(named: "Chat.png")
        imgRegister.contentMode = .scaleToFill
    }

    func setUpButton() {
        btnRegisterUI.layer.borderWidth = 2
               btnRegisterUI.layer.cornerRadius = 5
               btnRegisterUI.layer.backgroundColor = UIColor.systemOrange.cgColor
               btnRegisterUI.layer.shadowColor = UIColor.systemOrange.cgColor
               btnRegisterUI.layer.borderColor = UIColor.systemOrange.cgColor
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
}



