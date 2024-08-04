@testable import Capybara
import XCTest

final class GameStrategyTests: XCTestCase {
    func testGameTimeInit_InvalidMinutesProvided_ReturnsInvalidMinutesProvidedError() {
        switch GameTime.create(minute: 49, second: 0) {
        case .success:
            XCTFail("this game time creation should fail, games are only 48 minutes long")
        case .failure(let error):
            switch error {
            case .invalidMinutesAndSecondsProvided, .invalidSecondProvided:
                XCTFail("this game time creation should fail with error invalidMinutesProvided")
            case .invalidMinuteProvided(let minute):
                XCTAssertEqual(minute, 49)
            }
        }
    }
    
    func testGameTimeInit_InvalidSecondsProvided_ReturnsInvalidSecondsProvidedError() {
        switch GameTime.create(minute: 0, second: 61) {
        case .success:
            XCTFail("this game time creation should fail, minutes are only 60 seconds long")
        case .failure(let error):
            switch error {
            case .invalidMinutesAndSecondsProvided, .invalidMinuteProvided:
                XCTFail("this game time creation should fail with error invalidSecondsProvided")
            case .invalidSecondProvided(let second):
                XCTAssertEqual(second, 61)
            }
        }
    }
    
    func testGameTimeInit_InvalidMinutesAndInvalidSecondsProvided_ReturnsNil() {
        switch GameTime.create(minute: 51, second: 66) {
        case .success:
            XCTFail("this game time creation should fail, both minutes and seconds are invalid")
        case .failure(let error):
            switch error {
            case .invalidSecondProvided, .invalidMinuteProvided:
                XCTFail("this game time creation should fail with error invalidMinutesAndSecondsProvided")
            case .invalidMinutesAndSecondsProvided(let minute, let second):
                XCTAssertEqual(minute, 51)
                XCTAssertEqual(second, 66)
            }
        }
    }
    
    func testGameTimeInit_ValidMinutesAndValidSecondsProvided_SuccessfullyInits() {
        switch GameTime.create(minute: 0, second: 44) {
        case .failure:
            XCTFail("this game time creation should succeed")
        default:
            return
        }
    }
    
    func testGameStrategyCreation_MoreThan7SubstitutionsProvided_ReturnsInvalidNumberOfSubstitutions() {
        let strategyResult = GameStrategy.create(
            startingLineup: .computedTest,
            substitutions: [
                .init(gameTime: .create(minute: 0, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 1, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 2, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 3, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 4, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 5, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 6, second: 22).unwrap(), lineup: .computedTest),
                .init(gameTime: .create(minute: 7, second: 22).unwrap(), lineup: .computedTest)
            ]
        )
        switch strategyResult {
        case .success:
            XCTFail("this game strategy creation should fail, more than 7 substitutions are not allowed")
        case .failure(let error):
            switch error {
            case .invalidNumberOfSubstitutions(let numberOfSubs):
                XCTAssertEqual(numberOfSubs, 8)
            default:
                XCTFail("this game strategy creation should fail with an invalidNumberOfSubstitutions error")
            }
        }
    }
    
    func testGameStrategyCreation_SubstitutionProvidedForBeginningOfGame_ReturnsInvalidSubstitutionProvided() {
        let strategyResult = GameStrategy.create(
            startingLineup: .computedTest,
            substitutions: [
                .init(gameTime: .create(minute: 0, second: 0).unwrap(), lineup: .computedTest),
            ]
        )
        switch strategyResult {
        case .success:
            XCTFail("this game strategy creation should fail, a substitution at the start of the game is not allowed")
        case .failure(let error):
            switch error {
            case .invalidNumberOfSubstitutions, .clashingSubstitutions:
                XCTFail("this game strategy creation should fail with an invalidSubstitutionScheduledForStartOfGame error")
            default:
                return
            }
        }
    }
    
    func testGameStrategyCreation_ClashingSubstitutionsProvided_ReturnsClashingSubstitutions() {
        let sub1 = LineupSubstitution(gameTime: .create(minute: 0, second: 22).unwrap(), lineup: .computedTest)
        let sub2 = LineupSubstitution(gameTime: .create(minute: 0, second: 22).unwrap(), lineup: .computedTest)
        let strategyResult = GameStrategy.create(startingLineup: .computedTest, substitutions: [sub1, sub2])
        switch strategyResult {
        case .success:
            XCTFail("this game strategy creation should fail, clashing substitutions are not allowed")
        case .failure(let error):
            switch error {
            case .invalidNumberOfSubstitutions, .invalidSubstitutionScheduledForStartOfGame:
                XCTFail("this game strategy creation should fail with a clashingSubstitutions error")
            default:
                return
            }
        }
    }
}

extension Player {
    static var computedTest: Player {
        .init(
            firstName: UUID().uuidString,
            lastName: UUID().uuidString,
            height: Int.random(in: 100...200),
            weight: Int.random(in: 150...400),
            leanMusclePercentage: Int.random(in: 50...95),
            endurance: Int.random(in: 0...100),
            straightLineSpeed: Int.random(in: 0...100),
            vertical: Int.random(in: 0...100),
            lateralQuickness: Int.random(in: 0...100),
            strength: Int.random(in: 0...100),
            threePointShooting: Int.random(in: 0...100),
            midRangeShooting: Int.random(in: 0...100),
            finishingAroundTheBasket: Int.random(in: 0...100),
            handle: Int.random(in: 0...100),
            speedOffDribble: Int.random(in: 0...100),
            foulBaiting: Int.random(in: 0...100),
            screen: Int.random(in: 0...100),
            passing: Int.random(in: 0...100),
            steal: Int.random(in: 0...100),
            block: Int.random(in: 0...100),
            awareness: Int.random(in: 0...100)
        )
    }
}

extension Lineup {
    static var computedTest: Lineup {
        .init(
            pointGuard: .computedTest,
            shootingGuard: .computedTest,
            smallForward: .computedTest,
            powerForward: .computedTest,
            center: .computedTest
        )
    }
}
