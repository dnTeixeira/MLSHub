import Foundation
import SwiftUI

struct HomeView: View {
    @Environment(AppContainer.self) private var container
    @State private var viewModel: HomeViewModel?
    @State private var isTransitioningTeam = false
    
    private var userSettingsService: UserSettingsServiceProtocol {
        container.userSettingsService
    }
    
    private var dataRepository: DataRepositoryProtocol {
        container.dataRepository
    }
    
    var body: some View {
        ZStack {
            AppBackground(team: userSettingsService.selectedTeam)
            
            if isTransitioningTeam {
                TeamTransitionLoadingView(team: userSettingsService.selectedTeam)
            } else {
                contentView
            }
        }
        .task {
            await initializeViewModel()
        }
        .onChange(of: userSettingsService.selectedTeam) { oldTeam, newTeam in
            if let newTeam = newTeam, oldTeam?.id != newTeam.id {
                Task { await handleTeamChange(to: newTeam) }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if let viewModel = viewModel {
            if viewModel.isLoading {
                LoadingView()
            } else {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        HeaderView()
                        BadgeView()
                        TeamNameView(team: userSettingsService.selectedTeam)
                        
                        VStack(spacing: 16) {
                            LastMatchView(viewModel: viewModel, dataRepository: dataRepository)
                            StatsNavigationView(team: userSettingsService.selectedTeam)
                            UpcomingMatchesView(
                                matches: viewModel.upcomingMatches,
                                team: userSettingsService.selectedTeam,
                                dataRepository: dataRepository
                            )
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                }
                .refreshable {
                    await viewModel.loadTeamStats()
                }
            }
        } else {
            LoadingView()
        }
    }
    
    private func initializeViewModel() async {
        guard let selectedTeam = userSettingsService.selectedTeam else { return }
        
        let newViewModel = HomeViewModel(
            team: selectedTeam,
            dataRepository: dataRepository
        )
        viewModel = newViewModel
        await newViewModel.loadTeamStats()
    }
    
    private func handleTeamChange(to newTeam: TeamInfo) async {
        isTransitioningTeam = true
        
        let newViewModel = HomeViewModel(
            team: newTeam,
            dataRepository: dataRepository
        )
        await newViewModel.loadTeamStats()
        
        await MainActor.run {
            viewModel = newViewModel
            
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isTransitioningTeam = false
                    }
                }
            }
        }
    }
}

private struct TeamTransitionLoadingView: View {
    let team: TeamInfo?
    
    var body: some View {
        VStack(spacing: 24) {
            if let team = team {
                Image(team.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .opacity(0.8)
                    .scaleEffect(1.0)
                    .animation(
                        .easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true),
                        value: UUID()
                    )
                
                VStack(spacing: 8) {
                    Text("Switching to \(team.name)")
                        .font(.montserratBold(size: 18))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Loading team data...")
                        .font(.montserratMedium(size: 14))
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color(hex: team.colors.primary))
                            .frame(width: 10, height: 10)
                            .scaleEffect(1.0)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever()
                                .delay(Double(index) * 0.3),
                                value: UUID()
                            )
                    }
                }
                .padding(.top, 8)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.montserratMedium(size: 14))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 16)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

private struct BadgeView: View {
    @Environment(AppContainer.self) private var container
    @State private var isPressed = false
    
    var body: some View {
        if let team = container.userSettingsService.selectedTeam {
            Button {
                container.navigationCoordinator.navigateToTeamSelection()
            } label: {
                Image(team.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .opacity(isPressed ? 0.3 : 0.5)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .shadow(radius: 4)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
            }
            .buttonStyle(PlainButtonStyle())
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in isPressed = pressing },
                perform: {}
            )
        }
    }
}

private struct AppBackground: View {
    let team: TeamInfo?
    
    var body: some View {
        Color("AppBackgroundColor")
            .ignoresSafeArea()
        
        if let team = team {
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: team.colors.primary).opacity(0.4),
                        Color("AppBackgroundColor").opacity(0.9),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 500)
                .blur(radius: 20)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        HStack {
            Image(.outlinedWhiteMLSLogo)
                .resizable()
                .frame(width: 32, height: 34)
            
            Text("Hub.")
                .font(.montserratBold(size: 15))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

private struct TeamNameView: View {
    let team: TeamInfo?
    
    var body: some View {
        if let team = team {
            Text(team.name.uppercased())
                .font(.montserratBold(size: 20))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .kerning(10)
                .offset(y: -40)
        }
    }
}

private struct LastMatchView: View {
    let viewModel: HomeViewModel
    let dataRepository: DataRepositoryProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LAST MATCH")
                .font(.montserratBold(size: 12))
                .foregroundStyle(.white)
                .kerning(5)
            
            if let lastMatch = viewModel.lastMatch {
                MatchResultRow(match: lastMatch,
                               homeTeam: viewModel.team,
                               dataRepository: dataRepository) // Pass it down
            } else if viewModel.isLoading {
                LastMatchLoadingView()
            } else {
                LastMatchEmptyView()
            }
        }
    }
}

