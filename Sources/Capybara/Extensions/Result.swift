import Foundation

extension Result {
    func unwrap() -> Success {
        switch self {
        case .success(let successValue):
            return successValue
        case .failure(let error):
            fatalError("attempted to unwrap Result with failure value \(error)")
        }
    }
}
