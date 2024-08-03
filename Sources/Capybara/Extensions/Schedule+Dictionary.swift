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
        guard !shouldAllowBackToBacks,
              let previousLeagueDay = leagueDay.previous() else {
            return true
        }
        let gamesCurrentlyScheduledOnPreviousLeagueDay = self[previousLeagueDay] ?? []
        if gamesCurrentlyScheduledOnPreviousLeagueDay.contains(game.team1) || gamesCurrentlyScheduledOnLeagueDay.contains(game.team2) {
            return false
        } else {
            // even if we allow b2bs, we CANNOT allow 3 in a row
            guard let previousPreviousLeagueDay = previousLeagueDay.previous() else {
                // if there is no previous previous league day, we're good
                return true
            }
            let gamesCurrentlyScheduledOnPreviousPreviousLeagueDay = self[previousPreviousLeagueDay] ?? []
            if gamesCurrentlyScheduledOnPreviousPreviousLeagueDay.contains(game.team1) || gamesCurrentlyScheduledOnPreviousPreviousLeagueDay.contains(game.team2) {
                return false
            } else {
                return true
            }
        }
    }
}
