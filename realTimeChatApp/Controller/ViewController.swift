//
//  ViewController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/19/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "log-out.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "chat-2.png"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleNewMessage))
        tableView.separatorStyle = .none
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellid")
        checkIfUserLogged()
        observeMessage()
        
    }
    
    func observeMessage(){
        let ref = Database.database().reference().child("message")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:Any] {
                let message = Message()
                message.fromID = dictionary["fromId"] as? String
                message.text = dictionary["text"] as? String
                message.timestamp = dictionary["timestamp"] as? String
                message.toId = dictionary["toId"] as? String
                self.messages.append(message)
                print(message.timestamp)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
        }, withCancel: nil)
    }

    func checkIfUserLogged(){
        let uid = Auth.auth().currentUser?.uid
               print(uid)
               if uid == nil {
                   perform(#selector(handleLogout), with: nil, afterDelay: 0)
               } else {
              
            fectUserAndSetUpNavBarTitle()
        }
    }
    
    func fectUserAndSetUpNavBarTitle(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                          if let dictionary = snapshot.value as? [String: AnyObject]{
                              
                            let user = Users()
                            user.username = dictionary["username"] as? String
                            user.email = dictionary["email"] as? String
                            user.imageURL = dictionary["profileImage"] as? String
                          
                            self.navigationItem.title = user.username
//                            self.setUpNavBarWithUser(user: user)
                          }
                          
                      }, withCancel: nil)
    }
//
//    func setUpNavBarWithUser(user : Users){
//
//        let titleView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
//        titleView.backgroundColor = .red
//
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        titleView.addSubview(containerView)
//
//
//
//        let profileImage = UIImageView()
//
//        profileImage.layer.masksToBounds = false
//        profileImage.layer.cornerRadius = profileImage.frame.height/2
//        profileImage.clipsToBounds = true
//
//
//        let queue = DispatchQueue(label: "loadHinh")
//        queue.async {
//            if let profileImageURL = user.imageURL {
//                      NetWorkService.getInstance.loadAnhFromInternet(url: profileImageURL) { (data, mess) in
//                          if mess == "Success" {
//                            DispatchQueue.main.async {
//                                profileImage.image = UIImage(data: data)
//                            }
//                          } else {
//                              profileImage.image = UIImage(named: "Chat.png")
//                          }
//                      }
//                  } else {
//                DispatchQueue.main.async {
//                    profileImage.image = UIImage(named: "Chat.png")
//                }
//
//                  }
//        }
//
//            containerView.addSubview(profileImage)
//               profileImage.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//               profileImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//               profileImage.widthAnchor.constraint(equalToConstant: 40).isActive = true
//               profileImage.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//
//
//        let nameLabel = UILabel()
//        containerView.addSubview(nameLabel)
//
//
//        nameLabel.text = user.username
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        nameLabel.leftAnchor.constraint(equalTo: profileImage.rightAnchor, constant: 8).isActive = true
//        nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
//        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        nameLabel.heightAnchor.constraint(equalTo: profileImage.heightAnchor).isActive = true
//
//        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//        self.navigationItem.titleView = titleView
//
//    }

    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        let loginController = LoginController()
        loginController.messageController = self
        present(loginController, animated: true, completion: nil)
     }
    
    
    @objc func handleNewMessage(){
        let newMessageVC = NewMessageController()
        newMessageVC.messageController = self
        let navController = UINavigationController(rootViewController: newMessageVC)
        present(navController, animated: true, completion: nil)
    }
    
    func showChatController(user : Users){
        let chatController = ChatLogController()
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    
    
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
}

