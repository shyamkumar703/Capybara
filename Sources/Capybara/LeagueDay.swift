import Foundation

struct LeagueDay: Hashable {
    let rawValue: Int
    static let daysInRegularSeason: Int = 174

    public init?(_ day: Int) {
        guard day < Self.daysInRegularSeason,
            day >= 0 else { return nil }
        self.rawValue = day
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

func scheduleGamesParallel(
    _ games: [Game],
    completion: @escaping ([LeagueDay: [Game]]) -> Void
) {
    let pool = ParallelWorkerPool(
        numberOfWorkers: 50,
        work: { return scheduleGames(games) },
        completion: completion
    )
    
    pool.run()
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
    var gamesCopy = games
    var gameCounts: [Int] = (Array(repeating: 7, count: 120) + Array(repeating: 8, count: 48) + [6]).shuffled()

    gameCounts.insert(0, at: 116)
    gameCounts.insert(0, at: 117)
    gameCounts.insert(0, at: 118)
    gameCounts.insert(0, at: 119)
    gameCounts.insert(0, at: 120)

    // populate dictionary
    for day in 0..<LeagueDay.daysInRegularSeason {
        guard let ld = LeagueDay(day) else {
            fatalError()
        }

        guard gameCounts[day] > 0 else {
            scheduleDictionary[ld] = []
            continue
        }

        let gamesScheduledOnPreviousDay = getGamesScheduledOnPreviousDay(
            day: ld,
            schedule: scheduleDictionary
        )

        let scheduledGames = scheduleGames(
            gamesOnPreviousDay: gamesScheduledOnPreviousDay,
            gamesRemaining: &gamesCopy,
            gameCount: gameCounts[day]
        )
        
        switch scheduledGames {
        case .success(let games):
            scheduleDictionary[ld] = games
        case .failure:
            return scheduleGames(games.shuffled())
        }

    }

    assert(gamesCopy.isEmpty)

    return scheduleDictionary
}

enum ScheduleGameError: Error {
    case invalidScheduling
}

private func scheduleGames(
    gamesOnPreviousDay: [Game],
    gamesRemaining: inout [Game],
    gameCount: Int
) -> Result<[Game], ScheduleGameError> {
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
                return .failure(.invalidScheduling)
            }
            gamesToScheduleOnDay.append(game)
            gamesRemaining.remove(element: game)
        }
    }

    assert(gamesToScheduleOnDay.count == gameCount)

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
