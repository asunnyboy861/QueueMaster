import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            backgroundColor
            
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $viewModel.currentPage) {
                    ForEach(viewModel.pages) { page in
                        OnboardingPage(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                // Bottom buttons
                VStack(spacing: AppSpacing.md) {
                    Button(action: handleNextButton) {
                        Text(viewModel.isLastPage ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(AppCornerRadius.large)
                    }
                    
                    if !viewModel.isLastPage {
                        Button("Skip") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xxl)
            }
        }
        .onAppear {
            viewModel.checkIfOnboardingNeeded()
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.background : AppColors.Light.background
    }
    
    private func handleNextButton() {
        if viewModel.isLastPage {
            viewModel.completeOnboarding()
            dismiss()
        } else {
            viewModel.nextPage()
        }
    }
}

// MARK: - OnboardingPage

struct OnboardingPage: View {
    let page: OnboardingPageModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            // Icon
            Image(systemName: page.iconName)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            // Title
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            
            Spacer()
        }
        .padding()
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? AppColors.Dark.textSecondary : AppColors.Light.textSecondary
    }
}

// MARK: - OnboardingViewModel

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @Published var pages: [OnboardingPageModel] = []
    
    private let hasShownOnboardingKey = "hasShownOnboarding"
    
    init() {
        setupPages()
    }
    
    private func setupPages() {
        pages = [
            OnboardingPageModel(
                id: 0,
                iconName: "music.note.list",
                title: "Manage Your Queue",
                description: "Easily organize and rearrange your Apple Music queue with intuitive drag and drop."
            ),
            OnboardingPageModel(
                id: 1,
                iconName: "shield",
                title: "Protect Your Queue",
                description: "Automatic snapshots save your queue. Never lose your carefully curated playlist again."
            ),
            OnboardingPageModel(
                id: 2,
                iconName: "arrow.counterclockwise",
                title: "Restore Anytime",
                description: "Accidentally cleared your queue? One tap restores it from history."
            )
        ]
    }
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        withAnimation {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
    
    func checkIfOnboardingNeeded() {
        let hasShown = UserDefaults.standard.bool(forKey: hasShownOnboardingKey)
        if !hasShown {
            currentPage = 0
        }
    }
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasShownOnboardingKey)
    }
}

// MARK: - Models

struct OnboardingPageModel: Identifiable {
    let id: Int
    let iconName: String
    let title: String
    let description: String
}

#Preview {
    OnboardingView()
}
