//
//  FilmPlaylist.swift
//  MyWatchListApp
//
//  Created by may on 3/11/23.
//

import Foundation


struct FilmPlaylist: Codable {
	let id: String
	let playlist_owner: UserAccount
	let playlist_title: String
	var films: [Film] = [Film]()

}
