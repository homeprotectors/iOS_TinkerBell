import Foundation

struct ChoreRecurrenceDraft: Equatable {
    var rule: RecurrenceRule = .perWeek
    
    var isFixed: Bool {
        rule.isFixed
    }
    
    var cycleOption: CycleOption {
        switch rule {
        case .perWeek:
            return .simple(.weekly)
        case .per2Weeks:
            return .simple(.biweekly)
        case .perMonth:
            return .simple(.monthly)
        case .fixedDay:
            return .fixed(.day)
        case .fixedDate:
            return .fixed(.date)
        case .fixedMonth:
            return .fixed(.month)
        }
    }
    
    var isValidForSave: Bool {
        switch rule {
        case .fixedDay(let days):
            return !days.isEmpty
        case .fixedDate(let dates):
            return !dates.isEmpty
        case .fixedMonth(let months):
            return !months.isEmpty
        default:
            return true
        }
    }
    
    mutating func setFixed(_ isFixed: Bool) {
        if isFixed {
            if !rule.isFixed {
                rule = .fixedDay([])
            }
        } else {
            if rule.isFixed {
                rule = .perWeek
            }
        }
    }
    
    mutating func setCycleOption(_ option: CycleOption) {
        switch option {
        case .simple(.weekly):
            rule = .perWeek
        case .simple(.biweekly):
            rule = .per2Weeks
        case .simple(.monthly):
            rule = .perMonth
        case .fixed(.day):
            if case .fixedDay = rule { return }
            rule = .fixedDay([])
        case .fixed(.date):
            if case .fixedDate = rule { return }
            rule = .fixedDate([])
        case .fixed(.month):
            if case .fixedMonth = rule { return }
            rule = .fixedMonth([])
        }
    }
    
    mutating func toggleDay(_ day: DayOptions) {
        guard case .fixedDay(var days) = rule else { return }
        if days.contains(day) { days.remove(day) } else { days.insert(day) }
        rule = .fixedDay(days)
    }
    
    mutating func toggleDate(_ date: DateOptions) {
        guard case .fixedDate(var dates) = rule else { return }
        if dates.contains(date) { dates.remove(date) } else { dates.insert(date) }
        rule = .fixedDate(dates)
    }
    
    mutating func toggleMonth(_ month: MonthOptions) {
        guard case .fixedMonth(var months) = rule else { return }
        if months.contains(month) { months.remove(month) } else { months.insert(month) }
        rule = .fixedMonth(months)
    }
    
    func containsDay(_ day: DayOptions) -> Bool {
        guard case .fixedDay(let days) = rule else { return false }
        return days.contains(day)
    }
    
    func containsDate(_ date: DateOptions) -> Bool {
        guard case .fixedDate(let dates) = rule else { return false }
        return dates.contains(date)
    }
    
    func containsMonth(_ month: MonthOptions) -> Bool {
        guard case .fixedMonth(let months) = rule else { return false }
        return months.contains(month)
    }
}

