//
//  GroupMembersView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/03.
//

import SwiftUI
import Kingfisher
import FirebaseAuth

struct GroupMembersView: View {
    @StateObject private var viewModel = GroupViewModel()
    @State private var showActionSheet = false
    @State private var selectedMember: MemberModel?
    @State private var showQRGenerator = false  // QRコード生成画面を表示するためのフラグ
    private let currentUserId = Auth.auth().currentUser?.uid

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.customWhite.opacity(0.3))
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 5)
                .padding(.horizontal)
                .blur(radius: 0.1)

            VStack(spacing: 20) {
                Text("グループメンバー")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.customBlack)
                    .padding(.top, 20)

                ZStack {
                    ScrollView {
                        VStack(spacing: 15) {
                            // メンバーのリスト
                            ForEach(viewModel.members) { member in
                                memberCard(member: member)
                                    .onLongPressGesture {
                                        if member.id != currentUserId {
                                            selectedMember = member
                                            showActionSheet = true
                                        }
                                    }
                            }

                            // メンバーが1人のときに「メンバーを追加」カードを表示
                            if viewModel.members.count == 1 {
                                addMemberCard()
                                    .onTapGesture {
                                        showQRGenerator.toggle()
                                    }
                            }
                        }
                        .padding()
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchFirstGroupAndMembers()
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("メンバー管理"),
                message: Text("\(selectedMember?.name ?? "このユーザー") をどうしますか？"),
                buttons: [
                    .destructive(Text("ブロック")) {
                        if let member = selectedMember {
                            Task {
                                await viewModel.blockUser(memberId: member.id)
                            }
                        }
                    },
                    .default(Text("通報")) {
                        if let member = selectedMember {
                            reportUser(member: member)
                        }
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showQRGenerator) {
            QRCodeGeneratorView(navigateToCustomTab: $showQRGenerator, isPresentedFromGroupMembers: true)
                .environmentObject(AuthViewModel())
                .presentationDetents([
                    .height(450)
                ])
                .presentationDragIndicator(.visible)
        }
    }

    private func memberCard(member: MemberModel) -> some View {
        HStack(spacing: 15) {
            if let iconUrl = member.iconUrl, let url = URL(string: iconUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
            } else {
                Circle()
                    .fill(Color.customPink.opacity(0.7))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
            }

            Text(member.name)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.leading, 5)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.customWhite.opacity(0.7))
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
        .padding(.horizontal, 15)
    }

    // 「メンバーを追加」用のカード
    private func addMemberCard() -> some View {
        Button(action: {
            showQRGenerator = true
        }) {
            HStack(spacing: 15) {
                Circle()
                    .fill(Color.customPink)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                    )
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)

                Text("メンバーを追加")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.leading, 5)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.customWhite.opacity(0.7))
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 5)
            .padding(.horizontal, 15)
        }
    }

    private func reportUser(member: MemberModel) {
        let reportURL = "https://forms.gle/sbTcRmH9K9BfrKzd7"
        if let url = URL(string: reportURL) {
            UIApplication.shared.open(url)
        }
    }
}
