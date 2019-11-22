//
//  Message.swift
//  realTimeChatApp
//
//  Created by ManhLD on 11/20/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    var fromID : String?
    var text: String?
    var timestamp : String?
    var toId : String?
    

      func chatPartnerid() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toId : fromID
      }
}
