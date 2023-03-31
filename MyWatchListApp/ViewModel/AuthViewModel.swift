//
//  AuthViewModel.swift
//  netflixclone_swift
//
//  Created by may on 2/26/23.
//

import Foundation
import Firebase
import Combine

final class AuthViewModel: ObservableObject {
	
	@Published var email: String?
	@Published var password: String?
	@Published var isAuthenticationValid: Bool = false
	@Published var user: User? // from Auth Library
	@Published var error: Error?
	
	private var subscriptions: Set<AnyCancellable> = []
	
	func validateForm(){
		guard let email = email, let password = password else { return }
		isAuthenticationValid = isValidEmail(email) && isValidPassword(password: password)
		
	}
	
	func isValidEmail(_ email: String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

		let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: email)
	}
	
	func isValidPassword(password: String) -> Bool {
		guard password.count > 3
		else{return false}
		
		return true
	}
	
	func createUser(){
		guard let email = email, let password = password else { return }
		AuthManager.shared.registerUser(with: email, password: password)
			.handleEvents(receiveOutput: { [weak self] user in
				self?.user = user
			})
			.sink { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error
				}
			} receiveValue: { [weak self] user in
				self?.saveUserInDB(for: user)
				print("user saved in database!")
			}
			.store(in: &subscriptions)
	}
	
	func saveUserInDB(for user: User){
		DatabaseManager.shared.collectionUsers(add: user)
			.sink { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error
				}
			} receiveValue: { bool in
				print("Adding user in db: \(bool)")
			}
			.store(in: &subscriptions)
		
		

	}
	
	func loginUser(){
		guard let email = email, let password = password else { return }
		AuthManager.shared.loginUser(with: email, password: password)
			.sink { [weak self] result in
				if case .failure(let error) = result {
					self?.error = error
				}
			} receiveValue: { [weak self] user in //
				self?.user = user
			}
			.store(in: &subscriptions)
	}
	
	
}

