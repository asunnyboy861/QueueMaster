import SwiftUI

struct ContactSupportView: View {
    @StateObject private var viewModel = ContactSupportViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    private let feedbackSubjects = [
        "Bug Report",
        "Feature Request",
        "General Feedback",
        "Account Issue",
        "Other"
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        // Subject Selection
                        subjectSection
                        
                        // Contact Info
                        contactInfoSection
                        
                        // Message
                        messageSection
                        
                        // Submit Button
                        submitButton
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.lg)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We'll get back to you soon.")
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay(message: "Sending...")
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? AppColors.Dark.background : AppColors.Light.background
    }
    
    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("What can we help you with?")
                .font(.headline)
                .foregroundColor(primaryTextColor)
            
            VStack(spacing: AppSpacing.sm) {
                ForEach(0..<feedbackSubjects.count / 2 + feedbackSubjects.count % 2, id: \.self) { row in
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(0..<2) { col in
                            let index = row * 2 + col
                            if index < feedbackSubjects.count {
                                SubjectChip(
                                    title: feedbackSubjects[index],
                                    isSelected: viewModel.subject == feedbackSubjects[index],
                                    action: {
                                        withAnimation(.spring(duration: 0.3)) {
                                            viewModel.subject = feedbackSubjects[index]
                                        }
                                    }
                                )
                            } else {
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var contactInfoSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Name Field
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Name")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(secondaryTextColor)
                
                TextField("Your name", text: $viewModel.name)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .textContentType(.name)
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Email")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(secondaryTextColor)
                
                TextField("your@email.com", text: $viewModel.email)
                    .textFieldStyle(RoundedTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
    }
    
    private var messageSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Message")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(secondaryTextColor)
            
            TextEditor(text: $viewModel.message)
                .frame(minHeight: 120)
                .padding(AppSpacing.sm)
                .background(surfaceColor)
                .cornerRadius(AppCornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
    }
    
    private var submitButton: some View {
        Button(action: {
            Task {
                await viewModel.submitFeedback()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Submit Feedback")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.isLoading || !viewModel.isValid)
        .padding(.top, AppSpacing.md)
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? AppColors.Dark.textPrimary : AppColors.Light.textPrimary
    }
    
    private var secondaryTextColor: Color {
        colorScheme == .dark ? AppColors.Dark.textSecondary : AppColors.Light.textSecondary
    }
    
    private var surfaceColor: Color {
        colorScheme == .dark ? AppColors.Dark.surface : AppColors.Light.surface
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
}

// MARK: - Subject Chip
struct SubjectChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : primaryTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .padding(.horizontal, AppSpacing.md)
                .background(isSelected ? Color.accentColor : chipBackground)
                .cornerRadius(AppCornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .stroke(isSelected ? Color.accentColor : borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? AppColors.Dark.textPrimary : AppColors.Light.textPrimary
    }
    
    private var chipBackground: Color {
        colorScheme == .dark ? AppColors.Dark.surface : AppColors.Light.surface
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1)
    }
}

// MARK: - Rounded Text Field Style
struct RoundedTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.md)
            .background(surfaceColor)
            .cornerRadius(AppCornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
    
    private var surfaceColor: Color {
        colorScheme == .dark ? AppColors.Dark.surface : AppColors.Light.surface
    }
    
    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.md) {
                ProgressView()
                    .scaleEffect(1.2)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, AppSpacing.lg)
            .padding(.horizontal, AppSpacing.xl)
            .background(.ultraThinMaterial)
            .cornerRadius(AppCornerRadius.large)
        }
    }
}

#Preview {
    ContactSupportView()
}
