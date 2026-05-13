//
//  CreateUserPage.swift
//  social-apple
//
//  Created by Daniel Kravec on 2023-12-03.
//

import SwiftUI

struct CreateUserPage: View {
    @ObservedObject var client: Client
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var displayName: String = ""
    @State private var description: String = ""
    @State private var pronouns: String = ""
    @State private var status: String = ""
    @State private var userAge: Date = Date()
    @State private var isCreatingUser: Bool = false
    @State private var createError: String = ""
    
    private var canSubmit: Bool {
        !isCreatingUser &&
        !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Spacer()
                    Image(systemName: "envelope.circle")
                    TextField("Email (optional)", text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "person.circle")
                    TextField("Username (required)", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass.circle")
                    TextField("Display Name (required)", text: $displayName)
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "lock.circle")
                    SecureField("Password (required)", text: $password)
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    TextField("Description (optional)", text: $description)
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "line.3.horizontal.decrease.circle")
#if !os(tvOS)
                    DatePicker(selection: $userAge, in: ...Date.now, displayedComponents: .date) {
                        Text("Select a date (must be older than 13)")
                    }
#endif
                    Spacer()

                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "pencil.tip.crop.circle")
                    TextField("Pronouns (optional)", text: $pronouns)
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                HStack {
                    Spacer()
                    Image(systemName: "info.circle")
                    TextField("Activity Status (optional)", text: $status)
                        .interactInputSurface()
                    Spacer()
                }
                .padding(5)
                
                Button(action: {
                    createUser()
                }) {
                    Text(isCreatingUser ? "Creating..." : "Sign up")
                        .padding(15)
                        .interactCardSurface(tone: .selected, cornerRadius: 20, lineWidth: 3, originalBorder: .accentColor)
                }
                .disabled(!canSubmit)
                
                if !createError.isEmpty {
                    AuthInlineErrorView(message: createError)
                        .padding(.horizontal, 15)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .interactScreenPadding(maxWidth: 520)
        }
        .interactAppBackground()
        .navigationTitle("Sign up")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    client.hapticPress()
                    client.changeBeginSetting(value: 1)
                }
                .disabled(isCreatingUser)
            }
        }
    }
    
    private func createUser() {
        guard canSubmit else {
            return
        }
        
        client.hapticPress()
        isCreatingUser = true
        createError = ""
        
        let userLogin = UserCreateData(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            username: username.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            pronouns: pronouns.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status.trimmingCharacters(in: .whitespacesAndNewlines),
            userAge: dateTimeFormatterInt64(date: userAge)
        )
        
        client.api.auth.userCreateRequest(userCreate: userLogin) { result in
            DispatchQueue.main.async {
                isCreatingUser = false
                switch result {
                case .success(let userLoginData):
                    client.provideTokens(userLoginResponse: userLoginData)
                    client.changeBeginSetting(value: 0)
                case .failure(let error):
                    createError = userFacingErrorMessage(
                        error,
                        fallback: "We couldn't create your account. Check the fields and try again."
                    )
                }
            }
        }
    }
}
