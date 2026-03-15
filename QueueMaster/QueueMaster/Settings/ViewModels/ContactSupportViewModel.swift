import Foundation
import SwiftUI

@MainActor
class ContactSupportViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var subject: String = "General Feedback"
    @Published var message: String = ""
    
    @Published var isLoading: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let feedbackAPIURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    private let appName = "QueueMaster"
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isValidEmail(email) &&
        !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func submitFeedback() async {
        guard isValid else {
            errorMessage = "Please fill in all fields with valid information."
            showErrorAlert = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let feedbackData: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            "subject": subject,
            "message": message.trimmingCharacters(in: .whitespacesAndNewlines),
            "app_name": appName
        ]
        
        guard let url = URL(string: feedbackAPIURL) else {
            errorMessage = "Invalid API URL. Please try again later."
            showErrorAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: feedbackData)
        } catch {
            errorMessage = "Failed to prepare request data."
            showErrorAlert = true
            return
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid server response."
                showErrorAlert = true
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                showSuccessAlert = true
                // Reset form after successful submission
                name = ""
                email = ""
                subject = "General Feedback"
                message = ""
            case 400:
                errorMessage = "Invalid request. Please check your input and try again."
                showErrorAlert = true
            case 429:
                errorMessage = "Too many requests. Please wait a moment and try again."
                showErrorAlert = true
            case 500...599:
                errorMessage = "Server error. Please try again later."
                showErrorAlert = true
            default:
                errorMessage = "An unexpected error occurred. Please try again."
                showErrorAlert = true
            }
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                errorMessage = "No internet connection. Please check your network and try again."
            case .timedOut:
                errorMessage = "Request timed out. Please try again."
            default:
                errorMessage = "Network error: \(urlError.localizedDescription)"
            }
            showErrorAlert = true
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
