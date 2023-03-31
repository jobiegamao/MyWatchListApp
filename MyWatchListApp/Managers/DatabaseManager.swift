//
//  DatabaseManager.swift
//  netflixclone_swift
//
//  Created by may on 3/11/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import Combine

enum FirebaseError: Error {
	case invalidData, NoUserError
}

class DatabaseManager {
	
	static let shared = DatabaseManager()
	
	let db = Firestore.firestore()

	
	// MARK: - Collection USERS
	private let usersPath = "users"
	
	func collectionUsers(add newUser: User) -> AnyPublisher<Bool, Error> {
		let userAccount = UserAccount(from: newUser)
		
		return db.collection(usersPath).document(userAccount.id).setData(from: userAccount)
			.map{ _ in true }
			.eraseToAnyPublisher()
	}
	
	func collectionUsers(retrieve id: String) -> AnyPublisher<UserAccount, Error>{
		db.collection(usersPath).document(id).getDocument()
			.tryMap{ try $0.data(as: UserAccount.self) }
			.eraseToAnyPublisher()
	}
	
	func collectionUsers(for id: String, update fields: [String: Any]) -> AnyPublisher<Bool, Error>{
		db.collection(usersPath).document(id).updateData(fields)
			.map { _ in true }
			.eraseToAnyPublisher()
	}
	
	
	// MARK: - Collection RemindMe
	private let remindmePath = "remindMe"
	
	func collectionRemindMe(getAllFrom userAccount: UserAccount) -> AnyPublisher<[RemindMe], Error> {
		
		return db.collection(remindmePath)
			.whereField("profile.id", isEqualTo: userAccount.id)
			.getDocuments()
			.tryMap(\.documents) //array of doc snapshots
			.tryMap{ snapshots in
				try snapshots.map({
					try $0.data(as: RemindMe.self)
				})
			}
			.eraseToAnyPublisher()
	}
	
	func collectionRemindMe(add model: Film, to userAccount: UserAccount) -> AnyPublisher<Bool, Error>{
				
		let documentId = "\(userAccount.id)_\(model.id)"
		let data = RemindMe(id: documentId, film: model, user: userAccount)
		
		return db.collection(remindmePath).document(documentId).setData(from: data)
			.map{ _ in true }
			.eraseToAnyPublisher()
	}
	
	
	func collectionRemindMe(delete model: Film, from userAccount: UserAccount) -> AnyPublisher<Bool, Error>{
		
		let query = db.collection(remindmePath)
			.whereField("user.id", isEqualTo: userAccount.id)
			.whereField("film.id", isEqualTo: model.id)
			.limit(to: 1)

		return query.getDocuments()
			.flatMap { (querySnapshot) -> AnyPublisher<Bool, Error> in
				guard let document = querySnapshot.documents.first else {
					return Fail(error: FirebaseError.invalidData).eraseToAnyPublisher()
				}
				return document.reference.delete()
					.map{ _ in true }
					.eraseToAnyPublisher()
			}
			.eraseToAnyPublisher()
	}
	
	// MARK: - Collection RemindMe
	private let playlistPath = "filmPlaylists"
	
	func collectionPlaylist(getPlaylistTitle playlistTitle: String, from userAccount: UserAccount) -> AnyPublisher<FilmPlaylist, Error> {
		
		return db.collection(playlistPath)
			.whereField("playlist_owner.id", isEqualTo: userAccount.id)
			.whereField("playlist_title", isEqualTo: playlistTitle)
			.limit(to: 1)
			.getDocuments()
			.tryMap { querySnapshot in
						guard let document = querySnapshot.documents.first else {
							throw FirebaseError.invalidData
						}
						return try document.data(as: FilmPlaylist.self)
					}
			.eraseToAnyPublisher()
		
	}
	
	// add new playlist
	func collectionPlaylist(create playlistTitle: String, to userAccount: UserAccount) -> AnyPublisher<Bool, Error>{
				
		let documentId = "\(userAccount.id)_\(playlistTitle)"
		let data = FilmPlaylist(id: documentId, playlist_owner: userAccount, playlist_title: playlistTitle, films: [])
		
		return db.collection(playlistPath).document(documentId).setData(from: data)
			.map{ _ in true }
			.eraseToAnyPublisher()
	}
	
	
//	// add film in playlist
//	func collectionPlaylist(add films: [Film], to userAccount: UserAccount, for playlistTitle: String) -> AnyPublisher<Bool, Error>{
//
//		let query = db.collection(playlistPath)
//				.whereField("playlist_owner.id", isEqualTo: userAccount.id)
//				.whereField("playlist_title", isEqualTo: playlistTitle)
//
//		return query.getDocuments()
//			.flatMap { querySnapshot -> AnyPublisher<Void, Error> in
//				guard let document = querySnapshot.documents.first else {
//					return Fail(error: NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Playlist not found."]))
//						.eraseToAnyPublisher()
//				}
//
//				var updatedFilms = (document.get("films") as? [Film] ?? []) + films
//				return document.reference.updateData(["films": updatedFilms]).eraseToAnyPublisher()
//			}
//			.map { _ in true }
//			.eraseToAnyPublisher()
//	}
	
	func collectionPlaylist(add film: Film, to playlistID: String) -> AnyPublisher<Bool, Error> {
		let updatedFilms = FieldValue.arrayUnion([film])
		
		return db.collection(playlistPath).document(playlistID)
			.updateData(["films": updatedFilms])
			.map { _ in true }
			.eraseToAnyPublisher()
	}
	
	// delete a film in playlist
	func collectionPlaylist(remove film: Film, from playlistID: String) -> AnyPublisher<Bool, Error> {
		let updatedFilms = FieldValue.arrayRemove([film])
		
		return db.collection(playlistPath).document(playlistID)
			.updateData(["films": updatedFilms])
			.map { _ in true }
			.eraseToAnyPublisher()
	}
	
	// update playlist
	func collectionPlaylist(update fields: [String: Any], of playlist: FilmPlaylist) -> AnyPublisher<Bool, Error>{
		db.collection(usersPath).document(playlist.id).updateData(fields)
			.map { _ in true }
			.eraseToAnyPublisher()
	}
	
	//delete playlist
	func collectionPlaylist(delete playlist: FilmPlaylist, from userAccount: UserAccount) -> AnyPublisher<Bool, Error>{
		
		db.collection(playlistPath).document(playlist.id).delete()
			.map { _ in true }
			.eraseToAnyPublisher()
	}
	
	func checkPlaylistExistsPublisher(playlistTitle: String, userAccount: UserAccount) -> Future<Bool, Error> {
		let query = db.collection(playlistPath)
			.whereField("playlist_owner.id", isEqualTo: userAccount.id)
			.whereField("playlist_title", isEqualTo: playlistTitle)

		return Future { promise in
			query.getDocuments { (snapshot, error) in
				if let error = error {
					promise(.failure(error))
					return
				}
				
				guard let snapshot = snapshot else {
					promise(.failure(NSError(domain: "Firestore", code: -1, userInfo: ["description": "No snapshot found"])))
					return
				}
				
				promise(.success(!snapshot.documents.isEmpty))
			}
		}
	}
	
	
	
}
