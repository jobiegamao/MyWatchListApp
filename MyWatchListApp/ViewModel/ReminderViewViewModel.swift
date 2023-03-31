//
//  ReminderViewViewModel.swift
//  MyWatchListApp
//
//  Created by may on 3/15/23.
//


import Foundation
import Combine
import UserNotifications
import FirebaseAuth


class RemindMeViewViewModel: ObservableObject {
	
	private var subscriptions: Set<AnyCancellable> = []
	
	var user: UserAccount? {
		guard let authUser = Auth.auth().currentUser else { return nil }
		return UserAccount(from: authUser)
	}
	var error: Error?

	@Published var remindMeFilms: [Film] = []
	
	let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
	

	func retrieveRemindMeFilms(completion: (() -> Void)? = nil) {
		guard let user = user else { return }
		DatabaseManager.shared.collectionRemindMe(getAllFrom: user)
			.sink(receiveCompletion: { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error
				}
			}, receiveValue: { [weak self] arrayResult in
				let films = arrayResult.map { $0.film }
				self?.remindMeFilms = films
				completion?()
			})
			.store(in: &subscriptions)
	}
	
	
	func deleteFilm(model: Film, completion: @escaping (Result<Void,Error>) -> Void) {
		guard let user = user else { return }
		DatabaseManager.shared.collectionRemindMe(delete: model, from: user)
			.sink(receiveCompletion: { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error
					completion(.failure(error))
				}
			}, receiveValue: { [weak self] _ in
				self?.cancelReminderNotification(for: model)
				completion(.success(()))
			})
			.store(in: &subscriptions)

	}
	
	func addFilm(model: Film, completion: @escaping (Result<Void,Error>) -> Void){
		guard let user = user else { return }
		DatabaseManager.shared.collectionRemindMe(add: model, to: user)
			.sink(receiveCompletion: { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error
					completion(.failure(error))
				}
			}, receiveValue: { [weak self] _ in
				self?.createNotification(for: model)
				completion(.success(()))
			})
			.store(in: &subscriptions)

	}
	
	private func createNotification(for model: Film){

		notificationPermission() { [weak self] granted in
			if granted {
				guard let modelTitle = model.title ?? model.original_title ?? model.name ?? model.original_name,
					  let releaseDateStr = model.release_date,
					  let userID = self?.user?.id
				else { return }
				
				// DATE AND TIME NOTIF
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd"
				guard let releaseDate = dateFormatter.date(from: releaseDateStr) else {return}
				var notificationDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: releaseDate)
				notificationDateComponents.hour = 9
				notificationDateComponents.minute = 10
				
				let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDateComponents, repeats: false)
				
				// CONTENT
				let content = UNMutableNotificationContent()
				content.title = "\(modelTitle) is now streaming!"
				content.body = "Your Welcome."
				
				// ADD THE NOTIF
				let request = UNNotificationRequest(identifier: "\(userID)_\(model.id)", content: content, trigger: trigger)
				self?.center.add(request)
				print("notification added")
			}
		}
	}
	
	private func notificationPermission(completion: @escaping (Bool) -> Void){
		
		center.getNotificationSettings { [weak self] settings in
			
			switch settings.authorizationStatus{
				case .denied, .notDetermined:
					self?.center.requestAuthorization(options: [.alert, .sound]) { granted, error in
						if let error = error {
							print(error)
							completion(false)
							return
						}
						
						if granted {
							completion(true)
						} else {
							print("notification not created as user denied it")
							completion(false)
						}
					}
				case .authorized:
					completion(true)
				
				default:
					completion(true)
			}
		}
		
		
	}
	
	private func cancelReminderNotification(for model: Film){
		guard let userID = user?.id else { return }
		let notificationID = "\(userID)_\(model.id)"
		center.removePendingNotificationRequests(withIdentifiers: [notificationID])
		
	}
}
