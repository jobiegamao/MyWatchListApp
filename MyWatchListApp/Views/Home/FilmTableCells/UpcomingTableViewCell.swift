//
//  UpcomingTableViewCell.swift
//  MyWatchListApp
//
//  Created by may on 3/11/23.
//

import UIKit

class UpcomingTableViewCell: UITableViewCell {
	
	static let identifier = "UpcomingTableViewCell"
	
	private let reusable = ReusableViewsView()
	private lazy var webView = reusable.webView
	private lazy var placeholderImageView = reusable.placeholderImageView
	private lazy var tabView = reusable.tabView
	private lazy var titleLabel = reusable.titleLabel
	private lazy var genreLabel = reusable.genreLabel
	private lazy var descriptionLabel = reusable.descriptionLabel
	private lazy var monthLabel = reusable.monthLabel
	private lazy var dayLabel = reusable.dayLabel

	lazy var leftView: UIView = {
		let lv = UIView()
		lv.translatesAutoresizingMaskIntoConstraints = false

		let text1 = monthLabel
		let text2 = dayLabel
		lv.addSubview(text1)
		lv.addSubview(text2)

		NSLayoutConstraint.activate([
			text1.topAnchor.constraint(equalTo: lv.topAnchor),
			text1.centerXAnchor.constraint(equalTo: lv.centerXAnchor),

			text2.topAnchor.constraint(equalTo: text1.bottomAnchor, constant: 5),
			text2.centerXAnchor.constraint(equalTo: lv.centerXAnchor),
		])

		return lv
	}()
	

	
	// MARK: - Main
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(leftView)
		contentView.addSubview(webView)
		contentView.addSubview(placeholderImageView)
		contentView.addSubview(tabView)
		contentView.addSubview(titleLabel)
		contentView.addSubview(descriptionLabel)
		contentView.addSubview(genreLabel)
		
		applyConstraints()
		
	}
	
	// MARK: - Public Configure Method
	
	public func configureDetails(model: Film){
		
		let selectedTitle = model.name ?? model.title ?? model.original_title ?? model.original_name ?? "No Title"
		
		reusable.setWebViewRequest(selectedTitle: selectedTitle, model: model)
		
		titleLabel.text = selectedTitle
		descriptionLabel.text = model.overview
		
		reusable.genreToString(genres_id: model.genre_ids) { [weak self] result in
			DispatchQueue.main.async {
				self?.genreLabel.text = result
			}
			
		}
		
		if let release_date = model.release_date, let (month, day) = Global.shared.getMonthAndDay(from: release_date) {
			monthLabel.text = month
			dayLabel.text = day
		}
	}

	
	// MARK: - Private Methods
	
	private func applyConstraints(){
		
		NSLayoutConstraint.activate([
			leftView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			leftView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			leftView.heightAnchor.constraint(equalTo: contentView.heightAnchor),
			leftView.widthAnchor.constraint(equalToConstant: 50),
			
			webView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			webView.leftAnchor.constraint(equalTo: leftView.rightAnchor, constant: 5),
			webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			webView.heightAnchor.constraint(equalToConstant: 150),
			
			placeholderImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			placeholderImageView.leftAnchor.constraint(equalTo: leftView.rightAnchor, constant: 5),
			placeholderImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			placeholderImageView.heightAnchor.constraint(equalToConstant: 150),
			
			
			tabView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 10),
			tabView.leftAnchor.constraint(equalTo: webView.leftAnchor),
			tabView.rightAnchor.constraint(equalTo: webView.rightAnchor),
			tabView.heightAnchor.constraint(equalToConstant: 50),
			
			titleLabel.topAnchor.constraint(equalTo: tabView.bottomAnchor, constant: 20),
			titleLabel.leftAnchor.constraint(equalTo: webView.leftAnchor),
			titleLabel.rightAnchor.constraint(equalTo: webView.rightAnchor),
			
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
			descriptionLabel.leftAnchor.constraint(equalTo: webView.leftAnchor),
			descriptionLabel.rightAnchor.constraint(equalTo: webView.rightAnchor),
			
			genreLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
			genreLabel.leftAnchor.constraint(equalTo: webView.leftAnchor),
			genreLabel.rightAnchor.constraint(equalTo: webView.rightAnchor),
			
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
