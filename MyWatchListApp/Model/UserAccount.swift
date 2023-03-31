//
//  UserAccount.swift
//  netflixclone_swift
//
//  Created by may on 2/26/23.
//

import Foundation
import Firebase

struct UserAccount: Codable {
	let id: String
	var username: String?
	var name: String?
	var createdOn: Date = Date()


	//auto id from User Firebase
	init(from user: User) {
		self.id = user.uid
	}
}


