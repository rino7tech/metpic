//
//  SignUpEmailView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/16.
//

import SwiftUI
import Colorful

struct SignUpEmailView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isEmailFocused: Bool = false
    @State private var isPasswordFocused: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                ColorfulView(animation: .easeInOut(duration: 0.5), colors: [.customPink, .customLightPink.opacity(0.5)])
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.customWhite.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width * 0.93, height: UIScreen.main.bounds.height * 0.57)
                        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    Spacer()
                }

                VStack(spacing: 20) {
                    Spacer()
                    Text("Sign Up")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.customPink)
                        .padding(.bottom, 10)

                    VStack(spacing: 16) {
                        TextField("メールアドレス", text: $viewModel.email, onEditingChanged: { editing in
                            withAnimation {
                                isEmailFocused = editing
                            }
                        })
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.customWhite.opacity(0.7))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)

                        SecureField("パスワード", text: $viewModel.password)
                            .padding()
                            .background(Color.customWhite.opacity(0.7))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                            .onTapGesture {
                                withAnimation {
                                    isPasswordFocused = true
                                }
                            }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)

                    Button(action: {
                        viewModel.shouldNavigateToProfile = true
                    }) {
                        Text("次へ")
                            .font(.headline)
                            .foregroundColor(.customWhite)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.customPink, Color.customLightPink.opacity(0.5)]), startPoint: .bottomLeading, endPoint: .topLeading))
                            .cornerRadius(25)
                            .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)

                    Button(action: {
                        let loginView = UIHostingController(rootView: SignInView(viewModel: viewModel))
                        if let window = UIApplication.shared.windows.first {
                            window.rootViewController = loginView
                            window.makeKeyAndVisible()
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.customPink)
                            Text("サインインへ戻る")
                                .font(.headline)
                                .foregroundColor(.customPink)
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customWhite.opacity(0.8))
                        .cornerRadius(25)
                        .shadow(color: Color.customPink.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToProfile) {
                SignUpProfileView(viewModel: viewModel)
            }
        }
    }
}
