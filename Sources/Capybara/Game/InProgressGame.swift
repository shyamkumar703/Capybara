import Foundation

class InProgressGame {
    
}

// MARK: - GameLoop
class GameLoop {
    private var teamLineups: [Team: Lineup]
    private var gameTime: GameTime = .start
    private lazy var timer: Timer = .init(
        timeInterval: 1,
        repeats: true,
        block: { [weak self]_ in
            guard let self else { return }
            self.tick()
        }
    )
    private var gameState: GameState = .gameNotStarted
    
    public init(team1: Team, lineup1: Lineup, team2: Team, lineup2: Lineup) {
        var teamLineups = [Team: Lineup]()
        teamLineups[team1] = lineup1
        teamLineups[team2] = lineup2
        self.teamLineups = teamLineups
    }
    
    public func startGame() {
        // start running game loop
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func tick() {
        switch gameState {
        case .gameNotStarted:
            // start game
            print(gameState)
        case .timeout(let team, let ticksLeft):
            // not sure what to do here
            print(gameState)
        case .quarterEnd:
            // not sure what to do here
            print(gameState)
        case .gameOver:
            // not sure what to do here
            print(gameState)
        case .quarterInProgress(let quarter, let ticksLeft):
            print(gameState)
        }
    }
}

enum GameState {
    case gameNotStarted
    case timeout(team: Team, ticksLeft: Int)
    case quarterEnd(ticksLeft: Int)
    case quarterInProgress(quarter: Quarter, ticksLeft: Int)
    case gameOver
}

enum Quarter: Int {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
}
