import SwiftUI

struct AchivementGoalFullScreen: View {
    @EnvironmentObject var coordinator: Coordinator
    let goal: GoalAchieve
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "F2FCF3")
                
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#C6F8B5"), Color(hex: "#A7EA88")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 255,height: 140)
                    .offset(y: 26)
                
                if let data = goal.data {
                    ZStack {
                        Image(Stage.matchingStage(str: data.treeStage).imageName)
                            .resizable()
                            .scaledToFit()
                            
                    }
                    .offset(y: -140)
                }
                
                bottomSheet
            }
            .ignoresSafeArea(edges: [.top])
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .background(Color.Primary.goalLighter())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationTitle("목표 달성 리포트")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image("xmark")
                        .frame(maxWidth: 24, maxHeight: 24)
                        .higFullScreenBackSize()
                        .onTapGesture {
                            coordinator.dismissScreen()
                        }
                }
            }
            .overlay(alignment: .top) {
                VStack {
                    if let data = goal.data {
                        Text(Stage.matchingStage(str: data.treeStage).title)
                            .typography(.p22Bold)
                    }
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
    }
    
    var bottomSheet: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(stops: [
                            .init(color: .white, location: 0.6),
                            .init(color: Color.Primary.goalLighter(), location: 1.0)
                        ], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(height: geo.size.height / 2)
                    .clipShape(
                        RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                    )
                    .overlay {
                        VStack(spacing: 34) {
                            header
                            middle
                            bottom
                        }
                        .padding([.top, .leading, .trailing], 26)
                    }
            }
        }
    }
}


// MARK: View Structure
extension AchivementGoalFullScreen {
    // Header View - Bottom Sheet
    var header: some View {
        let startDate = goal.data?.startDate.replacingOccurrences(of: "-", with: ".") ?? ""
        let endDate = goal.data?.endDate.replacingOccurrences(of: "-", with: ".") ?? ""
        
        return HStack(spacing: 16) {
            VStack(spacing: 2) {
                Text("나의 목표")
                    .typography(.p12Medium)
                    .foregroundStyle(Color.Gray._600())
                Text("하루 기록")
                    .typography(.p16SemiBold)
            }
            
            Divider().background(Color.Gray._300())
            
            VStack(spacing: 2) {
                Text("목표 기간")
                    .typography(.p12Medium)
                    .foregroundStyle(Color.Gray._600())
                Text("\(startDate) ~ \(endDate)")
                    .typography(.p16SemiBold)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity ,maxHeight: 73)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.Gray._100())
        .clipShape(.rect(cornerRadius: 12))
    }
    // Middle View - Bottom Sheet
    var middle: some View {
        HStack {
            ForEach(Card.allCases, id: \.self) { card in
                let value = data[card.rawValue]
                
                VStack(spacing: 8) {
                    Image(card.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    VStack(spacing: 4) {
                        Text("\(value)\(card.unit)")
                            .typography(.p22Bold)
                            .foregroundStyle(Color.Primary.main())
                        Text(card.subTitle)
                            .typography(.p12Medium)
                            .foregroundStyle(Color.Gray._500())
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxHeight: .infinity)
                
                if card != Card.allCases.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 24)
    }
    // Bottom View - Bottom Sheet
    var bottom: some View {
        SeeDayBottomCard(title: "새로운 목표를 세우고\n다른 하루를 시작해보세요", cardTitle: "새 목표 설정하기") {
            coordinator.dismissScreen()
            coordinator.push(.goalSelection)
        }
    }
}

// MARK: Data Structure
extension AchivementGoalFullScreen {
    var data: [Int] {
        guard let data = goal.data else { return [] }
        return [
            data.achievementRate,
            data.completedDays,
            goal.achieveCount ?? 0
        ]
    }
    
    enum Card: Int,CaseIterable , Hashable{
        case achievementRate
        case completedDays
        case achiveCount
        
        var imageName: String {
            switch self {
                case .achievementRate:
                    "AchievementRate"
                case .completedDays:
                    "Success"
                case .achiveCount:
                    "Total"
            }
        }
        
        var unit: String {
            switch self {
                case .achievementRate:
                    "%"
                case .completedDays:
                    "일"
                case .achiveCount:
                    "회"
            }
        }
        
        var subTitle: String {
            switch self {
                case .achievementRate:
                    "목표\n달성률"
                case .completedDays:
                    "기록 완료\n일 수"
                case .achiveCount:
                    "누적 달성\n횟수"
            }
        }
    }
    
    enum Stage {
        case stage1
        case stage2
        case stage3
        case stage4
        
        var imageName: String {
            switch self {
                case .stage1:
                    "Step01"
                case .stage2:
                    "Step02"
                case .stage3:
                    "Step03"
                case .stage4:
                    "Step04"
            }
        }
        
        var title: String {
            switch self {
            case .stage1:
                "성장 1단계 성공!"
            case .stage2:
                "성장 2단계 성공!"
            case .stage3:
                "성장 3단계 성공!"
            case .stage4:
                "하루 나무 설장 완료"
            }
        }
        
        static func matchingStage(str: String) -> Stage {
            switch str {
                case "STAGE_1":
                        .stage1
                case "STAGE_2":
                        .stage2
                case "STAGE_3":
                        .stage3
                case "STAGE_4":
                        .stage4
                default:
                        .stage1
            }
        }
    }
}

#Preview {
    AchivementGoalFullScreen(
        goal: GoalAchieve(
            data: GoalData(
                goalId: "550e8400-e29b-41d4-a716-446655440000",
                recordType: "HABIT",
                goalDays: 20,
                startDate: "2025-11-01",
                endDate: "2025-11-20",
                completedDays: 7,
                achievementRate: 35,
                treeStage: "STAGE_4",
                isInProgress: true
            ),
            achieveCount: 3
        )
    )
    .environmentObject(Coordinator())
}
