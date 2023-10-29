import SourceKittenFramework

struct NoGroupingExtensionRule: OptInRule {
    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "no_grouping_extension",
        name: "No Grouping Extension",
        description: "Extensions shouldn't be used to group code within the same source file",
        kind: .idiomatic,
        nonTriggeringExamples: [
            Example("protocol Food {}\nextension Food {}"),
            Example("class Apples {}\nextension Oranges {}"),
            Example("class Box<T> {}\nextension Box where T: Vegetable {}")
        ],
        triggeringExamples: [
            Example("enum Fruit {}\n↓extension Fruit {}"),
            Example("↓extension Tea: Error {}\nstruct Tea {}"),
            Example("class Ham { class Spam {}}\n↓extension Ham.Spam {}"),
            Example("extension External { struct Gotcha {}}\n↓extension External.Gotcha {}")
        ]
    )

    func validate(file: SwiftLintFile) -> [StyleViolation] {
        let collector = NamespaceCollector(dictionary: file.sourceKitStructureDictionary)
        let elements = collector.findAllElements(of: [.class, .enum, .struct, .extension])

        let susceptibleNames = Set(elements.compactMap { $0.kind != .extension ? $0.name : nil })

        return elements.compactMap { element in
            guard element.kind == .extension, susceptibleNames.contains(element.name) else {
                return nil
            }

            guard !hasWhereClause(dictionary: element.dictionary, file: file) else {
                return nil
            }

            return StyleViolation(ruleDescription: Self.description,
                                  severity: configuration.severity,
                                  location: Location(file: file, byteOffset: element.offset))
        }
    }

    private func hasWhereClause(dictionary: SourceKittenDictionary, file: SwiftLintFile) -> Bool {
        guard let nameOffset = dictionary.nameOffset,
            let nameLength = dictionary.nameLength,
            let bodyOffset = dictionary.bodyOffset,
            case let contents = file.stringView,
            case let rangeStart = nameOffset + nameLength,
            case let rangeLength = bodyOffset - rangeStart,
            let range = contents.byteRangeToNSRange(ByteRange(location: rangeStart, length: rangeLength))
        else {
            return false
        }

        return file.match(pattern: "\\bwhere\\b", with: [.keyword], range: range).isNotEmpty
    }
}
