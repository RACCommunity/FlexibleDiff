import Nimble
import Quick
import FlexibleDiff
import Foundation

class SectionedChangesetSpec: QuickSpec {
	override func spec() {
		describe("insertion") {
			it("should reflect an inserted section") {
				diffTest(
					previous: [
						Section(identifier: "A", items: [])
					],
					current: [
						Section(identifier: "A", items: []),
						Section(identifier: "B", items: [])
					],
					expected: SectionedChangeset(
						sections: Changeset(inserts: [1]),
						mutatedSections: []
					)
				)
			}
		}

		describe("removal") {
			it("should reflect a removed section") {
				diffTest(
					previous: [
						Section(identifier: "A", items: []),
						Section(identifier: "B", items: [])
					],
					current: [
						Section(identifier: "A", items: []),
					],
					expected: SectionedChangeset(
						sections: Changeset(removals: [1]),
						mutatedSections: []
					)
				)
			}

			it("should reflect only removed sections") {
				diffTest(
					previous: [
						Section(identifier: "A", items: [Section.Item(identifier: "A0", value: .max)]),
						Section(identifier: "B", items: [Section.Item(identifier: "B0", value: .max)]),
						Section(identifier: "C", items: [Section.Item(identifier: "C0", value: .max)]),
						Section(identifier: "D", items: [Section.Item(identifier: "D0", value: .max)])
					],
					current: [
						Section(identifier: "C", items: [Section.Item(identifier: "C0", value: .max)])
					],
					expected: SectionedChangeset(
						sections: Changeset(removals: [0, 1, 3]),
						mutatedSections: []
					)
				)
			}
		}

		describe("insertions and moves") {
			it("should reflect three inserted sections and two moves") {
				diffTest(
					previous: [
						Section(identifier: "A", items: [Section.Item(identifier: "A0", value: .max)]),
						Section(identifier: "B", items: [Section.Item(identifier: "B0", value: .max)]),
						Section(identifier: "C", items: [Section.Item(identifier: "C0", value: .max)])
					],
					current: [
						Section(identifier: "B", items: [Section.Item(identifier: "B0", value: .max)]),
						Section(identifier: "D", items: [Section.Item(identifier: "D0", value: .max)]),
						Section(identifier: "C", items: [Section.Item(identifier: "C0", value: .max)]),
						Section(identifier: "E", items: [Section.Item(identifier: "E0", value: .max)]),
						Section(identifier: "F", items: [Section.Item(identifier: "F0", value: .max)]),
						Section(identifier: "A", items: [Section.Item(identifier: "A0", value: .max)])
					],
					expected: SectionedChangeset(
						sections: Changeset(inserts: [1, 3, 4],
											moves: [
												Changeset.Move(source: 0, destination: 5, isMutated: false),
												Changeset.Move(source: 1, destination: 0, isMutated: false)
											]),
						mutatedSections: []
					)
				)
			}
		}

		describe("removal and insertion duo") {
			it("should reflect an inserted section prior to a removal") {
				diffTest(
					previous: [
						Section(identifier: "A", items: []),
						Section(identifier: "B", items: []),
						Section(identifier: "C", items: [])
					],
					current: [
						Section(identifier: "D", items: []),
						Section(identifier: "A", items: []),
						Section(identifier: "C", items: [])
					],
					expected: SectionedChangeset(
						sections: Changeset(inserts: [0], removals: [1]),
						mutatedSections: []
					)
				)
			}

			it("should reflect an inserted section after a removal") {
				diffTest(
					previous: [
						Section(identifier: "A", items: []),
						Section(identifier: "B", items: []),
						Section(identifier: "C", items: []),
						Section(identifier: "D", items: [])
					],
					current: [
						Section(identifier: "B", items: []),
						Section(identifier: "C", items: []),
						Section(identifier: "D", items: []),
						Section(identifier: "E", items: []),
					],
					expected: SectionedChangeset(
						sections: Changeset(inserts: [3], removals: [0]),
						mutatedSections: []
					)
				)
			}
		}

		describe("mutation") {
			it("should reflect a mutated section") {
				diffTest(
					previous: [
						Section(identifier: "A", items: [])
					],
					current: [
						Section(identifier: "A", items: [
							Section.Item(identifier: "A0", value: .max)
						])
					],
					expected: SectionedChangeset(
						sections: Changeset(mutations: [0]),
						mutatedSections: [
							SectionedChangeset.MutatedSection(
								source: 0,
								destination: 0,
								changeset: Changeset(inserts: [0])
							)
						]
					)
				)
			}
		}

		describe("move") {
			it("should reflect a section moved without change") {
				diffTest(
					previous: [
						Section(identifier: "A", items: []),
						Section(identifier: "B", items: []),
						Section(identifier: "C", items: [])
					],
					current: [
						Section(identifier: "C", items: []),
						Section(identifier: "B", items: []),
						Section(identifier: "A", items: [])
					],
					expected: SectionedChangeset(
						sections: Changeset(moves: [
							Changeset.Move(source: 0, destination: 2, isMutated: false),
							Changeset.Move(source: 2, destination: 0, isMutated: false)
						]),
						mutatedSections: []
					)
				)
			}

			it("should reflect a section moved with mutations made") {
				diffTest(
					previous: [
						Section(identifier: "A", items: [
							Section.Item(identifier: "A0", value: .max)
						]),
						Section(identifier: "B", items: []),
						Section(identifier: "C", items: [
							Section.Item(identifier: "C0", value: .min)
						])
					],
					current: [
						Section(identifier: "C", items: [
							Section.Item(identifier: "CF", value: .max),
							Section.Item(identifier: "C0", value: .min)
						]),
						Section(identifier: "B", items: []),
						Section(identifier: "A", items: [
							Section.Item(identifier: "A1", value: .min)
						])
					],
					expected: SectionedChangeset(
						sections: Changeset(moves: [
							Changeset.Move(source: 0, destination: 2, isMutated: true),
							Changeset.Move(source: 2, destination: 0, isMutated: true)
						]),
						mutatedSections: [
							SectionedChangeset.MutatedSection(
								source: 0,
								destination: 2,
								changeset: Changeset(inserts: [0], removals: [0])
							),
							SectionedChangeset.MutatedSection(
								source: 2,
								destination: 0,
								changeset: Changeset(inserts: [0])
							)
						]
					)
				)
			}

			it("should reflect a section moved with mutations made to replace a removal") {
				diffTest(
					previous: [
						Section(identifier: "A", items: [
							Section.Item(identifier: "A0", value: .max)
							]),
						Section(identifier: "B", items: []),
						Section(identifier: "C", items: [
							Section.Item(identifier: "C0", value: .min)
						])
					],
					current: [
						Section(identifier: "C", items: [
							Section.Item(identifier: "CF", value: .max),
							Section.Item(identifier: "C0", value: .min)
							]),
						Section(identifier: "B", items: [])
					],
					expected: SectionedChangeset(
						sections: Changeset(
							removals: [0],
							moves: [
								Changeset.Move(source: 2, destination: 0, isMutated: true)
							]
						),
						mutatedSections: [
							SectionedChangeset.MutatedSection(
								source: 2,
								destination: 0,
								changeset: Changeset(inserts: [0])
							)
						]
					)
				)
			}
		}
	}
}

