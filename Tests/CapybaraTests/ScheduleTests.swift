//
//  ScheduleTests.swift
//
//
//  Created by Shyam Kumar on 6/9/24.
//

@testable import Capybara
import XCTest

final class ScheduleTests: XCTestCase {
    func testScheduleEveryTeamPlaysEightyTwoGames() {
        let matchupSchedule = generateMatchupScheduleOptions()
        for team in Team.allCases {
            let teamSchedule = matchupSchedule[team]!
            XCTAssertEqual(teamSchedule.count(.twoGameSetOppositeConference), 15)
            XCTAssertEqual(teamSchedule.count(.threeGameSetInConferenceOutOfDivision), 4)
            XCTAssertEqual(teamSchedule.count(.fourGameSetInDivision), 4)
            XCTAssertEqual(teamSchedule.count(.fourGameSetInConferenceOutOfDivision), 6)
            XCTAssertEqual(teamSchedule.getGameCount(), 82)
        }

        let games = unrollSchedule(matchupSchedule)
        XCTAssertEqual(games.count, 1230)
        for team in Team.allCases {
            XCTAssertEqual(games.getGameCountForTeam(team), 82)
        }
    }

    func testScheduleGames() {
        let matchupSchedule = generateMatchupScheduleOptions()
        let games = unrollSchedule(matchupSchedule)
        let christmasDay = 56
        let allStarBreak = Set(Array(116..<121))
        let gameSchedule = scheduleGames(
            games,
            allStarBreak: allStarBreak,
            christmasDay: christmasDay
        )
        var totalGameCount = 0
        for (leagueDay, games) in gameSchedule {
            if allStarBreak.contains(leagueDay.rawValue) {
                XCTAssert(games.isEmpty)
            }

            totalGameCount += games.count

            var teamSet = Set<Team>()
            for game in games {
                let (wasInsertedTeam1, _) = teamSet.insert(game.team1)
                XCTAssert(wasInsertedTeam1)
                let (wasInsertedTeam2, _) = teamSet.insert(game.team2)
                XCTAssert(wasInsertedTeam2)
            }
        }
        XCTAssertEqual(totalGameCount, 1230)
    }
}

extension Set where Element == MatchupScheduleOption {
    func getGameCount() -> Int {
        var totalGameCount = 0
        for element in self {
            totalGameCount += element.gameCount
        }
        return totalGameCount
    }
}

extension Array where Element == Game {
    func getGameCountForTeam(_ team: Team) -> Int {
        var gameCount: Int = 0
        for game in self {
            if game.team1 == team || game.team2 == team {
                gameCount += 1
            }
        }

        return gameCount
    }
}
