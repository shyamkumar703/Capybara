import Foundation

/*
 Users at minimum set a starting lineup
 7 additional lineups, along with game time to call timeout can be passed in as well
 */

/*
 IDEA: - maybe i can create a DSL and let users write "code" that plays a headless game against each other
 users cannot change the config after they queue in to start a game
 users could watch the game activity, and see the code execute in real time
 basically a headless coach
 15 variables that define each player to a user
 game loads basic roster (same) for each player
 user matches variables to players
 game runs
 
 do basic game mechanics first
 then begin implementing DSL to run game headlessly
 */
struct GameStrategy {
    let startingLineup: Lineup
    let substitutions: [LineupSubstitution]
    private init(startingLineup: Lineup, substitutions: [LineupSubstitution]) {
        self.startingLineup = startingLineup
        self.substitutions = substitutions
    }
    
    /// - `substitutions` can only contain up to 7 elements - only 7 timeouts allowed
    /// - `substitutions` cannot contain a time of 0:00, that's the start of the game
    /// - `substitutions` time must be unique; cannot have two substitutions at the exact same time
    public static func create(startingLineup: Lineup, substitutions: [LineupSubstitution]) -> Result<GameStrategy, CreationError> {
        guard substitutions.count <= 7 else {
            return .failure(.invalidNumberOfSubstitutions(substitutions.count))
        }
        var substitutionDictionary = [GameTime: Lineup]()
        for sub in substitutions {
            guard sub.gameTime != .start else {
                return .failure(.invalidSubstitutionScheduledForStartOfGame)
            }
            if let subAlreadyScheduledForTime = substitutionDictionary[sub.gameTime] {
                return .failure(
                    .clashingSubstitutions(
                        [.init(gameTime: sub.gameTime, lineup: subAlreadyScheduledForTime), sub]
                    )
                )
            } else {
                substitutionDictionary[sub.gameTime] = sub.lineup
            }
        }
        return .success(.init(startingLineup: startingLineup, substitutions: substitutions))
    }
}

extension GameStrategy {
    enum CreationError: Error {
        case invalidNumberOfSubstitutions(Int)
        case invalidSubstitutionScheduledForStartOfGame
        case clashingSubstitutions([LineupSubstitution])
    }
}

struct LineupSubstitution {
    let gameTime: GameTime
    let lineup: Lineup
    
    public init(gameTime: GameTime, lineup: Lineup) {
        self.gameTime = gameTime
        self.lineup = lineup
    }
}

struct Lineup {
    let pointGuard: Player
    let shootingGuard: Player
    let smallForward: Player
    let powerForward: Player
    let center: Player
}

struct GameTime: Equatable, Hashable {
    let minute: UInt8
    let second: UInt8
    public static let start: GameTime = .create(minute: 0, second: 0).unwrap()
    
    private init(minute: UInt8, second: UInt8) {
        self.minute = minute
        self.second = second
    }
    
    public static func create(minute: UInt8, second: UInt8) -> Result<GameTime, CreationError> {
        if !isValidMinute(minute) && !isValidSecond(second) {
            return .failure(.invalidMinutesAndSecondsProvided(minute: minute, second: second))
        } else if !isValidMinute(minute) {
            return .failure(.invalidMinuteProvided(minute))
        } else if !isValidSecond(second) {
            return .failure(.invalidSecondProvided(second))
        }
        
        return .success(.init(minute: minute, second: second))
    }
    
    private static func isValidMinute(_ minute: UInt8) -> Bool {
        return minute < 48
    }
    
    private static func isValidSecond(_ second: UInt8) -> Bool {
        return second < 60
    }
}

extension GameTime {
    enum CreationError: Error {
        case invalidMinuteProvided(UInt8)
        case invalidSecondProvided(UInt8)
        case invalidMinutesAndSecondsProvided(minute: UInt8, second: UInt8)
    }
}
