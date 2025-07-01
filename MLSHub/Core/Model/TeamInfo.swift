import Foundation

struct TeamInfo: Codable, Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let conference: String
    let logo: String
    let playerImage: String
    let colors: TeamColors
    let stadium: String
    
    struct TeamColors: Codable, Equatable, Hashable {
        let primary: String
        let secondary: String
    }
}

struct TeamStats: Codable {
    let lastMatches: [Match]
    let nextMatches: [Match]
    let standings: Standings
}

struct Match: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let opponent: String
    let result: String?
    let homeScore: Int?
    let awayScore: Int?
    
    private enum CodingKeys: String, CodingKey {
        case date, opponent, result, homeScore, awayScore
    }
}

struct Standings: Codable {
    let conference: String
    let rank: Int
    let points: Int
    let gamesPlayed: Int
    let wins: Int
    let losses: Int
    let draws: Int
    let goalsFor: Int
    let goalsAgainst: Int
    let goalDifference: Int
}
