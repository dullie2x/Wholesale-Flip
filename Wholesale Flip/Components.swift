import SwiftUI
import Combine


struct ModernTextField: View {
    var icon: String
    var title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isFocused: Bool
    var onTap: () -> Void
    
    @State private var isEditing = false
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var fieldIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isFocused || fieldIsFocused ? Color("AppTeal") : .gray)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isFocused || fieldIsFocused ? Color("AppTeal") : .gray)
                
                Spacer()
            }
            
            HStack {
                TextField("", text: $text)
                    .focused($fieldIsFocused)
                    .keyboardType(keyboardType)
                    .onChange(of: fieldIsFocused) { newValue in
                        if newValue {
                            onTap()
                        }
                    }
                    .onReceive(Just(text)) { newValue in
                        // Filter out invalid characters for decimal inputs
                        if keyboardType == .decimalPad {
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                self.text = filtered
                            }
                        }
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        self.text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .transition(.scale)
                    .animation(.easeInOut, value: text.isEmpty)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color("CardBackground"))
                .shadow(color: (isFocused || fieldIsFocused) ? Color("AppTeal").opacity(0.3) : Color("NavyBlue").opacity(0.1),
                        radius: (isFocused || fieldIsFocused) ? 4 : 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke((isFocused || fieldIsFocused) ? Color("AppTeal") : Color.gray.opacity(0.3),
                        lineWidth: (isFocused || fieldIsFocused) ? 1.5 : 0.5)
        )
        .contentShape(Rectangle()) // This makes the entire area tappable
        .onTapGesture {
            fieldIsFocused = true
            onTap()
        }
    }
}

// A card-style display for expense results
struct ExpenseCard: View {
    let title: String
    let value: String
    let percentage: String
    let icon: String
    let iconColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [iconColor, iconColor.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .font(.system(size: 14))
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(Color("NavyBlue"))
                
                if !percentage.isEmpty {
                    Text(percentage)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(Color("NavyBlue").opacity(0.6))
                }
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(Color("NavyBlue"))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 6)
    }
}

// MARK: - Extensions

extension Double {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter.string(for: self) ?? "0"
    }
    
    var currencyFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(for: self) ?? "$0"
    }
}

extension View {
    func hideKeyboardWhenTappedAround() -> some View {
        return onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
