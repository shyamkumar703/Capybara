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
        let gameSchedule = scheduleGames(games)
        var totalGameCount = 0
        for (leagueDay, games) in gameSchedule {
            if leagueDay.rawValue >= 116 && leagueDay.rawValue <= 120 {
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
        
        for team in Team.allCases {
            let longestStreak = getLongestBackToBackStreak(team: team, schedule: gameSchedule)
            print("\n\(team) longest b2b streak: \(longestStreak)\n")
        }
    }
    
    private func getLongestBackToBackStreak(team: Team, schedule: [LeagueDay: [Game]]) -> Int {
        var currentStreak = 0
        var longestStreak = 0
        for day in 0..<LeagueDay.daysInRegularSeason {
            guard let ld = LeagueDay(day) else {
                fatalError()
            }
            guard let games = schedule[ld] else {
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
                currentStreak = 0
                continue
            }
            
            if games.contains(team) {
                currentStreak += 1
            } else {
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
                currentStreak = 0
            }
        }
        return max(currentStreak, longestStreak)
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
