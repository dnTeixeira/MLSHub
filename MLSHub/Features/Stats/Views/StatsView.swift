import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppContainer.self) private var container

    private var userSettings: UserSettingsServiceProtocol { container.userSettingsService }
    private var dataRepository: DataRepositoryProtocol { container.dataRepository }

    var body: some View {
        if let team = userSettings.selectedTeam {
            content(for: team)
                .navigationBarBackButtonHidden(true)
                .background(Color("AppBackgroundColor").ignoresSafeArea())
        } else {
            VStack {
                Text("No Team Selected")
                    .font(.montserratBold(size: 18))
                    .foregroundStyle(.white)
                Button("Go Back") {
                    dismiss()
                }
                .padding(.top)
                .tint(.white)
            }
        }
    }
    
    @ViewBuilder
    private func content(for team: TeamInfo) -> some View {
        let teamStats = dataRepository.stats(for: team)
        
        ScrollView {
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color(hex: team.colors.primary))
                            .font(.title3.weight(.bold))
                    }
                    Spacer()
                }
                
                TeamBadgeView(rank: teamStats?.standings.rank, team: team)
                
                Text(team.name)
                    .font(.custom("Montserrat-Bold", size: 20))
                    .foregroundStyle(Color(hex: team.colors.primary))
                    .multilineTextAlignment(.center).textCase(.uppercase).kerning(10)
                
                HStack {
                    Text("RECENT MATCHES")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundStyle(.white).kerning(5).padding(.top, 24)
                    Spacer()
                }
                
                ForEach(teamStats?.lastMatches ?? []) { match in
                    MatchResultView(match: match, selectedTeam: team, dataRepository: dataRepository)
                }
                
                HStack {
                    Text("STATISTICS")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundStyle(.white).kerning(5).padding(.top, 24)
                    Spacer()
                }
                
                if let standings = teamStats?.standings {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            StatCardView(title: "GAMES PLAYED", value: "\(standings.gamesPlayed)", team: team)
                            StatCardView(title: "TOTAL WINS", value: "\(standings.wins)", team: team)
                            StatCardView(title: "TOTAL GOALS", value: "\(standings.goalsFor)", team: team)
                        }
                    }
                    .frame(height: 150)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
        }
    }
}

struct MatchResultView: View {
    let match: Match
    let selectedTeam: TeamInfo
    let dataRepository: DataRepositoryProtocol

    var body: some View {
        HStack {
            VStack {
                Image(selectedTeam.logo)
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 55, height: 55)
                Text(selectedTeam.name)
                    .font(.custom("Montserrat-Medium", size: 12))
                    .foregroundStyle(.white).padding(.top, 4).multilineTextAlignment(.center).minimumScaleFactor(0.7).lineLimit(2)
            }
            .frame(width: 80)
            
            Spacer()
            
            Text("\(match.homeScore ?? 0) - \(match.awayScore ?? 0)")
                .font(.custom("Montserrat-Bold", size: 24))
                .foregroundStyle(.white)
            
            Spacer()
            
            VStack {
                if let awayLogo = dataRepository.logo(forTeamName: match.opponent) {
                     Image(awayLogo)
                        .resizable().aspectRatio(contentMode: .fit).frame(width: 55, height: 55)
                } else {
                    Image(systemName: "shield.fill").resizable().aspectRatio(contentMode: .fit).frame(width: 45, height: 45).foregroundStyle(.gray)
                }
                Text(match.opponent)
                    .font(.custom("Montserrat-Medium", size: 12))
                    .foregroundStyle(.white).padding(.top, 4).multilineTextAlignment(.center).minimumScaleFactor(0.7).lineLimit(2)
            }
            .frame(width: 80)
        }
        .padding(.top)
    }
}

struct TeamBadgeView: View {
    let rank: Int?
    let team: TeamInfo
    
    private func formatRank(_ rank: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: rank)) ?? "\(rank)"
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Text(rank != nil ? formatRank(rank!) : "N/A")
                    .font(.custom("Montserrat-Bold", size: 20))
                    .foregroundStyle(.white)
                Text("Current place")
                    .font(.custom("Montserrat-Bold", size: 10))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            Spacer().frame(width: 16)
            Rectangle().fill(Color(hex: team.colors.primary)).frame(width: 50, height: 2)
            ZStack {
                Circle().strokeBorder(LinearGradient(colors: [Color(hex: team.colors.primary), Color(hex: team.colors.secondary)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                Image(team.logo)
                    .resizable()
                    .scaledToFit()
                    .padding(12)
            }.frame(width: 100, height: 100)
            Rectangle().fill(Color(hex: team.colors.primary)).frame(width: 50, height: 2)
            Spacer().frame(width: 16)
            VStack {
                Image(.stadiumIcon)
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 32, height: 32)
                    .foregroundColor(Color(hex: team.colors.primary))
                Text(team.stadium)
                    .font(.custom("Montserrat-Bold", size: 10))
                    .foregroundStyle(.white).multilineTextAlignment(.center)
                    .minimumScaleFactor(0.9)
                    .lineLimit(3)
            }
            .frame(width: 45)
        }
        .frame(height: 120)
        .padding(.horizontal, 16)
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let team: TeamInfo
    @State private var animateShine = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(colors: [Color(hex: team.colors.secondary), Color("AppBackgroundColor")], startPoint: .trailing, endPoint: .leading))
            
            VStack(alignment: .leading) {
                ZStack {
                    Text(title)
                         .font(.custom("Montserrat-Bold", size: 20))
                         .foregroundStyle(Color(hex: team.colors.primary))
                         .overlay(
                            LinearGradient(
                                colors: [Color.white.opacity(0),
                                         Color.white.opacity(0.8), Color.white.opacity(0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: animateShine ? 200 : -200)
                         )
                         .mask(
                            Text(title)
                                .font(.custom("Montserrat-Bold", size: 20))
                         )
                         .onAppear {
                             withAnimation(
                                Animation.linear(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                             ) {
                                 animateShine = true
                             }
                         }
                }
                
                Text(value)
                    .font(.custom("Montserrat-Bold", size: 64))
                    .foregroundStyle(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 200, height: 150)
        .padding(.horizontal)
    }
}

#Preview {
    let previewContainer = AppContainer()
    
    let sampleTeam = TeamInfo(id: 1, name: "Atlanta United FC", conference: "Eastern", logo: "atlanta_united", playerImage: "atlanta_player", colors: .init(primary: "#800000", secondary: "#000000"), stadium: "Mercedes-Benz Stadium")
    previewContainer.userSettingsService.selectTeam(sampleTeam)
    
    return NavigationStack {
        StatsView()
            .environment(previewContainer)
    }
}
