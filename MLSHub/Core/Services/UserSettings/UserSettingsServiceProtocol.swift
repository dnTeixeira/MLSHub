import Foundation

protocol UserSettingsServiceProtocol: Observable {
    var selectedTeam: TeamInfo? { get }
    
    func selectTeam(_ team: TeamInfo)
    func clearSelectedTeam()
}
