//
//  Comment.swift
//  Lawyer
//
//  Created by Admin on 11/8/19.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import ObjectMapper

class Comment: Mappable {

    var commentId: Int?
    var comment: String?
    var time: String?
    var rating: Double?
    var user: CommentUser?
    
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.commentId <- map[G.lawyer_id]
        self.comment <- map[G.comment]
        self.time <- map[G.time]
        self.rating <- map[G.rating]
    }
    
    init(commentId: Int,
         comment: String,
         time: String,
         rating: Double,
         user: CommentUser) {
        self.commentId = commentId
        self.comment = comment
        self.time = time
        self.rating = rating
        self.user = user
    }
    
    class func testComments() -> [Comment] {
        var comments = [Comment]()
        let user = CommentUser.user1()
        for i in 0 ..< 10 {
            let comment = Comment(commentId: i, comment: "Ameri is Very helpful as usual I will continue to come back and back again. Thank you.", time: "Apr 2019", rating: 5.0, user: user)
            comments.append(comment)
        }
        return comments
    }
}
