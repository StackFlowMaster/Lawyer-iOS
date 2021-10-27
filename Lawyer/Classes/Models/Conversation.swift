//
//  Conversation.swift
//  Lawyer
//
//  Created by Admin on 11/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class Conversation: NSObject {

    var conversationId: Int?
    var lawyer: Lawyer?
    var messages = [Message]()
    
    init(conversationId: Int) {
        self.conversationId = conversationId
    }
    
    func lastMessage() -> Message? {
        var message: Message?
        if (self.messages.count > 0) {
            message = self.messages.last
        }
        
        return message
    }
}
