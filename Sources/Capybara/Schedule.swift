import Foundation

func scheduleGames(
    _ games: [Game],
    allStarBreak: Set<Int>,
    christmasDay: Int
) -> [LeagueDay: [Game]] {
    var scheduleDictionary = [LeagueDay: [Game]]()
    var gamesCopy = games
    let leagueDays = LeagueDay.createLeagueDayList(
        allStarBreak: allStarBreak,
        christmasDay: christmasDay
    )
    /*
     STRATEGY
     - greedily schedule games without b2bs for any team
     - add in b2bs after
     - for each league day, loop through all available games, and schedule on day if possible
     */
    
    // INFO: - ignoring christmas for now
    
    // 1. greedily schedule with no b2bs
    for ld in leagueDays {
        if allStarBreak.contains(ld.rawValue) { continue }
        for game in gamesCopy {
            if scheduleDictionary.canSchedule(game: game, on: ld, shouldAllowBackToBacks: false) {
                if scheduleDictionary[ld] == nil {
                    scheduleDictionary[ld] = [game]
                } else {
                    scheduleDictionary[ld]!.append(game)
                }
                gamesCopy.remove(element: game)
            }
        }
    }
    // 2. add in b2bs
    for ld in leagueDays {
        if allStarBreak.contains(ld.rawValue) { continue }
        for game in gamesCopy {
            if scheduleDictionary.canSchedule(game: game, on: ld, shouldAllowBackToBacks: true) {
                if scheduleDictionary[ld] == nil {
                    scheduleDictionary[ld] = [game]
                } else {
                    scheduleDictionary[ld]!.append(game)
                }
                gamesCopy.remove(element: game)
            }
        }
    }
    
    assert(gamesCopy.isEmpty)

    return scheduleDictionary
}

