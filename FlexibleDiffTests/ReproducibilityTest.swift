import Foundation
import FlexibleDiff

internal func reproduce<C: RangeReplaceableCollection>(
	applying changeset: Changeset,
	to previous: C,
	expecting current: C,
	areEqual: (@escaping (C.Iterator.Element, C.Iterator.Element) -> Bool)
) -> C {
	var values = previous

	// Move offset pairs are only a hint for animation and optimization. They are
	// semantically equivalent to a removal offset paired with an insertion offset.
	let removals = changeset.removals.union(IndexSet(changeset.moves.lazy.map { $0.source }))
	let inserts = changeset.inserts.union(IndexSet(changeset.moves.lazy.map { $0.destination }))

	// (1) Perform removals (including move sources).
	for range in removals.rangeView.reversed() {
		let lowerBound = values.index(values.startIndex, offsetBy: numericCast(range.lowerBound))
		let upperBound = values.index(lowerBound, offsetBy: numericCast(range.count))
		values.removeSubrange(lowerBound ..< upperBound)
	}

	// (2) Copy position invariant mutations.
	for range in changeset.mutations.rangeView {
		let removalOffset = removals.count(in: 0 ..< range.lowerBound)
		let insertOffset = inserts.count(in: 0 ... range.lowerBound)

		let lowerBound = values.index(values.startIndex, offsetBy: numericCast(range.lowerBound - removalOffset))
		let upperBound = values.index(lowerBound, offsetBy: numericCast(range.count))
		let copyLowerBound = current.index(current.startIndex, offsetBy: numericCast(range.lowerBound - removalOffset + insertOffset))
		let copyUpperBound = current.index(copyLowerBound, offsetBy: numericCast(range.count))
		values.replaceSubrange(lowerBound ..< upperBound,
		                       with: current[copyLowerBound ..< copyUpperBound])
	}

	// (3) Perform insertions (including move destinations).
	for range in inserts.rangeView {
		let lowerBound = values.index(values.startIndex, offsetBy: numericCast(range.lowerBound))
		let copyLowerBound = current.index(current.startIndex, offsetBy: numericCast(range.lowerBound))
		let copyUpperBound = current.index(copyLowerBound, offsetBy: numericCast(range.count))
		values.insert(contentsOf: current[copyLowerBound ..< copyUpperBound],
		              at: lowerBound)
	}

	return values
}

