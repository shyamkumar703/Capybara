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
    
    func testScheduleGamesParallel() {
        let expectation = expectation(description: "waiting for completion")
        let matchupSchedule = generateMatchupScheduleOptions()
        let games = unrollSchedule(matchupSchedule)
        scheduleGamesParallel(games) { schedule in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }

//    func testScheduleGames() {
//        let matchupSchedule = generateMatchupScheduleOptions()
//        let games = unrollSchedule(matchupSchedule)
//        let gameSchedule = scheduleGames(games)
//        var totalGameCount = 0
//        for (leagueDay, games) in gameSchedule {
//            if leagueDay.rawValue >= 116 && leagueDay.rawValue <= 120 {
//                XCTAssert(games.isEmpty)
//            }
//            totalGameCount += games.count
//            let validGameCount = games.count == 8 || games.count == 7 || games.count == 6 || games.count == 0
//            XCTAssert(validGameCount)
//
//            var teamSet = Set<Team>()
//            for game in games {
//                let (wasInsertedTeam1, _) = teamSet.insert(game.team1)
//                XCTAssert(wasInsertedTeam1)
//                let (wasInsertedTeam2, _) = teamSet.insert(game.team2)
//                XCTAssert(wasInsertedTeam2)
//            }
//        }
//        XCTAssertEqual(totalGameCount, 1230)
//    }
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
