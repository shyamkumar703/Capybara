import Foundation

enum Position: String, Identifiable, CaseIterable {
    case pointGuard
    case shootingGuard
    case smallForward
    case powerForward
    case center
    
    var id: String { rawValue }
}
