//
//  MyWatchlistViewViewModel.swift
//  MyWatchListApp
//
//  Created by may on 3/15/23.
//

import Foundation
import Combine
import FirebaseAuth


class MyWatchlistViewViewModel: ObservableObject {
	
	private var subscriptions: Set<AnyCancellable> = []
	
	var user: UserAccount? {
		guard let authUser = Auth.auth().currentUser else { return nil }
		return UserAccount(from: authUser)
	}
	
	@Published var error: String?
	@Published var films: [ String : FilmPlaylist ] = [:]


	func retrievePlaylist(playlist_title: String, completion: (() -> Void)? = nil) {
		
		guard let user = user else {return}
	
		checkIfPlaylistExists(createPlaylist: true, playlist_title: playlist_title){ exists in
			guard exists else { return }
			DatabaseManager.shared.collectionPlaylist(getPlaylistTitle: playlist_title, from: user)
				.sink(receiveCompletion: { [weak self] result in
					if case .failure(let error) = result {
						self?.error = error.localizedDescription
						print(error)
					}
				}, receiveValue: { [weak self] playlist in
					self?.films[playlist.playlist_title] = playlist
					completion?()
				})
				.store(in: &self.subscriptions)
		}
		
		
	}
	
	func checkIfPlaylistExists(createPlaylist: Bool, playlist_title: String, completion: ((Bool) -> Void)? = nil){
		guard let user = user else {return}
		
		DatabaseManager.shared.checkPlaylistExistsPublisher(playlistTitle: playlist_title, userAccount: user)
			.sink(receiveCompletion: { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error.localizedDescription
					print(error)
					completion?(false)
				}
			}, receiveValue: { [weak self] exists in
				if(createPlaylist && !exists) {
					DatabaseManager.shared.collectionPlaylist(create: playlist_title, to: user)
						.sink { [weak self] result in
							if case .failure(let error) = result {
								self?.error = error.localizedDescription
								print(error)
							}
						} receiveValue: { _ in
							print("playlist created")
						}
						.store(in: &self!.subscriptions)
				}
				completion?(exists)
			})
			.store(in: &subscriptions)
	}
	
	func createPlaylist(playlist_title: String){
		checkIfPlaylistExists(createPlaylist: true, playlist_title: playlist_title){ exists in
			if exists{
				self.error = "Playlist has already been created!"
			}
		}
	}
	
	
	func removeFilm(model: Film, from playlistID: String, completion: @escaping (Result<Void,Error>) -> Void) {
		
		DatabaseManager.shared.collectionPlaylist(remove: model, from: playlistID)
			.sink(receiveCompletion: { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error.localizedDescription
					completion(.failure(error))
				}
			}, receiveValue: {  _ in
				completion(.success(()))
			})
			.store(in: &subscriptions)

	}
	
	func addFilm(model: Film, to playlistID: String, completion: @escaping (Result<Void,Error>) -> Void){
		
		DatabaseManager.shared.collectionPlaylist(add: model, to: playlistID)
			.sink(receiveCompletion: { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error.localizedDescription
					completion(.failure(error))
				}
			}, receiveValue: {  _ in
				completion(.success(()))
			})
			.store(in: &subscriptions)

	}
	
	
	
}
