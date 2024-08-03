import Foundation

extension Dictionary where Key == LeagueDay, Value == [Game] {
    func canSchedule(
        game: Game,
        on leagueDay: LeagueDay,
        shouldAllowBackToBacks: Bool
    ) -> Bool {
        let gamesCurrentlyScheduledOnLeagueDay = self[leagueDay] ?? []
        if gamesCurrentlyScheduledOnLeagueDay.contains(game.team1) || gamesCurrentlyScheduledOnLeagueDay.contains(game.team2) {
            return false
        }
        // previous league day
        guard let previousLeagueDay = leagueDay.previous(),
              let gamesScheduledOnPreviousLeagueDay = self[previousLeagueDay] else {
            // if no previous league day, or no games scheduled, we're good to go
            return true
        }
        
        if gamesScheduledOnPreviousLeagueDay.contains(game.team1) || gamesScheduledOnPreviousLeagueDay.contains(game.team2) {
            // if we're not allowing b2bs, this disqualifies the game from being scheduled
            guard shouldAllowBackToBacks else { return false }
            // if we're allowing b2bs, we NEED to make sure we're not scheduling 3 in a row
            guard let previousPreviousLeagueDay = previousLeagueDay.previous(),
                  let gamesScheduledOnPreviousPreviousLeagueDay = self[previousPreviousLeagueDay] else {
                // if no previous previous league day, we're good to go
                return true
            }
            if gamesScheduledOnPreviousPreviousLeagueDay.contains(game.team1) || gamesScheduledOnPreviousPreviousLeagueDay.contains(game.team2) {
                return false
            } else {
                // if this isn't a 3-in-a-row for either team, we're good to go
                return true
            }
        } else {
            // if this isn't a b2b for either team anyway, we're good
            return true
        }
    }
    
    func getSchedule(for team: Team) -> [(LeagueDay, Game?)] {
        var teamSchedule = [(LeagueDay, Game?)]()
        for (ld, games) in self {
            teamSchedule.append((ld, games.getGamesWith(team)))
        }
        teamSchedule.sort(by: { $0.0.rawValue < $1.0.rawValue })
        return teamSchedule
    }
}
