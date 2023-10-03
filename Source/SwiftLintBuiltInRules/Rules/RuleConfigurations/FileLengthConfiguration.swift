import SwiftLintCore

@AutoApply
struct FileLengthConfiguration: RuleConfiguration, Equatable {
    typealias Parent = FileLengthRule

    @ConfigurationElement
    private(set) var severityConfiguration = SeverityLevelsConfiguration<Parent>(warning: 400, error: 1000)
    @ConfigurationElement(key: "ignore_comment_only_lines")
    private(set) var ignoreCommentOnlyLines = false
}