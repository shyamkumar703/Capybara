//
//  Schedule.swift
//
//
//  Created by Shyam Kumar on 6/9/24.
//

import Foundation


/*
 2 games against the 15 teams from the other conference: 30
 4 games against the other 4 division opponents: 16
 4 games against 6 opponents (out-of-division, in-conference): 24
 3 games against the remaining 4 out-of-division, in-conference opponents: 12
 */

enum MatchupScheduleOption: Equatable, Hashable {
    case twoGameSetOppositeConference(MatchupInfo)
    case threeGameSetInConferenceOutOfDivision(MatchupInfo)
    case fourGameSetInDivision(MatchupInfo)
    case fourGameSetInConferenceOutOfDivision(MatchupInfo)

    var matchupInfo: MatchupInfo {
        switch self {
        case .twoGameSetOppositeConference(let matchupInfo):
            return matchupInfo
        case .threeGameSetInConferenceOutOfDivision(let matchupInfo):
            return matchupInfo
        case .fourGameSetInDivision(let matchupInfo):
            return matchupInfo
        case .fourGameSetInConferenceOutOfDivision(let matchupInfo):
            return matchupInfo
        }
    }

    static func create(_ companion: Companion, team1: Team, team2: Team, id: String) -> Self {
        let matchupInfo = MatchupInfo(id: id, team1: team1, team2: team2)
        switch companion {
        case .twoGameSetOppositeConference:
            return .twoGameSetOppositeConference(matchupInfo)
        case .threeGameSetInConferenceOutOfDivision:
            return .threeGameSetInConferenceOutOfDivision(matchupInfo)
        case .fourGameSetInDivision:
            return .fourGameSetInDivision(matchupInfo)
        case .fourGameSetInConferenceOutOfDivision:
            return .fourGameSetInConferenceOutOfDivision(matchupInfo)
        }
    }

    enum Companion {
        case twoGameSetOppositeConference
        case threeGameSetInConferenceOutOfDivision
        case fourGameSetInDivision
        case fourGameSetInConferenceOutOfDivision

        var total: Int {
            switch self {
            case .twoGameSetOppositeConference:
                return 15
            case .threeGameSetInConferenceOutOfDivision:
                return 4
            case .fourGameSetInDivision:
                return 4
            case .fourGameSetInConferenceOutOfDivision:
                return 6
            }
        }
    }

    var companion: Companion {
        switch self {
        case .twoGameSetOppositeConference: .twoGameSetOppositeConference
        case .threeGameSetInConferenceOutOfDivision: .threeGameSetInConferenceOutOfDivision
        case .fourGameSetInDivision: .fourGameSetInDivision
        case .fourGameSetInConferenceOutOfDivision: .fourGameSetInConferenceOutOfDivision
        }
    }

    var gameCount: Int {
        switch self {
        case .twoGameSetOppositeConference: return 2
        case .threeGameSetInConferenceOutOfDivision: return 3
        case .fourGameSetInDivision: return 4
        case .fourGameSetInConferenceOutOfDivision: return 4
        }
    }
}

extension MatchupScheduleOption {
    struct MatchupInfo: Hashable, Equatable, Identifiable {
        let id: String
        let team1: Team
        let team2: Team
    }
}

extension Collection where Element == MatchupScheduleOption {
    func count(_ companion: MatchupScheduleOption.Companion) -> Int {
        filter({ $0.companion == companion }).count
    }
}

extension Dictionary where Key == Team, Value == Set<MatchupScheduleOption> {
    mutating func insert(id: String, team1: Team, team2: Team, _ scheduleOption: MatchupScheduleOption.Companion) {
        guard let set1 = self[team1],
              let set2 = self[team2] else { return }
        guard set1.count(scheduleOption) < scheduleOption.total else {
            return
        }
        guard set2.count(scheduleOption) < scheduleOption.total else {
            return
        }
        self[team1]?.insert(.create(scheduleOption, team1: team1, team2: team2, id: id))
        self[team2]?.insert(.create(scheduleOption, team1: team2, team2: team1, id: id))
    }

