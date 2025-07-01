import Foundation

enum DataError: Error, LocalizedError {
    case localDataLoadingError(Error)
    case networkError(Error)
    case noDataAvailable
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .localDataLoadingError(let error):
            return "Failed to load local data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .noDataAvailable:
            return "No data available for this team"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
    
    static func from(_ error: Error) -> DataError {
        if let dataError = error as? DataError {
            return dataError
        } else if error is NetworkError {
            return .networkError(error)
        } else {
            return .unknown(error)
        }
    }
}
