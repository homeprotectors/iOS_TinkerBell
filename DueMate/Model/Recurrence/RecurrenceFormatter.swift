import Foundation

enum RecurrenceFormatter {
    static func displayText(_ rule: RecurrenceRule) -> String {
        switch rule {
        case .perWeek:
            return "1주에 1번"
        case .per2Weeks:
            return "2주에 1번"
        case .perMonth:
            return "한달에 1번"
        case .fixedDay(let days):
            guard !days.isEmpty else { return "고정 요일 없음" }
            let sorted = days.sorted { $0.order < $1.order }
            return "매주 " + sorted.map(\.display).joined(separator: ", ")
        case .fixedDate(let dates):
            guard !dates.isEmpty else { return "고정 일자 없음" }
            let sorted = dates.sorted(by: sortDateOptions)
            let labels = sorted.map { option in
                switch option {
                case .day(let day):
                    return "\(day)일"
                case .endOfMonth:
                    return "말일"
                }
            }
            return "매월 " + labels.joined(separator: ", ")
        case .fixedMonth(let months):
            guard !months.isEmpty else { return "고정 월 없음" }
            let sorted = months.sorted { (Int($0.rawValue) ?? 0) < (Int($1.rawValue) ?? 0) }
            return "매년 " + sorted.map(\.display).joined(separator: ", ")
        }
    }
    
    static func displayText(recurrenceType: String?, selectedCycle: [String]?) -> String {
        guard let recurrenceType,
              let rule = RecurrenceMapper.fromDTO(
                RecurrenceDTO(recurrenceType: recurrenceType, selectedCycle: selectedCycle)
              )
        else {
            return ""
        }
        return displayText(rule)
    }
    
    private static func sortDateOptions(lhs: DateOptions, rhs: DateOptions) -> Bool {
        switch (lhs, rhs) {
        case (.endOfMonth, .endOfMonth):
            return false
        case (.endOfMonth, .day):
            return false
        case (.day, .endOfMonth):
            return true
        case let (.day(a), .day(b)):
            return a < b
        }
    }
}

