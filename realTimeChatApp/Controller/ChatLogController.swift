//
//  ChatLogController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController {


    @IBOutlet weak var btnMicro: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var chatLogCollection: UICollectionView!
    @IBOutlet weak var heightViewSend: NSLayoutConstraint!
    @IBOutlet weak var txtMessage: UITextView!
    var containerContranst: NSLayoutConstraint!
    var messages = [Message]()
    var lastIndex : IndexPath!
    var user : Users? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    var bottomConstraint : NSLayoutConstraint?
    
     override func viewDidLoad() {
         super.viewDidLoad()
        setUpTextView()
        setUpCollectionView()
        dismissKeyboard()
        setUpKeyBoardObservers()
        observeMessages()
        messages.removeAll()
        chatLogCollection.reloadData()
        bottomConstraint = NSLayoutConstraint(item: bottomView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        textViewDidChange(txtMessage)
     }
    
    override func viewDidAppear(_ animated: Bool) {
         DispatchQueue.main.async {
            self.chatLogCollection.reloadData()
        }
    }
      // MARK: - Func
    
    func setUpTextView() {
        txtMessage.delegate = self
        txtMessage.isScrollEnabled = true
        txtMessage.layer.borderWidth = 0.5
        txtMessage.layer.cornerRadius = 5
        txtMessage.layer.borderColor = UIColor.systemGray.cgColor
        txtMessage.text = "Aa"
        txtMessage.textColor = UIColor.lightGray
        txtMessage.becomeFirstResponder()
        txtMessage.selectedTextRange = txtMessage.textRange(from: txtMessage.beginningOfDocument, to: txtMessage.beginningOfDocument)
    }
    
    func observeMessages() {
        
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
                if messageData.chatPartnerid() == self.user?.id {
                self.messages.append(messageData)
                    DispatchQueue.main.async {
                        self.chatLogCollection.reloadData()
                        print(self.messages)
                        self.chatLogCollection.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: false)
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func setUpKeyBoardObservers() {
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyBoardShow), name: UIResponder.keyboardWillHideNotification, object: nil)
      }
      
    
    @objc func handleKeyBoardShow(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        
        let keyboardFrame = keyboardSize.cgRectValue
        
        let isKeyBoardShowing = notification.name == UIResponder.keyboardWillShowNotification
        
        bottomConstraint?.constant = isKeyBoardShowing ? -keyboardFrame.height: 0

        UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.chatLogCollection.scrollToItem(at: IndexPath(item: self.messages.count - 1, section: 0), at: UICollectionView.ScrollPosition.bottom, animated: true)
        }
    }
    
  
    
    
    func dissmissKeyBoard() {
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
    
      func handleSend() {
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
    
    
      // MARK: - IBAction
 
    @IBAction func sendMesssage(_ sender: Any) {
        handleSend()
    }
}

 // MARK: - TextView

extension ChatLogController : UITextViewDelegate {
      func textViewDidBeginEditing(_ textView: UITextView) {
          if self.txtMessage.textColor == UIColor.lightGray {
              self.txtMessage.text = nil
              self.txtMessage.textColor = UIColor.black
        }
    }
    
      func textViewDidEndEditing(_ textView: UITextView) {
          if self.txtMessage.text.isEmpty {
              self.txtMessage.text = "Aa"
              self.txtMessage.textColor = UIColor.lightGray
        }
      }
      
      func textViewDidChange(_ textView: UITextView) {
        self.heightViewSend.constant = self.txtMessage.contentSize.height + 24
        
    }
}


 // MARK: - CollectionView

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
            cell.profileImage.isHidden = false
            if user?.imageURL != nil {
                let queue = DispatchQueue(label: "loadAvatar")
                queue.async {
                    NetWorkService.getInstance.loadImageFromInternet(url: self.user!.imageURL!) {
                        (data, error) in
                        DispatchQueue.main.async {
                            cell.profileImage.image = UIImage(data: data)
                        }
                    }
                }
            } else {
                cell.profileImage.image = UIImage(named: "Chat.png")
            }
          
            cell.bubbleView.backgroundColor = .systemGray6
            cell.textView.textColor = .black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 35
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height : CGFloat = 80
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 30
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        bottomView.endEditing(true)
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
