//
//  BooksView.swift
//  DailyPhoto
//
//  Created by 伊藤璃乃 on 2025/01/24.
//


import SwiftUI
import Kingfisher

struct BooksView: View {
    @StateObject private var booksViewModel = BooksViewModel()
    @StateObject private var imageGalleryViewModel = ImageGalleryViewModel()

    let uid: String
    @State var selectedSectionId: String? = nil
    @State var show = false
    @State var show2 = false
    @State var move = false
    @State var close = false
    @State var isAnimating = false
    @State var isExpanded = false
    @State var isTapLock = false
    @State var isTapNomal = false

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            ZStack {
                if selectedSectionId == nil {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 80) {
                            Spacer()
                                .frame(width: 15)
                            ForEach(booksViewModel.coverImages.keys.sorted(), id: \.self) { sectionId in
                                if let imageUrl = booksViewModel.coverImages[sectionId] {
                                    let isLocked = booksViewModel.lockedSections.contains(sectionId)

                                    ZStack {
                                        if show {
                                            ZStack {
                                                PageView(images: imageGalleryViewModel.images)
                                                    .shadow(radius: 10)
                                                    .cornerRadius(5)
                                                BehindCaver(show2: $show2, close: $close)
                                                Rectangle().foregroundStyle(.black)
                                                    .opacity(0.7)
                                                    .frame(width: 1)
                                                    .frame(height: 263)
                                                    .blur(radius: 5)
                                                    .offset(x: -90)
                                            }
                                            .scrollTransition(.interactive, axis: .horizontal) {content, phase in
                                                content
                                                    .scaleEffect(phase == .identity ? 1 : 0.9, anchor: .bottom)
                                                    .offset(y: phase == .identity ? 0 : 35)
                                                    .rotationEffect(.init(degrees: phase == .identity ? 0 : phase.value * 35), anchor: .bottom)
                                            }
                                        }

                                        IsometricView(depth: 5) {
                                            KFImage(URL(string: imageUrl))
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .scaledToFill()
                                                .frame(width: 180, height: 264)
                                                .clipped()
                                                .clipShape(CustomCornerShape(radius: 6))
                                                .opacity(isLocked ? 0.0 : 1.0)
                                                .overlay(
                                                    ZStack {
                                                        if isLocked {
                                                            PinkMeshGradientView()
                                                            Image(systemName: "lock.fill")
                                                                .foregroundColor(.white)
                                                                .frame(width: 60, height: 60)
                                                                .position(x: 90, y: 130)
                                                        }
                                                    }
                                                )
                                                .overlay(
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        if let dates = booksViewModel.sectionDates[sectionId] {
                                                            let formattedCreatedAt = formatDate(dates.createdAt).uppercased()
                                                            let formattedDate = dates.date != nil ? formatDate(dates.date!).uppercased() : "NOT SET"

                                                            VStack(alignment: .leading, spacing: 2) {
                                                                Text(formattedCreatedAt)
                                                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                                    .foregroundStyle(.customWhite)
                                                                    .shadow(radius: 2)

                                                                Text(formattedDate)
                                                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                                                    .foregroundStyle(.customWhite.opacity(0.8))
                                                                    .shadow(radius: 2)
                                                            }
                                                            .padding(6)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                        }
                                                    }
                                                        .padding(3)
                                                    , alignment: .bottomLeading
                                                )
                                        } bottom: {
                                            Color.gray.opacity(0.2)
                                        } side: {
                                            Color.gray.opacity(0.2)
                                        }
                                        .onTapGesture {
                                            if !isLocked && !isAnimating {
                                                openBookToggle(sectionId: sectionId)
                                                toggleExpand()
                                            }
                                            if !isLocked {
                                                isTapNomal = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                                    isTapNomal = false
                                                }
                                            } else {
                                                isTapLock = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                    isTapLock = false
                                                }
                                            }
                                        }
                                        .rotation3DEffect(
                                            .degrees(show ? -90 : 0),
                                            axis: (x: 0, y: 1, z: 0),
                                            anchor: .leading,
                                            anchorZ: 0,
                                            perspective: 0.3
                                        )
                                        .frame(width: 180, height: 264)
                                        .scrollTransition(.interactive, axis: .horizontal) {content, phase in
                                            content
                                                .scaleEffect(phase == .identity ? 1 : 0.9, anchor: .bottom)
                                                .offset(y: phase == .identity ? 0 : 35)
                                                .rotationEffect(.init(degrees: phase == .identity ? 0 : phase.value * 35), anchor: .bottom)
                                        }
                                        .shadow(color: .gray, radius: 3, x: 0, y: 2)
                                    }
                                }
                            }
                            Spacer()
                                .frame(width: 15)
                        }
                        .padding()
                    }
                    .task {
                        await booksViewModel.fetchCoverImages(uid: uid)
                    }
                } else {
                    if let sectionId = selectedSectionId, let imageUrl = booksViewModel.coverImages[sectionId] {
                        ZStack {
                            if show {
                                ZStack {
                                    PageView(images: imageGalleryViewModel.images)
                                        .shadow(radius: 10)
                                        .zIndex(1)
                                    BehindCaver(show2: $show2, close: $close)
                                    Rectangle().foregroundStyle(.black)
                                        .opacity(0.7)
                                        .frame(width: 1)
                                        .frame(height: 263)
                                        .blur(radius: 5)
                                        .offset(x: -90)
                                }
                                .zIndex(1)
                                .onTapGesture {
                                    if !isAnimating {
                                        openBookToggle(sectionId: sectionId)
                                        toggleExpand()
                                    }
                                }
                            }

                            IsometricView(depth: 5) {
                                KFImage(URL(string: imageUrl))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .scaledToFill()
                                    .frame(width: 180, height: 264)
                                    .clipped()
                                    .clipShape(CustomCornerShape(radius: 6))
                            } bottom: {
                                Color.gray.opacity(0.2)
                            } side: {
                                Color.gray.opacity(0.2)
                            }
                            .onTapGesture {
                                if !isAnimating {
                                    openBookToggle(sectionId: sectionId)
                                    toggleExpand()
                                }
                            }
                            .rotation3DEffect(
                                .degrees(show ? -90 : 0),
                                axis: (x: 0, y: 1, z: 0),
                                anchor: .leading,
                                anchorZ: 0,
                                perspective: 0.3
                            )
                            .frame(width: 180, height: 264)
                            .zIndex(isAnimating ? 2 : 0)
                            .shadow(color: .gray, radius: 3, x: 0, y: 2)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                    }
                }
            }
            .scaleEffect(isExpanded ? 1.9 : 1.6)
            .sensoryFeedback(.error, trigger: isTapLock)
            .sensoryFeedback(.success, trigger: isTapNomal)
        }
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd.EEE"
        return formatter.string(from: date)
    }
    func openBookToggle(sectionId: String) {
        isAnimating = true

        if selectedSectionId == sectionId {
            withAnimation(.linear(duration: 1).delay(0.49)) {
                show.toggle()
            }

            withAnimation(.linear(duration: 1)) {
                show2.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.49) {
                close = true
            }

            withAnimation(.linear(duration: 0.4).delay(0.4)) {
                move.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                selectedSectionId = nil
                isAnimating = false
            }
        } else {
            selectedSectionId = sectionId
            Task {
                await imageGalleryViewModel.fetchImages(uid: uid, sectionId: sectionId)
                print("Fetched images count:", imageGalleryViewModel.images.count)
            }

            close = false

            withAnimation(.linear(duration: 0.5)) {
                show.toggle()
            }
            withAnimation(.linear(duration: 1.0)) {
                show2.toggle()
            }
            withAnimation(.linear(duration: 0.4).delay(0.4)) {
                move.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                isAnimating = false
            }
        }
    }

    func toggleExpand() {
        isAnimating = true
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)) {
            isExpanded.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnimating = false
        }
    }
}
