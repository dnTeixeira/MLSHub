import Foundation

final class LocalDataService: LocalDataServiceProtocol {
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func loadTeams() async throws -> [TeamInfo] {
        guard let url = Bundle.main.url(forResource: "teams", withExtension: "json") else {
            throw LocalDataError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([TeamInfo].self, from: data)
        } catch {
            throw LocalDataError.decodingError(error)
        }
    }
}

enum LocalDataError: Error {
    case fileNotFound
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .fileNotFound:
            return "Teams data file not found in bundle"
        case .decodingError(let error):
            return "Failed to decode teams data: \(error.localizedDescription)"
        }
    }
}
