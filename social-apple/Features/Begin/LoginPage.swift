//
//  LoginPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-04-19.
//

import SwiftUI

struct LoginPage: View {
    @ObservedObject var client: Client
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggingIn: Bool = false
    @State private var loginError: String = ""
    
    private var canSubmit: Bool {
        !isLoggingIn &&
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    private var backButtonPlacement: ToolbarItemPlacement {
#if os(macOS)
        .automatic
#else
        .navigationBarLeading
#endif
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "person.circle")
                        TextField("Username", text: $username)
//                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .interactInputSurface()
                        Spacer()
                    }
                }
                .padding(5)
                
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "lock.circle")
                        
                        SecureField("Password", text: $password)
                            .interactInputSurface()
                        Spacer()
                    }
                }
                .padding(5)
                
                Button(action: {
                    login()
                }) {
                    Text(isLoggingIn ? "Logging in..." : "Login")
                        .padding(15)
                        .interactCardSurface(tone: .selected, cornerRadius: 20, lineWidth: 3, originalBorder: .accentColor)
                }
                .disabled(!canSubmit)
                
                if !loginError.isEmpty {
                    AuthInlineErrorView(message: loginError)
                        .padding(.horizontal, 15)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .interactScreenPadding(maxWidth: 520)
        }
        .interactAppBackground()
        .navigationTitle("Login")
        .toolbar {
            ToolbarItem(placement: backButtonPlacement) {
                Button("Back") {
                    client.hapticPress()
                    client.changeBeginSetting(value: 1)
                }
                .disabled(isLoggingIn)
            }
        }
    }
    
    private func login() {
        guard canSubmit else {
            return
        }
        
        client.hapticPress()
        isLoggingIn = true
        loginError = ""
        
        let userLogin = UserLoginData(
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
        
        client.api.auth.userLoginRequest(userLogin: userLogin) { result in
            DispatchQueue.main.async {
                isLoggingIn = false
                switch result {
                case .success(let userLoginData):
                    client.provideTokens(userLoginResponse: userLoginData)
                    client.changeBeginSetting(value: 0)
                case .failure(let error):
                    loginError = userFacingErrorMessage(
                        error,
                        fallback: "We couldn't sign you in. Check your username and password, then try again."
                    )
                }
            }
        }
    }
}

struct AuthInlineErrorView: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.callout)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(12)
        .background(Color.red.opacity(0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.35), lineWidth: 1)
        )
    }
}
