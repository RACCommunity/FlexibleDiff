import UIKit

enum EditorKind {
	case add
	case edit(original: String)
}

enum ListAction {
	case add
	case shuffle
	case xchgShuffle
}

protocol WordListChildBuilders {
	func makeEditor(_ kind: EditorKind, _ response: @escaping (String?) -> Void) -> UIViewController
	func makeActions(_ response: @escaping (ListAction) -> Void) -> UIViewController
}

struct WordListBuilder: WordListChildBuilders {
	func make(navigation: UINavigationController) -> UIViewController {
		let flowController = WordListFlowController(navigation: navigation, builders: self)
		let viewModel = WordListViewModel(routing: flowController)
		let viewController = WordListViewController(viewModel: viewModel)
		return viewController
	}

	func makeEditor(_ kind: EditorKind, _ response: @escaping (String?) -> Void) -> UIViewController {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

		switch kind {
		case .add:
			alert.title = "Add new words"
			alert.message = "Separate words with comma or space."
			alert.addTextField { _ in }

		case let .edit(original):
			alert.title = "Enter the replacement word"
			alert.addTextField { $0.text = original }
		}

		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in response(nil) })
		alert.addAction(cancel)

		let commit = UIAlertAction(title: "Confirm",
		                           style: .default,
		                           handler: { _ in response(alert.textFields![0].text ?? "") })
		alert.addAction(commit)

		alert.preferredAction = commit

		return alert
	}

	func makeActions(_ response: @escaping (ListAction) -> Void) -> UIViewController {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let create = UIAlertAction(title: "Add", style: .default, handler: { _ in response(.add) })
		actionSheet.addAction(create)

		let shuffle = UIAlertAction(title: "Shuffle", style: .default, handler: { _ in response(.shuffle) })
		actionSheet.addAction(shuffle)

		let xchgShuffle = UIAlertAction(title: "Exchange and Shuffle", style: .default, handler: { _ in response(.xchgShuffle) })
		actionSheet.addAction(xchgShuffle)

		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
		actionSheet.addAction(cancel)

		return actionSheet
	}
}
