//
//  RegisterViewController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/19/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var lblValidate: UILabel!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageLogo: UIImageView!
    

    @IBOutlet weak var txtUsername: UITextField!
    
   
    @IBOutlet weak var txtEmail: UITextField!
    
 
    
    @IBOutlet weak var txtPassword: UITextField!
    
  
    @IBOutlet weak var uiButtonRegiter: UIButton!
    
    @IBOutlet var selectImage: UITapGestureRecognizer!
    
    
    

    var messageController : ViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButton()
        setUpImageSelected()
        setTapToDissMissKeyBoard()
        setUpKeyBoardObservers()
        loading.isHidden = true
        lblValidate.isHidden = true
    }
    
    func setTapToDissMissKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
                       view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
         view.endEditing(true)
     }


    func setUpImageSelected() {
        selectImage = UITapGestureRecognizer(target: self, action: #selector(hanldeSelectImage))
        imageLogo.image = UIImage(named: "Chat.png")
        imageLogo.addGestureRecognizer(selectImage)
        imageLogo.translatesAutoresizingMaskIntoConstraints = false
        imageLogo.isUserInteractionEnabled = true
    }
    
   
   
    func setUpButton() {
        uiButtonRegiter.layer.borderWidth = 2
        uiButtonRegiter.layer.cornerRadius = 5
        uiButtonRegiter.layer.backgroundColor = UIColor.systemPink.cgColor
        uiButtonRegiter.layer.shadowColor = UIColor.systemPink.cgColor
        uiButtonRegiter.layer.borderColor = UIColor.systemPink.cgColor
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
    
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        print(result)
        return result
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        guard let username = txtUsername.text, let email = txtEmail.text, let password = txtPassword.text else {
                  return
              }
        
        if isValidEmail(testStr: email) == false {
            
            lblValidate.isHidden = false
            lblValidate.text = "Email không hợp lệ vui lòng thử lại"
            
        } else {
            loading.isHidden = false
            loading.startAnimating()
            lblValidate.isHidden = true
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                             if error != nil {
                             
                                 return
                             }
                             guard let uid = user?.user.uid else {
                                     return
                                 }
                             let imageName = NSUUID().uuidString
                             let storage = Storage.storage().reference().child("ProfileImage").child("\(imageName).jpg")
                             if let uploadData = self.imageLogo.image?.jpegData(compressionQuality: 0.1)
                             {
                                 storage.putData(uploadData, metadata: nil) { (metadata, error) in
                                 if error != nil {
                                  
                                     return
                                 }
                                storage.downloadURL(completion: { (url, err) in
                                           guard let downloadURL = url else {
                                             return
                                           }
                                 let image = downloadURL.absoluteString
                                 let values = ["username": username, "email": email, "profileImage" : image]
                                 self.regiterUser(uid: uid, values: values as [String : AnyObject])
                                     })
                                 }
                             }
                         }
        }
        
        
             
    }
    
    
    func regiterUser(uid: String, values : [String:AnyObject]) {
        
                var ref: DatabaseReference!
                ref = Database.database().reference(fromURL: "https://chatapp-manhld.firebaseio.com/")
                let usersReference = ref.child("users").child(uid)
                usersReference.updateChildValues(values) { (err, ref) in
                    if err != nil {
                            print(err!)
                            return
                    }
                    self.loading.stopAnimating()
                    self.loading.isHidden = true
                    self.navigationItem.title = values["name"] as? String 
                    self.dismiss(animated: true, completion: nil)
                }
    }
    
 
}

extension RegisterViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func hanldeSelectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromLibary : UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromLibary = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage
        {
            selectedImageFromLibary = originalImage
        }
        if let selectedImage = selectedImageFromLibary {
            imageLogo.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
}
