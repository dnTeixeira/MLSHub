import Foundation

@Observable
final class UserSettingsService: UserSettingsServiceProtocol {
    private(set) var selectedTeam: TeamInfo? {
        didSet { saveTeamToStorage() }
    }
    
    private let userDefaults: UserDefaults
    private let storageKey = "selectedTeam"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadTeamFromStorage()
    }
    
    func selectTeam(_ team: TeamInfo) {
        selectedTeam = team
    }
    
    func clearSelectedTeam() {
        selectedTeam = nil
    }
    
    private func saveTeamToStorage() {
        if let team = selectedTeam,
           let encoded = try? JSONEncoder().encode(team) {
            userDefaults.set(encoded, forKey: storageKey)
        } else {
            userDefaults.removeObject(forKey: storageKey)
        }
    }
    
    private func loadTeamFromStorage() {
        guard let data = userDefaults.data(forKey: storageKey),
              let team = try? JSONDecoder().decode(TeamInfo.self, from: data) else {
            return
        }
        selectedTeam = team
    }
}
