import Foundation

extension Collection where Element == MatchupScheduleOption {
    func count(_ companion: MatchupScheduleOption.Companion) -> Int {
        filter({ $0.companion == companion }).count
    }
}
