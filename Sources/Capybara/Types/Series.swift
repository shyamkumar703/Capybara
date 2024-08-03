import Foundation

struct Series {
    private let team1: Team
    private let team2: Team
    private let numberOfGames: Int

    public init(team1: Team, team2: Team, numberOfGames: Int) {
        self.team1 = team1
        self.team2 = team2
        self.numberOfGames = numberOfGames
    }

    func getGames() -> [Game] {
        var games = [Game]()
        for _ in 0..<numberOfGames {
            games.append(.init(team1: team1, team2: team2))
        }
        return games
    }
}
