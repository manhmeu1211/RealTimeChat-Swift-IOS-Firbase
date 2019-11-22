//
//  NewMessageController.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/19/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UIViewController {
    
    var users = [Users]()
    var messageController : ViewController?
    @IBOutlet weak var messageTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTable.dataSource = self
          messageTable.delegate = self
          messageTable.register(UINib(nibName: "NewMessageCell", bundle: nil), forCellReuseIdentifier: "NewMessageCell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleCancel))
        fectchUser()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        messageTable.reloadData()
    }

    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func fectchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value  as? [String : Any] {
               let user = Users()
                print(snapshot)
                user.id = snapshot.key
                user.email = dictionary["email"] as? String
                user.username = dictionary["username"] as? String
                user.imageURL = dictionary["profileImage"] as? String
                self.users.append(user)
           
                DispatchQueue.main.async {
                     self.messageTable.reloadData()
                }
                

            }

        }, withCancel: nil)
        
    }

}

extension NewMessageController : UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTable.dequeueReusableCell(withIdentifier: "NewMessageCell", for: indexPath) as! NewMessageCell
        
        let user = users[indexPath.row]
        cell.lblName.text = user.username
        cell.lblEmail.text = user.email
        let queue = DispatchQueue(label: "loadImage")
        if let profileImageURL = user.imageURL {
            let url = profileImageURL
          
            queue.async {
                NetWorkService.getInstance.loadAnhFromInternet(url: url) { (data, message) in
                    if message == "Success" {
                        DispatchQueue.main.async {
                            cell.imgAvatar.image = UIImage(data: data)
                        }
                    } else {
                        ToastView.shared.short(self.view, txt_msg: "Cannot load Image")
                        return
                    }
                }
            }
        } else {
            queue.async {
                       NetWorkService.getInstance.loadAnhFromInternet(url: "https://virl.bc.ca/wp-content/uploads/2019/01/AccountIcon2.png") { (data, message) in
                           if message == "Success" {
                               DispatchQueue.main.async {
                                   cell.imgAvatar.image = UIImage(data: data)
                               }
                           } else {
                               ToastView.shared.short(self.view, txt_msg: "Cannot load Image")
                               return
                           }
                       }
                   }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatLogController()
        vc.user = users[indexPath.row]
      
        self.dismiss(animated: true) {
            self.messageController?.showChatController(user: self.users[indexPath.row])
        }
    }
    
    
}
	
