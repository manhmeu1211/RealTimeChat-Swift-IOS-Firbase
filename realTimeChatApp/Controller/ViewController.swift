//
//  ViewController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/19/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class ViewController: UITableViewController {
    
    var messages = [Message]()
    var messageDictionary = [String : Message]()
    var timer : Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        checkIfUserLogged()
        setUpNavItem()
        notiFication()
        
    }
    
      // MARK: - Func

    func setUpNavItem() {
          navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "log-out.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
              navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "chat-2.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleNewMessage))
    }
    
    func setUpTableView() {
        tableView.separatorStyle = .singleLine
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellid")
        tableView.separatorStyle = .none
        tableView.allowsSelectionDuringEditing = true
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageReference = Database.database().reference().child("message").child(messageId)
            messageReference.observeSingleEvent(of: .value, with: { (snapshop) in
                  if let dictionary = snapshop.value as? [String:Any] {
                                let message = Message()
                                message.fromID = dictionary["fromId"] as? String
                                message.text = dictionary["text"] as? String
                                message.timestamp = dictionary["timestamp"] as? String
                                message.toId = dictionary["toId"] as? String
                                if let toId = message.toId {
                                    self.messageDictionary[toId] = message
                                    self.messages = Array(self.messageDictionary.values)
                                }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                              
                            }
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (data) in
            self.messageDictionary.removeValue(forKey: data.key)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }, withCancel: nil)
        
    }
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
   
    func checkIfUserLogged() {
        let uid = Auth.auth().currentUser?.uid
               if uid == nil {
                   perform(#selector(handleLogout), with: nil, afterDelay: 0)
               } else {
            fectUserAndSetUpNavBarTitle()
        }
    }
    
    
    func fectUserAndSetUpNavBarTitle() {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (userdata) in
                          if let dictionary = userdata.value as? [String: AnyObject] {
                            let user = Users()
                            user.username = dictionary["username"] as? String
                            user.email = dictionary["email"] as? String
                            user.imageURL = dictionary["profileImage"] as? String
                            self.navigationItem.title = "\(user.username!)"
                          }
                      }, withCancel: nil)
    }

    func showChatController(user : Users) {
        let chatController = ChatLogController()
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    @objc func handleLogout() {
       do {
           try Auth.auth().signOut()
        } catch let logOutError {
           print(logOutError)
        }
        notiFication()
        let loginController = LoginController()
      loginController.messageController = self
        navigationController?.pushViewController(loginController, animated: true)
     }
    
    @objc func handleNewMessage() {
        let newMessageVC = NewMessageController()
        newMessageVC.messageController = self
        let navController = UINavigationController(rootViewController: newMessageVC)
        present(navController, animated: true, completion: nil)
    }
    
    
    
      // MARK: - TableView
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! UserCell
        let mess = messages[indexPath.row]
        cell.message = mess
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerid() else { return }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (data) in
            guard let dictionary = data.value as? [String : Any] else { return }
            print(dictionary)
            let user = Users()
            user.id = chatPartnerId
            user.username = dictionary["username"] as? String
            user.email = dictionary["email"] as? String
            user.imageURL = dictionary["profileImage"] as? String
            self.showChatController(user: user)
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        if let chatPartnerId = message.chatPartnerid() {
            Database.database().reference().child("user-message").child(uid).child(chatPartnerId).removeValue { (error, ref) in
                if error != nil {
                    print("Failed")
                    return
                }
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}


  // MARK: - Notification

extension ViewController : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    
    func notiFication() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Check new Message"
        content.body = "Tapped cho check your message"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
          repeats: false)

        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier,
                        content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
        if let error = error {
             print(error)
            }
          })
    }
}


