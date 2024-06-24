import Foundation

struct LeagueDay: Hashable {
    let rawValue: Int
    var isInAllStarBreak: Bool
    static let daysInRegularSeason: Int = 174

    public init?(_ day: Int, isInAllStarBreak: Bool = false) {
        guard day < Self.daysInRegularSeason,
            day >= 0 else { return nil }
        self.rawValue = day
        self.isInAllStarBreak = isInAllStarBreak
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

func scheduleGames(_ games: [Game]) -> [LeagueDay: [Game]] {
    // 174 league days
    // 1230 games
    // 116 days to all-star break
    // 5 days off for all-star break
    // 53 days after all-star break
    // 169 days of league play for 1230 games
    // 117, 118, 119, 120, 121 are all star break

    // 120 days with 7 games
    // 48 days with 8 games
    // 1 day with 6 games
    var scheduleDictionary = [LeagueDay: [Game]]()
    var gamesCopy = games.shuffled()
    var gameCounts: [Int] = (Array(repeating: 7, count: 120) + Array(repeating: 8, count: 48) + [6]).shuffled()

    gameCounts.insert(0, at: 116)
    gameCounts.insert(0, at: 117)
    gameCounts.insert(0, at: 118)
    gameCounts.insert(0, at: 119)
    gameCounts.insert(0, at: 120)
    
    var failedLeagueDays = [LeagueDay]()

    // populate dictionary
    for day in 0..<LeagueDay.daysInRegularSeason {
        guard var ld = LeagueDay(day) else {
            fatalError()
        }

        guard gameCounts[day] > 0 else {
            ld.isInAllStarBreak = true
            scheduleDictionary[ld] = []
            continue
        }

        let gamesScheduledOnPreviousDay = getGamesScheduledOnPreviousDay(
            day: ld,
            schedule: scheduleDictionary
        )

        let scheduleGamesResult = scheduleGames(
            gamesOnPreviousDay: gamesScheduledOnPreviousDay,
            gamesRemaining: &gamesCopy,
            gameCount: gameCounts[day]
        )
        
        switch scheduleGamesResult {
        case .success(let games):
            scheduleDictionary[ld] = games
        case .failure(let games):
            scheduleDictionary[ld] = games
            failedLeagueDays.append(ld)
        }
    }
    
    scheduleOrphanedGames(
        currentSchedule: &scheduleDictionary,
        gamesRemaining: &gamesCopy
    )

    return scheduleDictionary
}

private func scheduleOrphanedGames(
    currentSchedule: inout [LeagueDay: [Game]],
    gamesRemaining: inout [Game]
) {
    // find already scheduled games that can slot into the failed league days to get up to `gameCount`
    // create a copy of failed league days and add relevant league days in as games are moved
    // retry until copy of failed league days is empty.
    
    // create failedLeagueDays dictionary
    for game in gamesRemaining {
        let leagueDay = findLeagueDayToAdd(game: game, schedule: currentSchedule)
        currentSchedule[leagueDay]?.append(game)
    }
    
    gamesRemaining.removeAll()
}

private func findLeagueDayToAdd(game: Game, schedule: [LeagueDay: [Game]]) -> LeagueDay {
    for (leagueDay, gamesScheduled) in schedule {
        guard !leagueDay.isInAllStarBreak else {
            continue
        }
        
        if !gamesScheduled.containsAnyParticipant(game) {
            return leagueDay
        }
    }
    
    fatalError()
}

enum ScheduleGameError: Error {
    case invalidScheduling
}

enum ScheduleGameResult {
    case success([Game])
    case failure([Game])
}

private func scheduleGames(
    gamesOnPreviousDay: [Game],
    gamesRemaining: inout [Game],
    gameCount: Int
) -> ScheduleGameResult {
    var gamesRemainingToScheduleOnDay = gameCount
    var gamesToScheduleOnDay = [Game]()
    while gamesRemainingToScheduleOnDay > 0 {
        defer { gamesRemainingToScheduleOnDay -= 1 }
        if let validGame = gamesRemaining.getAGameExcludingBackToBacks(previousDayGames: gamesOnPreviousDay + gamesToScheduleOnDay) {
            gamesToScheduleOnDay.append(validGame)
            gamesRemaining.remove(element: validGame)
        } else {
            guard let game = gamesRemaining.getAGameExcludingBackToBacks(previousDayGames: gamesToScheduleOnDay) else {
                // no games left?
                // shouldn't happen theoretically
                return .failure(gamesToScheduleOnDay)
            }
            gamesToScheduleOnDay.append(game)
            gamesRemaining.remove(element: game)
        }
    }

    return .success(gamesToScheduleOnDay)
}

private func getGamesScheduledOnPreviousDay(
    day: LeagueDay,
    schedule: [LeagueDay: [Game]]
) -> [Game] {
    guard let previousDay = day.previous() else {
        return []
    }

    return schedule[previousDay] ?? []
}
