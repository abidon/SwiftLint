import SwiftLintCore

@AutoApply
struct SwitchCaseAlignmentConfiguration: SeverityBasedRuleConfiguration, Equatable {
    typealias Parent = SwitchCaseAlignmentRule

    @ConfigurationElement(key: "severity")
    private(set) var severityConfiguration = SeverityConfiguration<Parent>(.warning)
    @ConfigurationElement(key: "indented_cases")
    private(set) var indentedCases = false
}