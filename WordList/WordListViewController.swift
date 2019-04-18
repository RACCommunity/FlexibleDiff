import UIKit
import FlexibleDiff

class WordListViewController: UIViewController {
	let viewModel: WordListViewModel

	private var cachedCellViewModels: [Word] = []
	private let tableView: UITableView

	init(viewModel: WordListViewModel) {
		tableView = UITableView()
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
		viewModel.output = self
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = tableView
		tableView.register(WordCell.self, forCellReuseIdentifier: "WordCell")
		tableView.dataSource = self
		tableView.delegate = self
		tableView.estimatedRowHeight = 44.0
		tableView.rowHeight = UITableView.automaticDimension
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.reloadData()
		viewModel.viewDidLoad()

		navigationItem.title = "Words"
		navigationItem.largeTitleDisplayMode = .never
		navigationItem.largeTitleDisplayMode = .automatic

		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(userDidTapActionButton))
    }

	@objc private func userDidTapActionButton() {
		viewModel.userDidTapActionButton()
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		super.motionEnded(motion, with: event)

		if motion == .motionShake {
			viewModel.userDidShakeDevice()
		}
	}
}

extension WordListViewController: WordListViewModelOutput {
	func update(_ snapshot: Snapshot<[Word]>) {
		cachedCellViewModels = snapshot.current

		for offset in snapshot.changeset.mutations {
			let indexPath = IndexPath(row: offset, section: 0)
			guard let cell = tableView.cellForRow(at: indexPath) as! WordCell?
				else { continue }
			cell.configure(self.cachedCellViewModels[offset])
		}

		for move in snapshot.changeset.moves where move.isMutated {
			let indexPath = IndexPath(row: move.source, section: 0)
			guard let cell = tableView.cellForRow(at: indexPath) as! WordCell?
				else { continue }
			cell.configure(self.cachedCellViewModels[move.destination])
		}

		tableView.performBatchUpdates(
			{
				let inserted = snapshot.changeset.inserts.map { IndexPath(row: $0, section: 0) }
				let deleted = snapshot.changeset.removals.map { IndexPath(row: $0, section: 0) }
				tableView.insertRows(at: inserted, with: .top)
				tableView.deleteRows(at: deleted, with: .top)

				for move in snapshot.changeset.moves {
					tableView.moveRow(at: IndexPath(row: move.source, section: 0),
					                  to: IndexPath(row: move.destination, section: 0))
				}
			},
			completion: nil
		)

		print(Date())
		print(snapshot.changeset)
		print("")
	}
}

extension WordListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell", for: indexPath) as! WordCell
		let viewModel = cachedCellViewModels[indexPath.row]
		cell.configure(viewModel)
		return cell
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return cachedCellViewModels.count
	}
}

extension WordListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}

	func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		return UISwipeActionsConfiguration(actions: [
			UIContextualAction(style: .destructive, title: "Delete") { [viewModel, cachedCellViewModels] _, _, completion in
				let isSuccessful = viewModel.deleteWord(cachedCellViewModels[indexPath.row])
				completion(isSuccessful)
			},
			UIContextualAction(style: .normal, title: "Edit") { [viewModel, cachedCellViewModels] _, _, completion in
				viewModel.editWord(cachedCellViewModels[indexPath.row], completion: completion)
			}
		])
	}
}
