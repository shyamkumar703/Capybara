import Foundation

struct LeagueDay: Hashable {
    let rawValue: Int
    let dayType: DayType?
    static let daysInRegularSeason: Int = 174

    public init?(
        _ day: Int,
        type: DayType? = nil
    ) {
        guard day < Self.daysInRegularSeason,
            day >= 0 else { return nil }
        self.rawValue = day
        self.dayType = type
    }

    static func createLeagueDayList(
      allStarBreak: Set<Int>,
        christmasDay: Int
    ) -> [LeagueDay] {
        var leagueDays = [LeagueDay]()
        for day in 0..<daysInRegularSeason {
            if allStarBreak.contains(day) {
                guard let ld = LeagueDay(day, type: .allStarBreak) else {
                    fatalError()
                }
                leagueDays.append(ld)
                continue
            }

            if day == christmasDay {
                guard let ld = LeagueDay(day, type: .christmas) else {
                    fatalError()
                }
                leagueDays.append(ld)
                continue
            }

            guard let ld = LeagueDay(day) else {
                fatalError()
            }

            leagueDays.append(ld)
        }

        return leagueDays
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

    func previous() -> Self? {
        return .init(rawValue - 1)
    }

    func next() -> Self? {
        return .init(rawValue + 1)
    }
}

extension LeagueDay {
    enum DayType {
        case allStarBreak
        case christmas
    }
}
