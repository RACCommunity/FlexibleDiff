import UIKit

class WordCell: UITableViewCell {
	private let wordLabel: UILabel
	private let uuidLabel: UILabel

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		wordLabel = UILabel()
		uuidLabel = UILabel()

		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(_ word: Word) {
		wordLabel.text = word.word
		uuidLabel.text = word.identifier.uuidString
	}

	private func setupViews() {
		wordLabel.translatesAutoresizingMaskIntoConstraints = false
		uuidLabel.translatesAutoresizingMaskIntoConstraints = false

		contentView.addSubview(wordLabel)
		contentView.addSubview(uuidLabel)

		let constraints = [
			wordLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
			wordLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			wordLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			wordLabel.bottomAnchor.constraint(equalTo: uuidLabel.topAnchor, constant: -2),
			uuidLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
			uuidLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
			uuidLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
		]

		constraints.forEach { $0.priority = UILayoutPriority.defaultHigh }
		NSLayoutConstraint.activate(constraints)

		wordLabel.textAlignment = .natural
		uuidLabel.textAlignment = .natural

		wordLabel.font = .preferredFont(forTextStyle: .headline)
		uuidLabel.font = .preferredFont(forTextStyle: .caption2)
		uuidLabel.textColor = .gray
	}
}
