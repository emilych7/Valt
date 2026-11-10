import SwiftUI

struct ExploreNoteDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var bannerManager: BannerManager
    let note: ExploreNote
    let onAuthorTap: (OtherUser) -> Void
    let onFavoriteToggle: (ExploreNote) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button {
                        dismiss()
                        onAuthorTap(note.asOtherUser)
                    } label: {
                        HStack(spacing: 10) {
                            authorAvatar(size: 38)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.authorUsername)
                                    .font(.custom("OpenSans-Bold", size: 15))
                                    .foregroundColor(Color("TextColor"))
                                
                                Text(note.formattedDate)
                                    .font(.custom("OpenSans-Regular", size: 11))
                                    .foregroundColor(Color("TextColor").opacity(0.55))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                        onAuthorTap(note.asOtherUser)
                    } label: {
                        Text("Profile")
                            .font(.custom("OpenSans-SemiBold", size: 12))
                            .foregroundColor(Color("TextColor"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color("BubbleColor"))
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color("TextColor").opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 12)
                .background(Color("AppBackgroundColor"))
                
                Divider()
                    .background(Color("TextColor").opacity(0.1))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let promptText = note.prompt, !promptText.isEmpty {
                            HStack(alignment: .top, spacing: 10) {
                                Image("promptsIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                    .padding(.top, 2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("PROMPT INSPIRATION")
                                        .font(.custom("OpenSans-Bold", size: 10))
                                        .foregroundColor(Color("TextColor").opacity(0.6))
                                        .tracking(1)
                                    
                                    Text(promptText)
                                        .font(.custom("OpenSans-Medium", size: 14))
                                        .foregroundColor(Color("TextColor"))
                                        .italic()
                                }
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color("CardColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color("TextColor").opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Text(note.title)
                            .font(.custom("OpenSans-Bold", size: 24))
                            .foregroundColor(Color("TextColor"))
                            .multilineTextAlignment(.leading)
                        
                        Text(note.content)
                            .font(.custom("OpenSans-Regular", size: 16))
                            .foregroundColor(Color("TextColor"))
                            .lineSpacing(6)
                            .textSelection(.enabled)
                        
                        Spacer(minLength: 24)
                        
                        if note.isPrompted {
                            HStack(spacing: 6) {
                                Image("promptsIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                Text("Prompted")
                                    .font(.custom("OpenSans-SemiBold", size: 12))
                            }
                            .foregroundColor(Color("TextColor").opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color("BubbleColor")))
                        }
                    }
                    .padding(22)
                }
                
                VStack(spacing: 0) {
                    Divider()
                        .background(Color("TextColor").opacity(0.1))
                    
                    HStack(spacing: 16) {
                        Button {
                            onFavoriteToggle(note)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: note.isFavorited ? "star.fill" : "star")
                                    .font(.system(size: 17))
                                    .foregroundColor(note.isFavorited ? .yellow : Color("TextColor"))
                                
                                Text("\(note.favoritesCount)")
                                    .font(.custom("OpenSans-SemiBold", size: 14))
                                    .foregroundColor(Color("TextColor"))
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Capsule().fill(Color("BubbleColor").opacity(0.7)))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            UIPasteboard.general.string = "\(note.title)\n\n\(note.content)"
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            bannerManager.show(
                                "Note copied to clipboard",
                                backgroundColor: Color("RequestButtonColor"),
                                icon: "checkmarkIcon"
                            )
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 15))
                                Text("Copy")
                                    .font(.custom("OpenSans-SemiBold", size: 14))
                            }
                            .foregroundColor(Color("TextColor"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Capsule().fill(Color("BubbleColor").opacity(0.7)))
                        }
                        .buttonStyle(.plain)
                        
                        ShareLink(
                            item: "\(note.title)\n\n\(note.content)\n\n— \(note.authorUsername) on Valt"
                        ) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15))
                                Text("Share")
                                    .font(.custom("OpenSans-SemiBold", size: 14))
                            }
                            .foregroundColor(Color("TextColor"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Capsule().fill(Color("BubbleColor").opacity(0.7)))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color("AppBackgroundColor"))
                }
            }
            .background(Color("AppBackgroundColor").ignoresSafeArea())
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func authorAvatar(size: CGFloat) -> some View {
        Group {
            if let url = URL(string: note.authorProfileImageURL), !note.authorProfileImageURL.isEmpty {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(Color("TextColor").opacity(0.4))
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(Color("TextColor").opacity(0.4))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
