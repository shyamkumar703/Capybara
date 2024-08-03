import Foundation

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
}
