import Foundation

extension Array where Element == Game {
    func contains(_ team: Team) -> Bool {
        for game in self {
            if game.contains(team) {
                return true
            }
        }
        
        return false
    }
    
    func getGamesWith(_ team: Team) -> Game? {
        var game: Game?
        for loopGame in self {
            if loopGame.contains(team) {
                guard game == nil else {
                    fatalError("team \(team) playing more than one game on day")
                }
                game = loopGame
            }
        }
        return game
    }
}

extension Array where Element: Identifiable {
    @discardableResult
    mutating func remove(element: Element) -> Bool {
        for (index, loopElement) in self.enumerated() {
            if loopElement.id == element.id {
                self.remove(at: index)
                return true
            }
        }
        
        return false
    }
}

extension Array where Element == (LeagueDay, Game?) {
    func getNumberOfBackToBacks(for team: Team) -> Int {
        var backToBackCount = 0
        for index in 0..<self.count {
            let nextIndex = index + 1
            guard nextIndex < self.count else { break }
            guard let currentGame = self[index].1,
                  let nextGame = self[nextIndex].1 else {
                continue
            }
            if currentGame.contains(team) && nextGame.contains(team) {
                backToBackCount += 1
            }
        }
        return backToBackCount
    }
}
