//
//  Message.swift
//  Lawyer
//
//  Created by Admin on 11/5/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit

class Message: NSObject {

    var messageId: Int?
    var message: String?
    var image: UIImage?
    var time: String?
    var isIncoming: Bool?
    var lawyer: Lawyer?
    
    override init() {
    }
    
    init(messageId: Int,
         message: String,
         image: UIImage?,
         time: String,
         isIncoming: Bool,
         lawyer: Lawyer) {
        self.messageId = messageId
        self.message = message
        self.image = image
        self.time = time
        self.isIncoming = isIncoming
        self.lawyer = lawyer
    }
    
    func getMessageHeight() -> CGFloat {
        let size: CGSize = getMessageSize()
        let height:CGFloat = size.height
        
        return height
    }
    
    func getMessageSize() -> CGSize {
        var size: CGSize = CGSize.zero
        
        let maxWidth: CGFloat = 240.0
        
        if (self.image != nil) {
            size = self.image!.size
            
            if (self.image!.size.width > maxWidth) {
                let height: CGFloat = maxWidth * self.image!.size.height / self.image!.size.width
                size = CGSize(width: maxWidth, height: height)
            }
        }
        else {
            let font = UIFont.systemFont(ofSize: 15.0, weight: .light)
            size = self.message!.size(withConstrainedWidth: maxWidth, font: font)
            if (size.height < 30.0) {
                size = CGSize(width: size.width, height: 30.0)
            }
        }
        
        return size
    }
    
    // test functions
    
    class func message1() -> Message {
        let message = Message()
        message.messageId = 1
        message.message = "No worries, I’ve got it!"
        message.time = "12:50 pm"
        message.isIncoming = true
        message.lawyer = Lawyer.lawyer1()
        
        return message
    }
    
    class func message2() -> Message {
        let message = Message()
        message.messageId = 2
        message.message = "Okay, No Problem."
        message.time = "Yesterday"
        message.isIncoming = true
        
        let lawyer = Lawyer.lawyer2()
        lawyer.status = .Invisible
        message.lawyer = lawyer
        
        return message
    }
    
    class func message3() -> Message {
        let message = Message()
        message.messageId = 3
        message.message = "That’s why we’re here."
        message.time = "Tuesday"
        message.isIncoming = true
        
        let lawyer = Lawyer.lawyer3()
        lawyer.status = .Offline
        message.lawyer = lawyer
        
        return message
    }
    
    class func message4() -> Message {
        let message = Message()
        message.messageId = 4
        message.message = "Sounds good! Bring that paper"
        message.time = "Friday"
        message.isIncoming = true
        
        let lawyer = Lawyer.lawyer4()
        lawyer.status = .Offline
        message.lawyer = lawyer
        
        return message
    }
    
    class func messageList() -> [Message] {
        var messages = [Message]()
        messages.append(Message(messageId: 11,
                                message: "Perfect, if come here legally\nThen no one can force you.",
                                image: nil,
                                time: "12:00 pm",
                                isIncoming: true,
                                lawyer: Lawyer.lawyer1()))
        messages.append(Message(messageId: 12,
                                message: "Yes sir, I do come here\nlegally with work parmit Visa",
                                image: nil,
                                time: "12:05 pm",
                                isIncoming: false,
                                lawyer: Lawyer.lawyer1()))
        messages.append(Message(messageId: 13,
                                message: "Great! Feel free to send me a\nPicture of visa and other papers",
                                image: nil,
                                time: "12:10 pm",
                                isIncoming: true,
                                lawyer: Lawyer.lawyer1()))
        messages.append(Message(messageId: 14,
                                message: "Here are the visa copy",
                                image: nil,
                                time: "12:20 pm",
                                isIncoming: false,
                                lawyer: Lawyer.lawyer1()))
        messages.append(Message(messageId: 15,
                                message: "",
                                image: UIImage(named: "ic_image"),
                                time: "12:22 pm",
                                isIncoming: false,
                                lawyer: Lawyer.lawyer1()))
        
        return messages
    }
}
