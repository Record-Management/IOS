import SwiftUI
import Combine

extension SettingView {
    @MainActor
    class ViewModel: ObservableObject {
        @ObservedObject var resVM: RecordSelectionView.ViewModel
        @Published var name: String
        @Published var isValidName: Bool = false
        @Published var birth: Date
        @Published var isShow: Bool = false
        
        private var cancellables = Set<AnyCancellable>()
        var originalName: String = ""
        let useCase: SettingUseCase
        
        init(useCase: SettingUseCase,resVM: RecordSelectionView.ViewModel) {
            self.useCase = useCase
            self.resVM = resVM
            // Name
            name = resVM.user.data?.nickname ?? ""
            originalName = resVM.user.data?.nickname ?? "" // 임시 저장
            birth = Date.convertDateForIntArray(resVM.user.data?.birthDate ?? []) ?? .now
            getNameSubscriber()
        }
    }
}


// MARK: Combine name, isValidName
extension SettingView.ViewModel {
    // TODO: 설정 Name 부분 구독 함수
    private func getNameSubscriber() {
        getNamePublisher()
            .sink { [weak self] val in
                withAnimation(.smooth) {
                    self?.isValidName = val
                }
            }
            .store(in: &cancellables)
    }
    
    // TODO: 설정 Name 부분 Publisher 함수
    private func getNamePublisher() -> AnyPublisher<Bool,Never> {
        $name
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { name -> Bool in
                guard !self.originalName.isEmpty else { return false }
                guard name != self.originalName else { return false }
                if name.isEmpty { return false }
                guard name.count <= 6 else { return false }
                
                return name.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}


// MARK: Profile Update
extension SettingView.ViewModel {
    func updateNickName() async -> Bool {
        do {
            let parameter: [String : Any] = [
                "nickname" : name
            ]
            let currentUser = try await useCase.update(with: parameter)
            resVM.user = currentUser
            originalName = self.name
            return true
        } catch {
            debugPrint("닉네임 업데이트 error : \(error)")
        }
        return false
    }
    
    func updateBirth() async -> Bool {
        do {
            let parameter: [String : Any] = [
                "birthDate" : Date.onBoardingFormet(birth)
            ]
            
            let currentUser = try await useCase.update(with: parameter)
            resVM.user = currentUser
            
            return true
        } catch {
            debugPrint("생일 업데이트 error: \(error)")
        }
        return false
    }
}
