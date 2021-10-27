//
//  UsersDataSource.swift
//  Lawyer
//
//  Created by Admin on 2/13/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Quickblox

class UsersDataSource: NSObject {
    
    // MARK: - Properties
    var selectedUsers = [QBUUser]()
    private var users = [QBUUser]()
    
    func update(users: [QBUUser]) {
        for chatUser in users {
            update(user:chatUser)
        }
    }
    
    func update(user: QBUUser) {
        if let localUser = users.filter({ $0.id == user.id }).first {
            //Update local User
            localUser.fullName = user.fullName
            localUser.updatedAt = user.updatedAt
            return
        }
        users.append(user)
    }
        
    func appendSelectedUser(user: QBUUser?) {
        guard let user = user else {
            return
        }
        
        if !selectedUsers.contains(user) {
//            selectedUsers.removeAll(where: { element in element == user })
            selectedUsers.append(user)
        }
    }
    
    func selectUser(at indexPath: IndexPath) {
        
        let user = usersSortedByLastSeen()[indexPath.row]
        if selectedUsers.contains(user) {
            selectedUsers.removeAll(where: { element in element == user })
        } else {
            selectedUsers.append(user)
        }
    }
    
    func user(withID ID: UInt) -> QBUUser? {
        return users.filter{ $0.id == ID }.first
    }
    
    
    func ids(forUsers users: [QBUUser]) -> [NSNumber] {
        
        var result = [NSNumber]()
        
        for user in users {
            result.append(NSNumber(value: user.id))
        }
        return result
    }
    
    func removeAllUsers() {
        users.removeAll()
    }
    
    func usersSortedByFullName() -> [QBUUser] {
        let sortedUsers = unsortedUsersWithoutMe().sorted(by: {
            guard let firstUserName = $0.fullName, let secondUserName = $1.fullName else {
                return false
            }
            return firstUserName < secondUserName
        })
        return sortedUsers
    }
    
    func usersSortedByLastSeen() -> [QBUUser] {
        let sortedUsers = unsortedUsersWithoutMe().sorted(by: {
            guard let firstUpdatedAt = $0.updatedAt, let secondUpdatedAt = $1.updatedAt else {
                return false
            }
            return secondUpdatedAt < firstUpdatedAt
        })
        return sortedUsers
    }
    
    func unsortedUsersWithoutMe() -> [QBUUser] {
        var unsorterUsers = self.users
        let profile = Profile()
        if profile.isFull == false {
            return unsorterUsers
        }
        guard let index = unsorterUsers.index(where: { $0.id == profile.ID }) else {
            return unsorterUsers
        }
        unsorterUsers.remove(at: index)
        return unsorterUsers
    }
    
    //MARK: - Load User from server
    func loadUser(_ id: UInt, completion: ((QBUUser?) -> Void)? = nil) {
        QBRequest.user(withID: id, successBlock: { [weak self] (response, user) in
            self?.update(user: user)
            completion?(user)
        }) { (response) in
            completion?(nil)
        }
    }
    
    func loadUsers(success: @escaping (_ response: QBResponse?, _ page: QBGeneralResponsePage, _ users: [QBUUser]?) -> Void,
                   failure: @escaping (_ response: QBResponse?) -> Void) {
        let firstPage = QBGeneralResponsePage(currentPage: 1, perPage: 100)
        QBRequest.users(withExtendedRequest: ["order": "desc date updated_at"],
                        page: firstPage,
                        successBlock: { [weak self] (response, page, users) in
                            self?.update(users: users)
                            success(response, page, users)
        }, errorBlock: { response in
            debugPrint("[UsersViewController] loadUsers error: \(response.error?.error?.localizedDescription ?? "")")
            failure(response)
        })
    }
}
