@testable import Capybara
import XCTest

final class TeamTests: XCTestCase {
    func testFiveTeamsPerDivision() {
        let teams = Team.allCases
        for division in Division.allCases {
            XCTAssertEqual(
                teams.countOfTeamsIn(division: division),
                5
            )
        }
    }
    
    func testFifteenTeamsPerConference() {
        let teams = Team.allCases
        for conference in Conference.allCases {
            XCTAssertEqual(
                teams.countOfTeamsIn(conference: conference),
                15
            )
        }
    }
}

extension Array where Element == Team {
    func countOfTeamsIn(division: Division) -> Int {
        filter({ $0.division == division }).count
    }
    
    func countOfTeamsIn(conference: Conference) -> Int {
        filter({ $0.conference == conference }).count
    }
}
