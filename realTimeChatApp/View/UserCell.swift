//
//  UserCell.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message : Message? {
        didSet {
            setUpNameAndAvatar()
            detailTextLabel?.text = message?.text
            self.timeLabel.text = message?.timestamp
        }
    }
    
    
    func setUpNameAndAvatar(){
     
        if let id = message?.chatPartnerid(){
                          let ref = Database.database().reference().child("users").child(id)
                          ref.observe(.value, with: { (snapshot) in
                              if let dictionary = snapshot.value as? [String: Any] {
                                self.textLabel?.text = dictionary["username"] as? String
                                  if let profileImgURL = dictionary["profileImage"]  as? String {
                                      let queue = DispatchQueue(label: "LoadHinh")
                                   
                                      queue.async {
                                          NetWorkService.getInstance.loadAnhFromInternet(url: profileImgURL) { (data, mess) in
                                              if mess == "Success" {
                                                  DispatchQueue.main.async {
                                                    self.profileImageView.image = UIImage(data: data)
                                                      }
                                              } else {
                                              }
                                          }
                                      }
                                  } else
                                  {
                                    DispatchQueue.main.async {
                                        self.profileImageView.image = UIImage(named: "Chat.png")
                                    }
                                }
                              }
                          }, withCancel: nil)
                      }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 90, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 90, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        detailTextLabel?.numberOfLines = 1
       
    }
    
    let profileImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = false
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    let timeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
   
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 125).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

  
        
    }
    
}
