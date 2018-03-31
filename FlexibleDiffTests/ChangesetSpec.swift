import Nimble
import Quick
import FlexibleDiff
import Foundation

class ChangesetSpec: QuickSpec {
	override func spec() {
		describe("insertion reproducibility") {
			it("should reproduce the insertion at the beginning") {
				reproducibilityTest(applying: Changeset(inserts: [0]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["e", "a", "b", "c", "d"])
			}

			it("should reproduce the insertion at the end") {
				reproducibilityTest(applying: Changeset(inserts: [4]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "c", "d", "e"])
			}

			it("should reproduce the insertion in the middle") {
				reproducibilityTest(applying: Changeset(inserts: [2]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "e", "c", "d"])
			}

			it("should reproduce the contiguous insertions at the beginning") {
				reproducibilityTest(applying: Changeset(inserts: [0, 1, 2]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["e", "f", "g", "a", "b", "c", "d"])
			}

			it("should reproduce the contiguous insertions at the end") {
				reproducibilityTest(applying: Changeset(inserts: [4, 5, 6]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "c", "d", "e", "f", "g"])
			}

			it("should reproduce the contiguous insertions in the middle") {
				reproducibilityTest(applying: Changeset(inserts: [2, 3, 4]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "e", "f", "g", "c", "d"])
			}

			it("should reproduce the scattered insertions in the middle") {
				reproducibilityTest(applying: Changeset(inserts: [1, 3, 4, 7]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "e", "b", "f", "g", "c", "d", "h"])
			}
		}

		describe("removal reproducibility") {
			it("should reproduce the removal at the beginning") {
				reproducibilityTest(applying: Changeset(removals: [0]),
				                    to: ["e", "a", "b", "c", "d"],
				                    expecting: ["a", "b", "c", "d"])
			}

			it("should reproduce the removal at the end") {
				reproducibilityTest(applying: Changeset(removals: [4]),
				                    to: ["a", "b", "c", "d", "e"],
				                    expecting: ["a", "b", "c", "d"])
			}

			it("should reproduce the removal in the middle") {
				reproducibilityTest(applying: Changeset(removals: [2]),
				                    to: ["a", "b", "e", "c", "d"],
				                    expecting: ["a", "b", "c", "d"])
			}

			it("should reproduce the contiguous removals at the beginning") {
				reproducibilityTest(applying: Changeset(removals: [0, 1, 2]),
				                    to: ["e", "f", "g", "a", "b", "c", "d"],
				                    expecting: ["a", "b", "c", "d"])
			}

			it("should reproduce the contiguous removals at the end") {
				reproducibilityTest(applying: Changeset(removals: [4, 5, 6]),
				                    to: ["a", "b", "c", "d", "e", "f", "g"],
				                    expecting: ["a", "b", "c", "d"])
			}

			it("should reproduce the contiguous removals in the middle") {
				reproducibilityTest(applying: Changeset(removals: [2, 3, 4]),
				                    to: ["a", "b", "e", "f", "g", "c", "d"],
				                    expecting: ["a", "b", "c", "d"])
			}

			it("should reproduce the scattered removals in the middle") {
				reproducibilityTest(applying: Changeset(removals: [1, 3, 4, 7]),
				                    to: ["a", "e", "b", "f", "g", "c", "d", "h"],
				                    expecting: ["a", "b", "c", "d"])
			}
		}

		describe("mutation reproducibility") {
			it("should reproduce the mutation at the beginning") {
				reproducibilityTest(applying: Changeset(mutations: [0]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["Z", "b", "c", "d"])
			}

			it("should reproduce the mutation at the end") {
				reproducibilityTest(applying: Changeset(mutations: [3]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "c", "Z"])
			}

			it("should reproduce the mutation in the middle") {
				reproducibilityTest(applying: Changeset(mutations: [1]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "Z", "c", "d"])
			}

			it("should reproduce the contiguous mutations at the beginning") {
				reproducibilityTest(applying: Changeset(mutations: [0, 1, 2]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["X", "Y", "Z", "d"])
			}

			it("should reproduce the contiguous mutations at the end") {
				reproducibilityTest(applying: Changeset(mutations: [1, 2, 3]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "X", "Y", "Z"])
			}

			it("should reproduce the contiguous mutations in the middle") {
				reproducibilityTest(applying: Changeset(mutations: [2, 3, 4]),
				                    to: ["a", "b", "e", "f", "g", "c", "d"],
				                    expecting: ["a", "b", "X", "Y", "Z", "c", "d"])
			}

			it("should reproduce the scattered mutations in the middle") {
				reproducibilityTest(applying: Changeset(mutations: [1, 3, 4, 7]),
				                    to: ["a", "e", "b", "f", "g", "c", "d", "h"],
				                    expecting: ["a", "W", "b", "Z", "Y", "c", "d", "Z"])
			}
		}

		describe("move reproducibility") {
			it("should reproduce the forward move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 1, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["b", "a", "c", "d"])
			}

			it("should reproduce the forward move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 3, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["b", "c", "d", "a"])
			}

			it("should reproduce the backward move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 3, destination: 2, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "d", "c"])
			}

			it("should reproduce the backward move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 3, destination: 0, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["d", "a", "b", "c"])
			}

			it("should reproduce the forward mutating move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 1, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["b", "Z", "c", "d"])
			}

			it("should reproduce the forward mutating move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 3, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["b", "c", "d", "Z"])
			}

			it("should reproduce the backward mutating move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 3, destination: 2, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["a", "b", "Z", "c"])
			}

			it("should reproduce the backward mutating move") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 3, destination: 0, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["Z", "a", "b", "c"])
			}

			it("should reproduce the overlapping moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 3, isMutated: false),
				                                                .init(source: 3, destination: 0, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["d", "b", "c", "a"])
			}

			it("should reproduce the overlapping forward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 2, isMutated: false),
				                                                .init(source: 1, destination: 3, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["c", "d", "a", "b"])
			}

			it("should reproduce the overlapping forward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 3, isMutated: false),
				                                                .init(source: 1, destination: 2, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["c", "d", "b", "a"])
			}

			it("should reproduce the overlapping backward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 3, destination: 0, isMutated: false),
				                                                .init(source: 2, destination: 1, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["d", "c", "a", "b"])
			}


			it("should reproduce the overlapping backward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 2, destination: 0, isMutated: false),
				                                                .init(source: 3, destination: 1, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["c", "d", "a", "b"])
			}

			it("should reproduce the overlapping mutating moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 3, isMutated: false),
				                                                .init(source: 3, destination: 0, isMutated: false)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["Y", "b", "c", "Z"])
			}


			it("should reproduce the overlapping mutating forward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 2, isMutated: true),
				                                                .init(source: 1, destination: 3, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["c", "d", "Y", "Z"])
			}

			it("should reproduce the overlapping mutating forward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 0, destination: 3, isMutated: true),
				                                                .init(source: 1, destination: 2, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["c", "d", "Z", "Y"])
			}

			it("should reproduce the overlapping mutating backward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 3, destination: 0, isMutated: true),
				                                                .init(source: 2, destination: 1, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["Z", "Y", "a", "b"])
			}


			it("should reproduce the overlapping mutating backward moves") {
				reproducibilityTest(applying: Changeset(moves: [.init(source: 2, destination: 0, isMutated: true),
				                                                .init(source: 3, destination: 1, isMutated: true)]),
				                    to: ["a", "b", "c", "d"],
				                    expecting: ["Y", "Z", "a", "b"])
			}
		}

		describe("mixed reproducibility") {
			it("should reproduce all the operations") {
				reproducibilityTest(applying: Changeset(inserts: [0, 4],
				                                        removals: [0],
				                                        mutations: [1],
				                                        moves: [.init(source: 2, destination: 6, isMutated: true),
				                                                .init(source: 3, destination: 8, isMutated: false),
				                                                .init(source: 5, destination: 2, isMutated: false)]),
				                    to:        "abcdefgh",
				                    expecting: "YBfeZgChd")
			}

			it("should reproduce all the operations") {
				reproducibilityTest(applying: Changeset(inserts: [2],
				                                        removals: [],
				                                        moves: [Changeset.Move(source: 1, destination: 0, isMutated: false),
				                                                Changeset.Move(source: 2, destination: 1, isMutated: false),
				                                                Changeset.Move(source: 0, destination: 4, isMutated: false)]),
				                    to:        "EABDFGHIJ",
				                    expecting: "ABCDEFGHIJ")
			}
		}

		describe("diffing") {
			describe("insertions") {
				it("should reflect an insertion to an empty collection") {
					diffTest(previous: [],
					         current: [0],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [0]),
					         areEqual: ==)
				}

				it("should reflect an insertion at the beginning") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [10, 0, 1, 2, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [0]),
					         areEqual: ==)
				}

				it("should reflect contiguous insertions at the beginning") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [10, 11, 12, 0, 1, 2, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [0, 1, 2]),
					         areEqual: ==)
				}

				it("should reflect an insertion in the middle") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 1, 10, 2, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [2]),
					         areEqual: ==)
				}

				it("should reflect contiguous insertions in the middle") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 1, 10, 11, 12, 2, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [2, 3, 4]),
					         areEqual: ==)
				}

				it("should reflect scattered insertions in the middle") {
					// NOTE: This is not the most ideal changeset.
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 10, 1, 11, 2, 12, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [1, 3, 5],
					                             moves: [.init(source: 2, destination: 4, isMutated: false),
					                                     .init(source: 3, destination: 6, isMutated: false)]),
					         areEqual: ==)
				}

				it("should reflect an insertion at the end") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 1, 2, 3, 10],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [4]),
					         areEqual: ==)
				}

				it("should reflect contiguous insertions at the end") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 1, 2, 3, 10, 11, 12],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [4, 5, 6]),
					         areEqual: ==)
				}

				it("should detect inserted repeated values") {
					diffTest(previous: "AAA",
					         current: "AAAAA",
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [3, 4]),
					         areEqual: ==)
				}

				it("should detect inserted, scattered repeated values") {
					// NOTE: This is not the most ideal changeset.
					diffTest(previous: "WAXAYAZ",
					         current:  "AWAXAAYAZA",
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [5, 7, 9],
					                             moves: [.init(source: 6, destination: 8, isMutated: false),
					                                     .init(source: 1, destination: 0, isMutated: false),
					                                     .init(source: 0, destination: 1, isMutated: false),
					                                     .init(source: 4, destination: 6, isMutated: false),
					                                     .init(source: 2, destination: 3, isMutated: false),
					                                     .init(source: 3, destination: 2, isMutated: false),
					                                     .init(source: 5, destination: 4, isMutated: false)]),
					         areEqual: ==)
				}
			}

			describe("deletions") {
				it("should reflect a removal from a single-element collection") {
					diffTest(previous: [0],
					         current: [],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [0]),
					         areEqual: ==)
				}

				it("should reflect a removal at the beginning") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [1, 2, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [0]),
					         areEqual: ==)
				}

				it("should reflect contiguous removals at the beginning") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [0, 1, 2]),
					         areEqual: ==)
				}

				it("should reflect a removal in the middle") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 1, 3],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [2]),
					         areEqual: ==)
				}

				it("should reflect contiguous removals in the middle") {
					diffTest(previous: [0, 1, 2, 3, 4],
					         current: [0, 4],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [1, 2, 3]),
					         areEqual: ==)
				}

				it("should reflect scattered contiguous removals in the middle") {
					// NOTE: This is not the most ideal changeset.
					diffTest(previous: [0, 1, 2, 3, 4, 5, 6, 7, 8],
					         current: [0, 3, 7],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [1, 2, 4, 5, 6, 8],
					                             moves: [.init(source: 7, destination: 2, isMutated: false)]),
					         areEqual: ==)
				}

				it("should reflect a removal at the end") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0, 1, 2],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [3]),
					         areEqual: ==)
				}

				it("should reflect contiguous removals at the end") {
					diffTest(previous: [0, 1, 2, 3],
					         current: [0],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [1, 2, 3]),
					         areEqual: ==)
				}

				it("should detect removed repeated values") {
					diffTest(previous: "AAAAA",
					         current: "AAA",
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [3, 4]),
					         areEqual: ==)
				}
			}

			describe("mutations") {
				// Mutations can happen only if the identifying strategy differs from the
				// comparing strategy.

				it("should reflect a mutation at the beginning") {
					diffTest(previous: [Pair(key: "k1", value: "v1_old"),
					                    Pair(key: "k2", value: "v2"),
					                    Pair(key: "k3", value: "v3")],
					         current: [Pair(key: "k1", value: "v1_new"),
					                   Pair(key: "k2", value: "v2"),
					                   Pair(key: "k3", value: "v3")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [0]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutations at the beginning") {
					diffTest(previous: [Pair(key: "k1", value: "v1_old"),
					                    Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4")],
					         current: [Pair(key: "k1", value: "v1_new"),
					                   Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k4", value: "v4")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [0, 1, 2]),
					         areEqual: ==)
				}

				it("should reflect a mutation in the middle") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k2", value: "v2"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k2", value: "v2"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k4", value: "v4")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [2]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutations in the middle") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4_old"),
					                    Pair(key: "k5", value: "v5_old"),
					                    Pair(key: "k6", value: "v6")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k4", value: "v4_new"),
					                   Pair(key: "k5", value: "v5_new"),
					                   Pair(key: "k6", value: "v6")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [1, 2, 3, 4]),
					         areEqual: ==)
				}

				it("should reflect scattered mutations in the middle") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3"),
					                    Pair(key: "k4", value: "v4_old"),
					                    Pair(key: "k5", value: "v5"),
					                    Pair(key: "k6", value: "v6"),
					                    Pair(key: "k7", value: "v7_old"),
					                    Pair(key: "k8", value: "v8")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3"),
					                   Pair(key: "k4", value: "v4_new"),
					                   Pair(key: "k5", value: "v5"),
					                   Pair(key: "k6", value: "v6"),
					                   Pair(key: "k7", value: "v7_new"),
					                   Pair(key: "k8", value: "v8")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [1, 3, 6]),
					         areEqual: ==)
				}

				it("should reflect a mutation at the end") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k2", value: "v2"),
					                    Pair(key: "k3", value: "v3_old")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k2", value: "v2"),
					                   Pair(key: "k3", value: "v3_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [2]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutations at the end") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4_old")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k4", value: "v4_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [1, 2, 3]),
					         areEqual: ==)
				}

				it("should detect mutated repeated values") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k1", value: "v2_old"),
					                    Pair(key: "k1", value: "v3"),
					                    Pair(key: "k1", value: "v4_old")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k1", value: "v2_new"),
					                   Pair(key: "k1", value: "v3"),
					                   Pair(key: "k1", value: "v4_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(mutations: [1, 3]),
					         areEqual: ==)
				}
			}

			// Move tests are disabled for now, until the algorithm has been updated to
			// eliminate redundant moves.

			describe("moves") {
				it("should reflect a forward move") {
					diffTest(previous: [0, 1, 2, 3, 4],
					         current: [1, 2, 3, 0, 4],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(moves: [Changeset.Move(source: 0, destination: 3, isMutated: false),
					                                     Changeset.Move(source: 3, destination: 2, isMutated: false),
					                                     Changeset.Move(source: 2, destination: 1, isMutated: false),
					                                     Changeset.Move(source: 1, destination: 0, isMutated: false)]),
					         areEqual: ==)
				}

				it("should reflect a backward move") {
					diffTest(previous: [0, 1, 2, 3, 4],
					         current: [3, 0, 1, 2, 4],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(moves: [Changeset.Move(source: 3, destination: 0, isMutated: false),
					                                     Changeset.Move(source: 0, destination: 1, isMutated: false),
					                                     Changeset.Move(source: 1, destination: 2, isMutated: false),
					                                     Changeset.Move(source: 2, destination: 3, isMutated: false)]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutated moves that were affected by a removal") {
					diffTest(previous: [Pair(key: "k1", value: "v1"),
					                    Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4_old")],
					         current: [Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k4", value: "v4_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(removals: [0],
					                             moves: [Changeset.Move(source: 1, destination: 0, isMutated: true),
					                                     Changeset.Move(source: 2, destination: 1, isMutated: true),
					                                     Changeset.Move(source: 3, destination: 2, isMutated: true)]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutated moves that were affected by an insertion") {
					diffTest(previous: [Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4_old")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k4", value: "v4_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(inserts: [0],
					                             moves: [Changeset.Move(source: 0, destination: 1, isMutated: true),
					                                     Changeset.Move(source: 1, destination: 2, isMutated: true),
					                                     Changeset.Move(source: 2, destination: 3, isMutated: true)]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutated moves that were affected by a removal followed by a move") {
					diffTest(previous: [Pair(key: "k0", value: "v0"),
					                    Pair(key: "k1", value: "v1_old"),
					                    Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old")],
					         current: [Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new"),
					                   Pair(key: "k1", value: "v1_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(removals: [0],
					                             moves: [Changeset.Move(source: 1, destination: 2, isMutated: true),
					                                     Changeset.Move(source: 3, destination: 1, isMutated: true),
					                                     Changeset.Move(source: 2, destination: 0, isMutated: true)]),
					         areEqual: ==)
				}

				it("should reflect contiguous mutated moves that were affected by an insertion followed by a move") {
					diffTest(previous: [Pair(key: "k2", value: "v2_old"),
					                    Pair(key: "k3", value: "v3_old"),
					                    Pair(key: "k4", value: "v4_old")],
					         current: [Pair(key: "k1", value: "v1"),
					                   Pair(key: "k4", value: "v4_new"),
					                   Pair(key: "k2", value: "v2_new"),
					                   Pair(key: "k3", value: "v3_new")],
					         computed: { Changeset(previous: $0, current: $1, identifier: { $0.key }) },
					         expected: Changeset(inserts: [0],
					                             moves: [Changeset.Move(source: 0, destination: 2, isMutated: true),
					                                     Changeset.Move(source: 1, destination: 3, isMutated: true),
					                                     Changeset.Move(source: 2, destination: 1, isMutated: true)]),
					         areEqual: ==)
				}
			}

			describe("removals and moves") {
				it("should reflect a forward move and a removal") {
					diffTest(previous: [0, 1, 2, 3, 4],
					         current: [2, 3, 0, 4],
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(removals: [1],
					                             moves: [Changeset.Move(source: 0, destination: 2, isMutated: false),
					                                     Changeset.Move(source: 2, destination: 0, isMutated: false),
					                                     Changeset.Move(source: 3, destination: 1, isMutated: false),
					                                     Changeset.Move(source: 4, destination: 3, isMutated: false)]),
					         areEqual: ==)
				}
			}

			describe("insertions and moves") {
				it("should reflect a move and an insertion") {
					diffTest(previous: "EABDFGHIJ",
					         current:  "ABCDEFGHIJ",
					         computed: { Changeset(previous: $0, current: $1) },
					         expected: Changeset(inserts: [2],
					                             removals: [],
					                             moves: [Changeset.Move(source: 1, destination: 0, isMutated: false),
					                                     Changeset.Move(source: 2, destination: 1, isMutated: false),
					                                     Changeset.Move(source: 0, destination: 4, isMutated: false),
					                                     Changeset.Move(source: 0, destination: 4, isMutated: false),
					                                     Changeset.Move(source: 4, destination: 5, isMutated: false),
					                                     Changeset.Move(source: 5, destination: 6, isMutated: false),
					                                     Changeset.Move(source: 6, destination: 7, isMutated: false),
					                                     Changeset.Move(source: 7, destination: 8, isMutated: false),
					                                     Changeset.Move(source: 8, destination: 9, isMutated: false)]),
					         areEqual: ==)
				}
			}
		}

		describe("reproducibility") {
			describe("Hashable elements") {
				it("should produce a snapshot that can be reproduced from the previous snapshot by applying the changeset") {
					_measureAndStart(times: 256) {
						let numbers = Array(0 ..< 64).shuffled()
						let newNumbers = Array(numbers.dropLast(8) + (128 ..< 148)).shuffled()

						reproducibilityTest(applying: Changeset(previous: numbers,
						                                        current: newNumbers),
						                    to: numbers,
						                    expecting: newNumbers)
					}
				}

				it("should produce a snapshot that can be reproduced from the previous snapshot by applying the changeset, even if the collection is a multiset") {
					_measureAndStart(times: 256) {
						let numbers = Array(Array(repeating: Array(0 ..< 64), count: 3).joined()).shuffled()
						let newNumbers = Array(numbers.dropLast(16) + (128 ..< 148)).shuffled()

						reproducibilityTest(applying: Changeset(previous: numbers,
						                                        current: newNumbers),
						                    to: numbers,
						                    expecting: newNumbers)
					}
				}

				it("should produce a snapshot that can be reproduced from the previous snapshot by applying the changeset, even if the collection is bidirectional") {
					_measureAndStart(times: 256) {
						let oldCharacters = "abcdefghijkl12345~!@%^&*()_-+=".shuffled()
						var newCharacters = String(oldCharacters.dropLast(8))
						newCharacters.append(contentsOf: "mnopqrstuvwxyz67890#")
						newCharacters = newCharacters.shuffled()

						reproducibilityTest(applying: Changeset(previous: oldCharacters,
																current: newCharacters),
											to: oldCharacters,
											expecting: newCharacters)
					}
				}

				it("should produce a snapshot that can be reproduced from the previous snapshot by applying the changeset, even if the collection is bidirectional and is a multiset") {
					_measureAndStart(times: 256) {
						let oldCharacters = "abcdefghijkl12345~!@%^&*()_-+=abcdefghijkl12345~!@%^&*()_-+=".shuffled()
						var newCharacters = String(oldCharacters.dropLast(8))
						newCharacters.append(contentsOf: "mnopqrstuvwxyz67890#")
						newCharacters = newCharacters.shuffled()

						reproducibilityTest(applying: Changeset(previous: oldCharacters,
						                                        current: newCharacters),
						                    to: oldCharacters,
						                    expecting: newCharacters)
					}
				}
			}

			describe("AnyObject elements") {
				it("should produce a snapshot that can be reproduced from the previous snapshot by applying the changeset") {
					_measureAndStart(times: 256) {
						let objects = Array(0 ..< 256).map { _ in ObjectValue() }.shuffled()
						let newObjects = (Array(objects.dropLast(16)) + (0 ..< 128).map { _ in ObjectValue() }).shuffled()

						reproducibilityTest(applying: Changeset(previous: objects, current: newObjects),
						                    to: objects,
						                    expecting: newObjects,
						                    areEqual: ===)
					}
				}
			}

			describe("custom identifier and custom content") {
				it("should produce a snapshot that can be reproduced from the previous snapshot by applying the changeset") {
					_measureAndStart(times: 256) {
						let objects = Array(0 ..< 256).map { $0 --> $0 }.shuffled()
						let newObjects = (Array(objects.dropLast(16)) + (0 ..< 128).map { $0 --> $0 })
							.shuffled()
							.map { pair -> Pair<Int, Int> in
								let random = Int(arc4random())
								return pair.key --> (random % 3 == 0 ? pair.value : random)
							}

						reproducibilityTest(applying: Changeset(previous: objects, current: newObjects),
						                    to: objects,
						                    expecting: newObjects,
						                    areEqual: ==)
					}
				}
			}
		}
	}
}

precedencegroup PairPrecedence {
	associativity: left
	higherThan: AssignmentPrecedence
}

infix operator -->: PairPrecedence

private func --> <Key, Value>(key: Key, value: Value) -> Pair<Key, Value> {
	return Pair(key: key, value: value)
}

private func diffTest<C: RangeReplaceableCollection>(
	previous: C,
	current: C,
	computed changeset: (C, C) -> Changeset,
	expected expectedChangeset: Changeset,
	areEqual: (@escaping (C.Iterator.Element, C.Iterator.Element) -> Bool),
	file: FileString = #file,
	line: UInt = #line
) where C.Iterator.Element: Equatable {
	let changeset = changeset(previous, current)
	expect(changeset, file: file, line: line) == expectedChangeset
	reproducibilityTest(applying: changeset, to: previous, expecting: current, areEqual: areEqual, file: file, line: line)
}


private func reproducibilityTest<C: RangeReplaceableCollection>(
	applying changeset: Changeset,
	to previous: C,
	expecting current: C,
	file: FileString = #file,
	line: UInt = #line
) where C.Iterator.Element: Equatable {
	reproducibilityTest(applying: changeset, to: previous, expecting: current, areEqual: ==, file: file, line: line)
}

private func reproducibilityTest<C: RangeReplaceableCollection>(
	applying changeset: Changeset,
	to previous: C,
	expecting current: C,
	areEqual: (@escaping (C.Iterator.Element, C.Iterator.Element) -> Bool),
	file: FileString = #file,
	line: UInt = #line
) {
	var values = previous
	expect(values).to(equal(previous, by: areEqual))

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

	expect(values, file: file, line: line).to(equal(current, original: previous, changeset: changeset, by: areEqual))
}

#if !swift(>=3.2)
extension SignedInteger {
	fileprivate init<I: SignedInteger>(_ integer: I) {
		self.init(integer.toIntMax())
	}
}
#endif

#if os(Linux)
private func randomInteger() -> Int {
	srandom(UInt32(time(nil)))
	return Int(random() >> 1)
}
#else
private func randomInteger() -> Int {
	return Int(arc4random() >> 1)
}
#endif

private extension RangeReplaceableCollection {
	func shuffled() -> Self {
		var elements = self

		for i in 0 ..< Int(elements.count) {
			let distance = randomInteger() % Int(elements.count)
			let random = elements.index(elements.startIndex, offsetBy: numericCast(distance))
			let index = elements.index(elements.startIndex, offsetBy: numericCast(i))
			guard random != index else { continue }

			let temp = elements[index]
			elements.replaceSubrange(index ..< elements.index(after: index), with: CollectionOfOne(elements[random]))
			elements.replaceSubrange(random ..< elements.index(after: random), with: CollectionOfOne(temp))
		}

		return elements
	}
}

private class ObjectValue {}

private struct Pair<Key: Hashable, Value: Equatable>: Hashable, CustomStringConvertible {
	var key: Key
	var value: Value

	var hashValue: Int {
		return key.hashValue
	}

	var description: String {
		return "\(key) --> \(value)"
	}

	init(key: Key, value: Value) {
		self.key = key
		self.value = value
	}

	static func ==(left: Pair<Key, Value>, right: Pair<Key, Value>) -> Bool {
		return left.key == right.key && left.value == right.value
	}
}

private func _measure(times: UInt64 = 2_000_000, label: String = #function, _ action: (() -> UInt64) -> Void) {
	var result: UInt64 = 0
	var minResult: UInt64 = .max

	for i in 0 ..< times {
		var start: UInt64!
		action {
			start = mach_absolute_time()
			return i
		}
		let end = mach_absolute_time()

		let r = (end - start)
		result += r
		minResult = min(minResult, r)
	}

	var base = mach_timebase_info()
	_ = withUnsafeMutablePointer(to: &base, mach_timebase_info)

	let ns = (result / times) / UInt64(base.denom) * UInt64(base.numer)
	let minNs = minResult / UInt64(base.denom) * UInt64(base.numer)

	print("@\(label): avg \(ns) ns; min \(minNs) ns")
}

private func _measureAndStart(times: UInt64 = 2_000_000, label: String = #function, _ action: () -> Void) {
	return _measure(times: times, label: label) { start in
		_ = start()
		action()
	}
}
