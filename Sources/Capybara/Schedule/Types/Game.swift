import Foundation

struct Game: Identifiable {
    let id: UUID = .init()
    let team1: Team
    let team2: Team

    public init(team1: Team, team2: Team) {
        self.team1 = team1
        self.team2 = team2
    }

    public func contains(_ team: Team) -> Bool {
        return team == team1 || team == team2
    }
}
