//
//  RemindMe.swift
//  netflixclone_swift
//
//  Created by may on 3/6/23.
//

import Foundation

struct RemindMe: Codable {
	let id: String
	let film: Film
	let user: UserAccount
	
	var addedOn: Date = Date()
}