struct Section: Equatable {
	var identifier: String
	var metadata: String
	var items: [Item]

	init(identifier: String, metadata: String = "", items: [Item] = []) {
		self.identifier = identifier
		self.metadata = metadata
		self.items = items
	}
}

extension Section {
	struct Item: Equatable {
		var identifier: String
		var value: Int
	}
}

private func diffTest(
	previous: [Section],
	current: [Section],
	expected expectedChangeset: SectionedChangeset,
	file: FileString = #file,
	line: UInt = #line
) {
	let changeset = SectionedChangeset(previous: previous,
	                                   current: current,
	                                   sectionIdentifier: { $0.identifier },
	                                   areMetadataEqual: { $0.metadata == $1.metadata },
	                                   items: { $0.items },
	                                   itemIdentifier: { $0.identifier },
	                                   areItemsEqual: ==)

	expect(changeset, file: file, line: line) == expectedChangeset
	reproducibilityTest(applying: changeset, to: previous, expecting: current, file: file, line: line)
}

private func reproducibilityTest(
	applying changeset: SectionedChangeset,
	to previous: [Section],
	expecting current: [Section],
	file: FileString = #file,
	line: UInt = #line
) {
	var values = previous
	expect(values, file: file, line: line) == previous

	let allRemovals = changeset.sections.removals
		.union(IndexSet(changeset.sections.moves.map { $0.source }))
	let allInsertions: [(Int?, Int)] = [changeset.sections.inserts.map { (nil, $0) },
	                                    changeset.sections.moves.map { ($0.source as Int?, $0.destination) }]
		.flatMap { $0 }
		.sorted { lhs, rhs in lhs.1 < rhs.1 }

	for index in allRemovals.reversed() {
	 	values.remove(at: index)
	}

	for (previousIndex, index) in allInsertions {
		if let previousIndex = previousIndex {
			values.insert(previous[previousIndex], at: index)
		} else {
			values.insert(current[index], at: index)
		}
	}

	let mutatedMoves = Set(changeset.sections.moves.lazy
		.filter { $0.isMutated }
		.compactMap { Tuple2($0.source, $0.destination) })
	let mutatedSections = Set(changeset.sections.mutations.map { Tuple2($0, $0) })
		.union(mutatedMoves)
	let records = Set(changeset.mutatedSections.map { Tuple2($0.source, $0.destination) })

	// [BUG] It seems occasionally `Set.==` is not being picked up.
	//       Nimble 7.3.1.
	expect(records).to(equal(mutatedSections))

	for record in changeset.mutatedSections {
		values[record.destination].metadata = current[record.destination].metadata
		values[record.destination].items = reproduce(applying: record.changeset,
		                                             to: values[record.destination].items,
		                                             expecting: current[record.destination].items,
		                                             areEqual: ==)
	}

	expect(values, file: file, line: line) == current
}

struct Tuple2<L: Hashable, R: Hashable>: Hashable {
	let lhs: L
	let rhs: R

	init(_ lhs: L, _ rhs: R) {
		self.lhs = lhs
		self.rhs = rhs
	}
}
