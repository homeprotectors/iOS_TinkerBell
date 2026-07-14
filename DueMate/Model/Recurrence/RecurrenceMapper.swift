import Foundation

enum RecurrenceMapper {
    static func fromDTO(_ dto: RecurrenceDTO) -> RecurrenceRule? {
        switch dto.recurrenceType {
        case "PER_WEEK":
            return .perWeek
        case "PER_2WEEKS":
            return .per2Weeks
        case "PER_MONTH":
            return .perMonth
        case "FIXED_DAY":
            let days = Set((dto.selectedCycle ?? []).compactMap(DayOptions.init(rawValue:)))
            return .fixedDay(days)
        case "FIXED_DATE":
            let dates = Set((dto.selectedCycle ?? []).compactMap(parseDateOption))
            return .fixedDate(dates)
        case "FIXED_MONTH":
            let months = Set((dto.selectedCycle ?? []).compactMap(MonthOptions.init(rawValue:)))
            return .fixedMonth(months)
        default:
            return nil
        }
    }
    
    static func toDTO(_ rule: RecurrenceRule) -> RecurrenceDTO {
        switch rule {
        case .perWeek:
            return RecurrenceDTO(recurrenceType: "PER_WEEK", selectedCycle: nil)
        case .per2Weeks:
            return RecurrenceDTO(recurrenceType: "PER_2WEEKS", selectedCycle: nil)
        case .perMonth:
            return RecurrenceDTO(recurrenceType: "PER_MONTH", selectedCycle: nil)
        case .fixedDay(let days):
            let sorted = days.sorted { $0.order < $1.order }
            return RecurrenceDTO(
                recurrenceType: "FIXED_DAY",
                selectedCycle: sorted.map(\.rawValue)
            )
        case .fixedDate(let dates):
            let sorted = dates.sorted(by: sortDateOptions)
            return RecurrenceDTO(
                recurrenceType: "FIXED_DATE",
                selectedCycle: sorted.map(\.serverData)
            )
        case .fixedMonth(let months):
            let sorted = months.sorted { (Int($0.rawValue) ?? 0) < (Int($1.rawValue) ?? 0) }
            return RecurrenceDTO(
                recurrenceType: "FIXED_MONTH",
                selectedCycle: sorted.map(\.rawValue)
            )
        }
    }
    
    private static func parseDateOption(_ raw: String) -> DateOptions? {
        if raw == "END" { return .endOfMonth }
        guard let day = Int(raw), (1...30).contains(day) else { return nil }
        return .day(day)
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