    typealias SuccessType = (fourGameTeams: [Team], threeGameTeams: [Team])
    enum GenerationError: Error {
        case wallHit
    }
    func split(team: Team, teamArr: [Team]) -> Result<SuccessType, GenerationError>  {
        guard let set = self[team] else {
            fatalError()
        }
        let threeGameOption = MatchupScheduleOption.Companion.threeGameSetInConferenceOutOfDivision
        let fourGameOption = MatchupScheduleOption.Companion.fourGameSetInConferenceOutOfDivision
        let threeGameSetsNeeded = threeGameOption.total - set.count(threeGameOption)
        let fourGameSetsNeeded = fourGameOption.total - set.count(fourGameOption)

        var fourGameTeams = [Team]()
        var threeGameTeams = [Team]()

        var satisfyFourGameConstraints = [Team]()
        var satisfyThreeGameConstraints = [Team]()
        var satisfyBothConstraints = [Team]()

        for opposingTeam in teamArr {
            if fourGameTeams.count == fourGameSetsNeeded && threeGameTeams.count == threeGameSetsNeeded {
                return .success((fourGameTeams, threeGameTeams))
            }

            guard let opposingTeamSet = self[opposingTeam] else {
                fatalError()
            }

            if opposingTeamSet.count(fourGameOption) < fourGameOption.total && opposingTeamSet.count(threeGameOption) < threeGameOption.total {
                satisfyBothConstraints.append(opposingTeam)
            } else {
                if opposingTeamSet.count(fourGameOption) < fourGameOption.total {
                    satisfyFourGameConstraints.append(opposingTeam)
                } else if opposingTeamSet.count(threeGameOption) < threeGameOption.total {
                    satisfyThreeGameConstraints.append(opposingTeam)
                }
            }
        }

        while fourGameTeams.count < fourGameSetsNeeded {
            guard !satisfyFourGameConstraints.isEmpty || !satisfyBothConstraints.isEmpty else {
                return .failure(.wallHit)
            }

            if let fourGameSetTeam = satisfyFourGameConstraints.popLast() {
                fourGameTeams.append(fourGameSetTeam)
            } else if let fourGameSetTeam = satisfyBothConstraints.popLast() {
                fourGameTeams.append(fourGameSetTeam)
            } else {
                return .failure(.wallHit)
            }
        }

        while threeGameTeams.count < threeGameSetsNeeded {
            guard !satisfyThreeGameConstraints.isEmpty || !satisfyBothConstraints.isEmpty else {
                return .failure(.wallHit)
            }

            if let threeGameSetTeam = satisfyThreeGameConstraints.popLast() {
                threeGameTeams.append(threeGameSetTeam)
            } else if let threeGameSetTeam = satisfyBothConstraints.popLast() {
                threeGameTeams.append(threeGameSetTeam)
            } else {
                return .failure(.wallHit)
            }
        }

        return .success((fourGameTeams, threeGameTeams))
    }

    func dump() {
        var dump = "\nASSERTION FAILURE: DUMP\n"
        for (key, value) in self {
            dump += "\(key.rawValue.uppercased())\n=======================\n"
            for scheduleOption in value {
                switch scheduleOption {
                case .fourGameSetInConferenceOutOfDivision(let matchupInfo):
                    dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 4 GAMES IN CONFERENCE OUT OF DIVISION\n"
                case .fourGameSetInDivision(let matchupInfo):
                    dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 4 GAMES IN DIVISION\n"
                case .threeGameSetInConferenceOutOfDivision(let matchupInfo):
                    dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 3 GAMES IN CONFERENCE OUT OF DIVISION\n"
                case .twoGameSetOppositeConference(let matchupInfo):
                    dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 2 GAMES IN OPPOSITE CONFERENCE\n"
                }
            }
        }

        print(dump)
    }
}

