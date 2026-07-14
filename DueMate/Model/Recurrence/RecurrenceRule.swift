import Foundation

enum RecurrenceRule: Equatable {
    case perWeek
    case per2Weeks
    case perMonth
    case fixedDay(Set<DayOptions>)
    case fixedDate(Set<DateOptions>)
    case fixedMonth(Set<MonthOptions>)
    
    var isFixed: Bool {
        switch self {
        case .fixedDay, .fixedDate, .fixedMonth:
            return true
        default:
            return false
        }
    }
}

struct RecurrenceDTO: Equatable {
    let recurrenceType: String
    let selectedCycle: [String]?
    
    init(recurrenceType: String, selectedCycle: [String]?) {
        self.recurrenceType = recurrenceType
        self.selectedCycle = selectedCycle ?? []
    }
}
