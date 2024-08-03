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
