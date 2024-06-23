//
//  Team.swift
//  
//
//  Created by Shyam Kumar on 6/9/24.
//

import Foundation

enum Team: String, CaseIterable, Equatable, Hashable {
    case atl
    case bos
    case brk
    case chi
    case cho
    case cle
    case dal
    case den
    case det
    case gsw
    case hou
    case ind
    case lac
    case lal
    case mem
    case mia
    case mil
    case min
    case nop
    case nyk
    case okc
    case orl
    case phi
    case pho
    case por
    case sac
    case sas
    case tor
    case uta
    case was
    
    init(_ abbreviation: String) {
        self.init(rawValue: abbreviation.lowercased())!
    }
    
    var division: Division {
        switch self {
        case .atl: .southeast
        case .bos: .atlantic
        case .brk: .atlantic
        case .chi: .central
        case .cho: .southeast
        case .cle: .central
        case .dal: .southwest
        case .den: .northwest
        case .det: .central
        case .gsw: .pacific
        case .hou: .southwest
        case .ind: .central
        case .lac: .pacific
        case .lal: .pacific
        case .mem: .southwest
        case .mia: .southeast
        case .mil: .central
        case .min: .northwest
        case .nop: .southwest
        case .nyk: .atlantic
        case .okc: .northwest
        case .orl: .southeast
        case .phi: .atlantic
        case .pho: .pacific
        case .por: .northwest
        case .sac: .pacific
        case .sas: .southwest
        case .tor: .atlantic
        case .uta: .northwest
        case .was: .southeast
        }
    }
    
    var conference: Conference {
        division.conference
    }
    
    func `in`(division: Division) -> Bool {
        self.division == division
    }
    
    func `in`(conference: Conference) -> Bool {
        self.conference == conference
    }
    
    func getAllTeamsFromOppositeConference() -> [Team] {
        Team.allCases.filter({ $0.conference == self.conference.otherConference })
    }
    
    func getAllOtherTeamsInDivision() -> [Team] {
        Team.allCases.filter({ $0.division == self.division && $0 != self })
    }
    
    func getAllTeamsOutOfDivisionButInConference() -> [Team] {
        Team.allCases.filter({ $0.conference == self.conference && $0.division != self.division })
    }
}

enum Division: CaseIterable, Equatable {
    // EASTERN
    case atlantic
    case central
    case southeast
    // WESTERN
    case pacific
    case southwest
    case northwest
    
    var conference: Conference {
        switch self {
        case .atlantic, .central, .southeast:
            return .eastern
        case .pacific, .southwest, .northwest:
            return .western
        }
    }
}

enum Conference: CaseIterable, Equatable {
    case eastern
    case western
    
    var otherConference: Conference {
        switch self {
        case .eastern: return .western
        case .western: return .eastern
        }
    }
}
