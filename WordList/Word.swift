import Foundation

struct Word: Equatable {
	let identifier: UUID
	let word: String

	init(word: String) {
		self.identifier = UUID()
		self.word = word
	}

	init(identifier: UUID, word: String) {
		self.identifier = identifier
		self.word = word
	}

	func updating(_ word: String) -> Word {
		return Word(identifier: self.identifier, word: word)
	}

	static func == (left: Word, right: Word) -> Bool {
		return left.identifier == right.identifier && left.word == right.word
	}
}
