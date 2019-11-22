//
//  ChatLogController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var chatLogCollection: UICollectionView!
    
    
    @IBOutlet weak var btnSendUi: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
   
    
    @IBOutlet weak var containerView: UIView!
    var containerContranst: NSLayoutConstraint!
    
    var messages = [Message]()
    
    var user : Users? {
        didSet {
            navigationItem.title = user?.username
            observeMessages()
        }
    }
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagRef = Database.database().reference().child("user-message").child(uid)
        userMessagRef.observe(.childAdded, with: { (data) in
            let messageId = data.key
            let messageRef = Database.database().reference().child("message").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (dataMessage) in
                guard let dictionaryMessage = dataMessage.value as? [String : Any] else {
                    return
                }
              
                let messageData = Message()
                messageData.fromID = dictionaryMessage["fromId"] as? String
                messageData.text = dictionaryMessage["text"] as? String
                messageData.timestamp = dictionaryMessage["timestamp"] as? String
                messageData.toId = dictionaryMessage["toId"] as? String
                if messageData.chatPartnerid() == self.user?.id{
                    self.messages.append(messageData)
                    DispatchQueue.main.async {
                        self.chatLogCollection.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMessage.delegate = self
        setUpCollectionView()
        dismissKeyboard()
        setUpKeyBoardObservers()
        containerContranst = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerContranst.isActive = true
        
    }

    
    
    
    func setUpKeyBoardObservers(){
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyBoardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    
      }
      
    
    
      @objc func handleKeyBoardShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardFrame = keyboardSize.cgRectValue
        
          if self.view.frame.origin.y == 0{
                  self.view.frame.origin.y -= keyboardFrame.height
              }
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                  self.view.layoutIfNeeded()
              })
      }
    
    @objc func handleKeyBoardHide(notification : Notification){
    guard let userInfo = notification.userInfo else { return }
        
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardFrame = keyboardSize.cgRectValue
        
          if self.view.frame.origin.y != 0{
                  self.view.frame.origin.y += keyboardFrame.height
              }
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                  self.view.layoutIfNeeded()
              })
    }
    
    
    
    func dissmissKeyBoard(){
          let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
                       view.addGestureRecognizer(tap)
      }
      
       @objc func dismissKeyboard() {
           view.endEditing(true)
       }

     
    
    func setUpCollectionView() {
        chatLogCollection.dataSource = self
        chatLogCollection.delegate = self
        chatLogCollection.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        chatLogCollection.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        chatLogCollection.alwaysBounceVertical = true
        chatLogCollection.backgroundColor = .white
        chatLogCollection.register(ChatLogCell.self, forCellWithReuseIdentifier: "ChatLogCell")
          let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        chatLogCollection.addGestureRecognizer(tap)
        
    }
    
 

    @IBAction func btnSend(_ sender: Any) {
      
      handleSend()
    }
    
    func handleSend(){
        if txtMessage.text!.isEmpty {
        } else {
             let ref = Database.database().reference().child("message")
                    let childRef = ref.childByAutoId()
                    let toId = user!.id!
                    let fromId = Auth.auth().currentUser!.uid
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                    let timestamp = dateFormatter.string(from: NSDate() as Date)
                    let values = ["text" : txtMessage.text!, "toId": toId,
                                  "fromId" : fromId, "timestamp": timestamp] as [String : Any]
            //              childRef.updateChildValues(values)
                     
                    childRef.updateChildValues(values) { (err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                        guard let messageId = childRef.key else { return }
                        let userMessagesRef = Database.database().reference().child("user-message").child(fromId).child(messageId)
                            userMessagesRef.setValue(1)
                        let recipientUserMessagesRef = Database.database().reference().child("user-message").child(toId).child(messageId)
                                  recipientUserMessagesRef.setValue(1)
                        self.txtMessage.text = ""
                    }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
}


extension ChatLogController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chatLogCollection.dequeueReusableCell(withReuseIdentifier: "ChatLogCell", for: indexPath) as! ChatLogCell
        let message = messages[indexPath.row]
        cell.textView.text = message.text
        if message.fromID == Auth.auth().currentUser?.uid{
            cell.bubbleView.backgroundColor = .blue
            cell.profileImage.isHidden = true
            cell.textView.textColor = .white
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        } else {
            cell.bubbleView.backgroundColor = .systemGray6
            cell.textView.textColor = .black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 30
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 30
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        chatLogCollection.collectionViewLayout.invalidateLayout()
    }
}
