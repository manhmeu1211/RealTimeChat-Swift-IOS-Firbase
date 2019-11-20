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
    
    
    @IBOutlet weak var txtMessage: UITextField!
    
    var user : Users? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMessage.delegate = self
        chatLogCollection.dataSource = self
        chatLogCollection.delegate = self
        chatLogCollection.register(UINib(nibName: "ChatLogCell", bundle: nil), forCellWithReuseIdentifier: "ChatLogCell")

    }


    @IBAction func btnSend(_ sender: Any) {
      handleSend()
    }
    
    func handleSend(){
        let ref = Database.database().reference().child("message")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser?.uid
        let timestamp = String(NSDate().timeIntervalSince1970)
        let values = ["text" : txtMessage.text!, "toId": toId,
                      "fromId" : fromId, "timestamp": timestamp] as [String : Any]
              childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
}


extension ChatLogController: UICollectionViewDataSource, UICollectionViewDelegate  {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = chatLogCollection.dequeueReusableCell(withReuseIdentifier: "ChatLogCell", for: indexPath) as! ChatLogCell
        return cell
    }
    
    
    
}
