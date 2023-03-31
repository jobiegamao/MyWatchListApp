//
//  SectionBarView.swift
//  MyWatchListApp
//
//  Created by may on 3/11/23.
//

import UIKit


class SectionBarView: UIView {

	var sectionItems: [Section] = []
	var didSelectSection: ((Int) -> Void)?
	var selectedIndexPath: IndexPath = IndexPath(row: 0, section: 0){
		didSet{
			sectionCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
		}
	}
	
	
	public lazy var sectionCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal

		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.register(HomeHeaderCollectionViewCell.self, forCellWithReuseIdentifier: HomeHeaderCollectionViewCell.identifier)
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.backgroundColor = .clear
		cv.showsHorizontalScrollIndicator = false
		cv.alwaysBounceHorizontal = true
		
		cv.delegate = self
		cv.dataSource = self

		return cv
	}()
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.addSubview(sectionCollectionView)
		NSLayoutConstraint.activate([
			sectionCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
			sectionCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
			sectionCollectionView.topAnchor.constraint(equalTo: topAnchor),
			sectionCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
	   ])
		
		
	}
	

	override func layoutSubviews() {
		super.layoutSubviews()
		sectionCollectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}



extension SectionBarView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sectionItems.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeHeaderCollectionViewCell.identifier, for: indexPath) as? HomeHeaderCollectionViewCell else{ return UICollectionViewCell() }
		let sectionItem = sectionItems[indexPath.row]
		cell.configure(with: sectionItem)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		didSelectSection?(indexPath.row)
		selectedIndexPath = indexPath
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		let title = sectionItems[indexPath.row].title
		let width = title.size(withAttributes: [.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]).width + 30
		return CGSize(width: width, height: collectionView.frame.height)
	}
	
	
	
}


class HomeHeaderCollectionViewCell: UICollectionViewCell {
	
	static let identifier = "HomeHeaderCollectionViewCell"
		
	override var isSelected: Bool {
		didSet {
			configureSelectedStatus()
		}
	}
	
	let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		imageView.clipsToBounds = true
		
		return imageView
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
		label.textAlignment = .center
		label.numberOfLines = 1
		

		return label
	}()
	
	
	lazy var labelView: UIView = {
		let lv = UIView()
		lv.translatesAutoresizingMaskIntoConstraints = false
		
		
		lv.addSubview(imageView)
		lv.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: lv.leadingAnchor, constant: 5),
			imageView.bottomAnchor.constraint(equalTo: lv.bottomAnchor, constant: -5),
			imageView.widthAnchor.constraint(equalToConstant: 15),
			imageView.centerYAnchor.constraint(equalTo: lv.centerYAnchor),
			
			titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
			titleLabel.centerYAnchor.constraint(equalTo: lv.centerYAnchor),
		])
		
		return lv
	}()
	
	private lazy var indicatorView: UIView = {
		let indic = UIView()
		indic.isUserInteractionEnabled = false
		indic.translatesAutoresizingMaskIntoConstraints = false
		indic.backgroundColor = UIColor(named: "AccentColor")
		indic.layer.masksToBounds = true
		
	
		indic.layer.cornerRadius = 20
		
		return indic
	}()
	
	
	// MARK: - Main
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(indicatorView)
		contentView.addSubview(labelView)
		
		applyConstraints()
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		configureSelectedStatus()
	}
	
	// MARK: - Public Configure Method
	public func configure(with sectionItem: Section) {
		titleLabel.text = sectionItem.title
		imageView.image = sectionItem.icon
	}
	
	// MARK: - Private Methods
	private func configureSelectedStatus(){
		if isSelected {
			indicatorView.backgroundColor = UIColor(named: "AccentColor")
			imageView.tintColor = .white
			titleLabel.textColor = .white
		} else {
			indicatorView.backgroundColor = .clear
			imageView.tintColor = UIColor(named: "AccentColor")
			titleLabel.textColor = UIColor(named: "AccentColor")
		}
	}
	
	private func applyConstraints(){
		NSLayoutConstraint.activate([
		   labelView.topAnchor.constraint(equalTo: contentView.topAnchor),
		   labelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
		   labelView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
		   labelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
		])
			   
	   NSLayoutConstraint.activate([
		   indicatorView.centerYAnchor.constraint(equalTo: labelView.centerYAnchor),
		   indicatorView.heightAnchor.constraint(equalToConstant: 40),
		   indicatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
		   indicatorView.trailingAnchor.constraint(equalTo: trailingAnchor)
	   ])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
