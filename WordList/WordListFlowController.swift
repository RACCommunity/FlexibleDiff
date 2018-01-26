import UIKit

final class WordListFlowController: WordListViewModelRouting {
	private weak var navigation: UINavigationController?
	private let builders: WordListChildBuilders

	init(navigation: UINavigationController, builders: WordListChildBuilders) {
		self.navigation = navigation
		self.builders = builders
	}

	func showActions(_ response: @escaping (ListAction) -> Void) {
		let viewController = builders.makeActions(response)
		navigation?.present(viewController, animated: true, completion: nil)
	}

	func showEditor(_ kind: EditorKind, _ response: @escaping (String?) -> Void) {
		let viewController = builders.makeEditor(kind, response)
		navigation?.present(viewController, animated: true, completion: nil)
	}
}
