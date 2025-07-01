import Foundation

protocol LocalDataServiceProtocol {
    func loadTeams() async throws -> [TeamInfo]
}
