import UIKit

struct RootBuilder {
	func make() -> UIViewController {
		let navigation = UINavigationController()
		let wordList = WordListBuilder().make(navigation: navigation)
		navigation.setViewControllers([wordList], animated: false)
		navigation.navigationBar.prefersLargeTitles = true

		return navigation
	}
}