private struct MatchResultRow: View {
    let match: Match
    let homeTeam: TeamInfo
    let dataRepository: DataRepositoryProtocol
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            TeamInfoView(team: homeTeam, dataRepository: dataRepository)
            
            Spacer()
            
            Text("\(match.homeScore ?? 0) - \(match.awayScore ?? 0)")
                .font(.montserratBold(size: 24))
                .foregroundStyle(.white)
            
            Spacer()
            
            TeamInfoView(teamName: match.opponent, dataRepository: dataRepository)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

private struct TeamInfoView: View {
    let team: TeamInfo?
    let teamName: String?
    let dataRepository: DataRepositoryProtocol
    
    init(team: TeamInfo, dataRepository: DataRepositoryProtocol) {
        self.team = team
        self.teamName = nil
        self.dataRepository = dataRepository
    }
    
    init(teamName: String, dataRepository: DataRepositoryProtocol) {
        self.team = nil
        self.teamName = teamName
        self.dataRepository = dataRepository
    }
    
    var body: some View {
        VStack(spacing: 4) {
            if let team = team {
                Image(team.logo)
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40)
                Text(team.name)
                    .font(.montserratMedium(size: 10)).foregroundStyle(.white).lineLimit(2).multilineTextAlignment(.center)
            } else if let teamName = teamName {
                if let awayLogo = dataRepository.logo(forTeamName: teamName) {
                    Image(awayLogo)
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40)
                } else {
                    Image(systemName: "shield.fill")
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 35, height: 35).foregroundStyle(.gray.opacity(0.5))
                }
                
                Text(teamName)
                    .font(.montserratMedium(size: 10)).foregroundStyle(.white).lineLimit(2).multilineTextAlignment(.center)
            }
        }
        .frame(width: 75)
    }
}

private struct StatsNavigationView: View {
    let team: TeamInfo?
    
    var body: some View {
        if let team = team {
            NavigationLink {
                StatsView()
            } label: {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: team.colors.secondary),
                                    Color("AppBackgroundColor")
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 135)
                    
                    HStack {
                        Image(team.playerImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 125, height: 220)
                            .mask(
                                PlayerMask(cornerRadius: 20, height: 180)
                            )
                            .offset(x: -10, y: -5)
                        
                        VStack(alignment: .leading) {
                            Text("TEAM")
                                .font(.montserratBold(size: 24))
                                .foregroundStyle(Color(hex: team.colors.primary))
                            Text("STATS")
                                .font(.montserratBold(size: 24))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
    }
}

private struct PlayerMask: Shape {
    let cornerRadius: CGFloat
    let height: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        let clipShape = RoundedRectangle(cornerRadius: cornerRadius)
            .path(in: CGRect(x: 0, y: 0, width: rect.width, height: height))
        return path.intersection(clipShape)
    }
}

private struct UpcomingMatchesView: View {
    let matches: [Match]
    let team: TeamInfo?
    let dataRepository: DataRepositoryProtocol
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("UPCOMING")
                .font(.montserratBold(size: 12))
                .foregroundStyle(.white)
                .kerning(5)
            
            if matches.isEmpty {
                UpcomingMatchesEmptyView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 20) {
                        ForEach(matches) { match in
                            UpcomingMatchCard(match: match,
                                              team: team,
                                              dataRepository: dataRepository)
                        }
                    }
                    .frame(height: 210)
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

private struct UpcomingMatchCard: View {
    let match: Match
    let team: TeamInfo?
    let dataRepository: DataRepositoryProtocol
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: match.date)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: match.date)
    }
    
    var body: some View {
        if let team = team {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: team.colors.secondary),
                                Color("AppBackgroundColor")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(formattedDate)
                        .font(.montserratLight(size: 10))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.white)
                        )
                        .padding([.top, .leading], 16)
                    
                    HStack {
                        Image(team.logo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        
                        Spacer()
                        
                        Text("vs")
                            .font(.montserratMedium(size: 10))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        if let awayLogo = dataRepository.logo(forTeamName: match.opponent) {
                            Image(awayLogo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                        } else {
                            Image(systemName: "shield.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 35, height: 35)
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(team.name)
                            .font(.montserratMedium(size: 10))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text("vs")
                            .font(.montserratLight(size: 8))
                            .foregroundStyle(.white.opacity(0.7))
                        
                        Text(match.opponent)
                            .font(.montserratMedium(size: 10))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(formattedTime)
                            .font(.montserratLight(size: 9))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(width: 160, height: 200)
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("Loading team data...")
                .font(.montserratMedium(size: 14))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 16)
        }
    }
}

private struct LastMatchLoadingView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.3))
            .frame(height: 120)
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            )
    }
}

private struct LastMatchEmptyView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.3))
            .frame(height: 120)
            .overlay(
                Text("No recent matches found")
                    .font(.montserratMedium(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            )
    }
}

private struct UpcomingMatchesEmptyView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.black.opacity(0.3))
            .frame(height: 100)
            .overlay(
                Text("No upcoming matches found")
                    .font(.montserratMedium(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            )
    }
}