extension Set where Element == MatchupScheduleOption {
    func printSchedule() {
        var dump = "\nSCHEDULE\n===================\n"
        for scheduleOption in self {
            switch scheduleOption {
            case .fourGameSetInConferenceOutOfDivision(let matchupInfo):
                dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 4 GAMES IN CONFERENCE OUT OF DIVISION\n"
            case .fourGameSetInDivision(let matchupInfo):
                dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 4 GAMES IN DIVISION\n"
            case .threeGameSetInConferenceOutOfDivision(let matchupInfo):
                dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 3 GAMES IN CONFERENCE OUT OF DIVISION\n"
            case .twoGameSetOppositeConference(let matchupInfo):
                dump += "\(matchupInfo.team1.rawValue.uppercased()) vs \(matchupInfo.team2.rawValue.uppercased()) · 2 GAMES IN OPPOSITE CONFERENCE\n"
            }
        }

        print(dump)
    }
}



func generateMatchupScheduleOptions() -> [Team: Set<MatchupScheduleOption>] {
    var matchupScheduleOptions = [Team: Set<MatchupScheduleOption>]()
    for team in Team.allCases {
        matchupScheduleOptions[team] = Set<MatchupScheduleOption>()
    }

    for team in Team.allCases.shuffled() {
        // two game set, opposite conference
        let oppositeConferenceTeams = team.getAllTeamsFromOppositeConference().shuffled()
        for oppositeConferenceTeam in oppositeConferenceTeams {
            matchupScheduleOptions.insert(id: UUID().uuidString, team1: team, team2: oppositeConferenceTeam, .twoGameSetOppositeConference)
        }

        // four game set, other 4 division teams
        let otherTeamsInDivision = team.getAllOtherTeamsInDivision().shuffled()
        for otherTeamInDivision in otherTeamsInDivision {
            matchupScheduleOptions.insert(id: UUID().uuidString, team1: team, team2: otherTeamInDivision, .fourGameSetInDivision)
        }

        let teamsInConferenceButNotInDivision = team.getAllTeamsOutOfDivisionButInConference().shuffled()
        assert(teamsInConferenceButNotInDivision.count == 10)

        switch matchupScheduleOptions.split(team: team, teamArr: teamsInConferenceButNotInDivision) {
        case .success(let (fourGameSetTeams, threeGameSetTeams)):
            for fourGameSetTeam in fourGameSetTeams {
                matchupScheduleOptions.insert(id: UUID().uuidString, team1: team, team2: fourGameSetTeam, .fourGameSetInConferenceOutOfDivision)
            }

            for threeGameSetTeam in threeGameSetTeams {
                matchupScheduleOptions.insert(id: UUID().uuidString, team1: team, team2: threeGameSetTeam, .threeGameSetInConferenceOutOfDivision)
            }

            assert(matchupScheduleOptions[team]!.count(.twoGameSetOppositeConference) == 15)
            assert(matchupScheduleOptions[team]!.count(.threeGameSetInConferenceOutOfDivision) == 4)
            assert(matchupScheduleOptions[team]!.count(.fourGameSetInDivision) == 4)
            assert(matchupScheduleOptions[team]!.count(.fourGameSetInConferenceOutOfDivision) == 6)
        case .failure:
            return generateMatchupScheduleOptions()
        }

    }

    return matchupScheduleOptions
}

func unrollSchedule(_ schedule: [Team: Set<MatchupScheduleOption>]) -> [Game] {
    var allSeries = [String: Series]()
    for (_, gameSet) in schedule {
        for game in gameSet {
            let matchupInfo = game.matchupInfo
            if allSeries[matchupInfo.id] == nil {
                let series = Series(team1: matchupInfo.team1, team2: matchupInfo.team2, numberOfGames: game.gameCount)
                allSeries[matchupInfo.id] = series
            }
        }
    }

    var games = [Game]()
    for (_, series) in allSeries {
        games += series.getGames()
    }

    return games.shuffled()
}

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

extension Array where Element == Game {
    func contains(_ team: Team) -> Bool {
        for game in self {
            if game.contains(team) {
                return true
            }
        }

        return false
    }

    /// Returns (index, game) if possible
    func getAGameExcludingBackToBacks(previousDayGames: [Game]) -> Game? {
        var teams = Set<Team>()
        for game in previousDayGames {
            teams.insert(game.team1)
            teams.insert(game.team2)
        }

        for game in self {
            if !teams.contains(game.team1) && !teams.contains(game.team2) {
                return game
            }
        }

        return nil
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
