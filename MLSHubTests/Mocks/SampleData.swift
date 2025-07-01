import Foundation
@testable import MLSHub

struct SampleData {
    static let miami = TeamInfo(
        id: 1,
        name: "Inter Miami",
        conference: "Eastern",
        logo: "InterMiami",
        playerImage: "Messi",
        colors: .init(primary: "#FF97C1", secondary: "#593644"),
        stadium: "Chase Stadium"
    )

    static let atlanta = TeamInfo(
        id: 3,
        name: "Atlanta United",
        conference: "Eastern",
        logo: "AtlantaUnited",
        playerImage: "Almiron",
        colors: .init(primary: "#AA1212", secondary: "#550B0B"),
        stadium: "Mercedes-Benz Stadium"
    )

    static let miamiStats = TeamStats(
        lastMatches: [
            Match(date: Date(), opponent: "Orlando City", result: "W", homeScore: 3, awayScore: 1)
        ],
        nextMatches: [],
        standings: Standings(
            conference: "Eastern",
            rank: 1,
            points: 55,
            gamesPlayed: 28,
            wins: 17,
            losses: 6,
            draws: 5,
            goalsFor: 50,
            goalsAgainst: 25,
            goalDifference: 25
        )
    )
    
    static let networkError = DataError.networkError(NSError(domain: "TestError", code: 404, userInfo: nil))
}
