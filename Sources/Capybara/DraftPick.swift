//
//  DraftPick.swift
//
//
//  Created by Shyam Kumar on 5/30/24.
//

import Foundation

struct DraftPick {
    let round: Round
    let year: Year
}


extension DraftPick {
    enum Round {
        case one
        case two
    }
    
    enum Year {
        case dy2025
        case dy2026
        case dy2027
        case dy2028
        case dy2029
        case dy2030
    }
}
