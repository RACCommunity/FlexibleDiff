import FlexibleDiff
import Foundation

protocol WordListViewModelRouting: class {
	func showEditor(_ kind: EditorKind, _ response: @escaping (String?) -> Void)
	func showActions(_ response: @escaping (ListAction) -> Void)
}

protocol WordListViewModelOutput: class {
	func update(_ snapshot: Snapshot<[Word]>)
}

final class WordListViewModel {
	weak var output: WordListViewModelOutput?
	private let routing: WordListViewModelRouting

	private var words = [
		"Hello", "Hallo", "Bonjour", "Ciao", "Hola", "Olà",
		"Namasthe", "哈囉", "你好", "Halo", "こんにちは", "Hei"
	].map(Word.init)

	init(routing: WordListViewModelRouting) {
		self.routing = routing
	}

	func viewDidLoad() {
		let snapshot = Snapshot(previous: nil,
		                        current: words,
		                        changeset: Changeset(initial: words))
		output?.update(snapshot)
	}

	func userDidTapActionButton() {
		routing.showActions { action in
			switch action {
			case .add:
				self.routing.showEditor(.add) { response in
					self.parseAndAdd(response)
				}

			case .shuffle:
				self.shuffle()

			case .xchgShuffle:
				self.xchgShuffle()
			}
		}
	}

	func userDidShakeDevice() {
		xchgShuffle()
	}

	func editWord(_ word: Word, completion: @escaping (Bool) -> Void) {
		routing.showEditor(.edit(original: word.word)) { input in
			// `nil` means the alert has been cancelled.
			guard let input = input else {
				completion(false)
				return
			}

			completion(true)

			self.update { words in
				guard let index = words.firstIndex(where: { $0.identifier == word.identifier })
					else { return }
				words[index] = word.updating(input)
			}
		}
	}

	func deleteWord(_ word: Word) -> Bool {
		return update { words in
			guard let index = words.firstIndex(where: { $0.identifier == word.identifier })
				else { return false }
			words.remove(at: index)
			return true
		}
	}

	private func parseAndAdd(_ response: String?) {
		// `nil` means the alert has been cancelled.
		guard let response = response else { return }

		let words = response
			.components(separatedBy: ",")
			.flatMap { $0.components(separatedBy: " ") }
			.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
			.map(Word.init)

		update { $0.append(contentsOf: words) }
	}

	private func shuffle() {
		update { $0 = $0.shuffled() }
	}

	private func xchgShuffle() {
		update { words in
			words = zip(words.lazy.map { $0.identifier },
			            words.lazy.map { $0.word }.shuffled())
				.map(Word.init)
				.shuffled()
		}
	}

	@discardableResult
	private func update<Result>(_ action: (inout [Word]) -> Result) -> Result {
		let previous = words
		let result = action(&words)

		let changeset = Changeset(previous: previous, current: words, identifier: { $0.identifier })
		if changeset.inserts.isEmpty && changeset.removals.isEmpty && changeset.mutations.isEmpty && changeset.moves.isEmpty {
			return result
		}

		output?.update(Snapshot(previous: previous, current: words, changeset: changeset))
		return result
	}
}
