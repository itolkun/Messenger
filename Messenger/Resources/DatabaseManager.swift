//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Айтолкун Анарбекова on 1/2/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    

}

// MARK: - Account Management

extension DatabaseManager {
    
    public func userExists(with email: String, _ completion: @escaping ((Bool) -> Void) )  {
        database.child(email).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChapAppUser) {
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}

struct ChapAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
//        let profilePictureUrl: String
}
