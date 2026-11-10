import SwiftUI

struct ExploreNoteCard: View {
    let note: ExploreNote
    let span: ExploreGridSpan
    let onSelect: (ExploreNote) -> Void
    let onAuthorTap: (OtherUser) -> Void
    let onFavoriteToggle: (ExploreNote) -> Void
    
    var body: some View {
        Button {
            onSelect(note)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color("CardColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color("TextColor").opacity(0.08), lineWidth: 1)
                    )
                    .shadow(
                        color: Color.black.opacity(0.03),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                
                switch span {
                case .tall:
                    tallCardContent
                case .compact:
                    compactCardContent
                case .standard:
                    standardCardContent
                case .spotlight:
                    spotlightCardContent
                }
            }
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                onSelect(note)
            } label: {
                Label("Read Full Note", systemImage: "doc.text.magnifyingglass")
            }
            
            Button {
                onAuthorTap(note.asOtherUser)
            } label: {
                Label("Visit \(note.authorUsername)", systemImage: "person.crop.circle")
            }
            
            Button {
                UIPasteboard.general.string = "\(note.title)\n\n\(note.content)"
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } label: {
                Label("Copy Note", systemImage: "doc.on.doc")
            }
            
            Button {
                onFavoriteToggle(note)
            } label: {
                Label(note.isFavorited ? "Favorited" : "Save to Favorites", systemImage: note.isFavorited ? "star.fill" : "star")
            }
            
            ShareLink(item: "\(note.title)\n\n\(note.content)\n\n— \(note.authorUsername) on Valt") {
                Label("Share Note", systemImage: "square.and.arrow.up")
            }
        } preview: {
            FullNotePreview(draft: note.asDraft)
        }
    }
    
    private var tallCardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                if note.isPrompted {
                    HStack(spacing: 4) {
                        Image("promptsIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                        Text("Prompted")
                            .font(.custom("OpenSans-SemiBold", size: 9))
                    }
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color("BubbleColor")))
                }
                
                Spacer()
                
                Text(note.relativeTime)
                    .font(.custom("OpenSans-Regular", size: 10))
                    .foregroundColor(Color("TextColor").opacity(0.5))
            }
            
            if let promptText = note.prompt, !promptText.isEmpty {
                Text(promptText)
                    .font(.custom("OpenSans-Medium", size: 10))
                    .foregroundColor(Color("TextColor").opacity(0.75))
                    .lineLimit(2)
                    .italic()
                    .padding(.vertical, 2)
            }
            
            Text(note.title)
                .font(.custom("OpenSans-Bold", size: 14))
                .foregroundColor(Color("TextColor"))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(note.content)
                .font(.custom("OpenSans-Regular", size: 11))
                .foregroundColor(Color("TextColor").opacity(0.85))
                .lineSpacing(3)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
            
            authorRow(avatarSize: 22, textSize: 11)
        }
        .padding(12)
        .frame(height: 260)
    }
    
    private var compactCardContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            if note.isPrompted {
                HStack(spacing: 4) {
                    Image("promptsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                    Text("Prompted")
                        .font(.custom("OpenSans-SemiBold", size: 9))
                }
                .foregroundColor(Color("TextColor"))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color("BubbleColor")))
            }
            
            Text(note.title)
                .font(.custom("OpenSans-Bold", size: 12))
                .foregroundColor(Color("TextColor"))
                .lineLimit(1)
            
            Text(note.content)
                .font(.custom("OpenSans-Regular", size: 10.5))
                .foregroundColor(Color("TextColor").opacity(0.8))
                .lineLimit(note.isPrompted ? 2 : 3)
                .lineSpacing(2)
            
            Spacer(minLength: 0)
            
            authorRow(avatarSize: 18, textSize: 10)
        }
        .padding(10)
        .frame(height: 124)
    }
    
    private var standardCardContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            if note.isPrompted {
                HStack(spacing: 4) {
                    Image("promptsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                    Text("Prompted")
                        .font(.custom("OpenSans-SemiBold", size: 9))
                }
                .foregroundColor(Color("TextColor"))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color("BubbleColor")))
            }
            
            Text(note.title)
                .font(.custom("OpenSans-Bold", size: 13))
                .foregroundColor(Color("TextColor"))
                .lineLimit(2)
            
            Text(note.content)
                .font(.custom("OpenSans-Regular", size: 11))
                .foregroundColor(Color("TextColor").opacity(0.8))
                .lineSpacing(2.5)
                .lineLimit(note.isPrompted ? 3 : 4)
            
            Spacer(minLength: 0)
            
            authorRow(avatarSize: 20, textSize: 10.5)
        }
        .padding(11)
        .frame(height: 160)
    }
    
    private var spotlightCardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Button {
                    onAuthorTap(note.asOtherUser)
                } label: {
                    HStack(spacing: 7) {
                        authorAvatar(size: 26)
                        
                        Text(note.authorUsername)
                            .font(.custom("OpenSans-SemiBold", size: 13))
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                if note.isPrompted {
                    HStack(spacing: 4) {
                        Image("promptsIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 10, height: 10)
                        Text("Prompted")
                            .font(.custom("OpenSans-SemiBold", size: 9))
                    }
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color("BubbleColor")))
                }
            }
            
            Text(note.title)
                .font(.custom("OpenSans-Bold", size: 15))
                .foregroundColor(Color("TextColor"))
                .lineLimit(1)
            
            Text(note.content)
                .font(.custom("OpenSans-Regular", size: 12))
                .foregroundColor(Color("TextColor").opacity(0.85))
                .lineSpacing(3)
                .lineLimit(3)
            
            Spacer(minLength: 0)
            
            HStack {
                Text(note.formattedDate)
                    .font(.custom("OpenSans-Regular", size: 11))
                    .foregroundColor(Color("TextColor").opacity(0.5))
                
                Spacer()
                
                Button {
                    onFavoriteToggle(note)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: note.isFavorited ? "star.fill" : "star")
                            .font(.system(size: 13))
                            .foregroundColor(note.isFavorited ? .yellow : Color("TextColor").opacity(0.6))
                        
                        Text("\(note.favoritesCount)")
                            .font(.custom("OpenSans-SemiBold", size: 11))
                            .foregroundColor(Color("TextColor").opacity(0.8))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color("BubbleColor").opacity(0.6)))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 155)
    }
    
    private func authorRow(avatarSize: CGFloat, textSize: CGFloat) -> some View {
        HStack(spacing: 5) {
            Button {
                onAuthorTap(note.asOtherUser)
            } label: {
                HStack(spacing: 5) {
                    authorAvatar(size: avatarSize)
                    
                    Text(note.authorUsername)
                        .font(.custom("OpenSans-SemiBold", size: textSize))
                        .foregroundColor(Color("TextColor"))
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 4)
            
            Button {
                onFavoriteToggle(note)
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: note.isFavorited ? "star.fill" : "star")
                        .font(.system(size: textSize))
                        .foregroundColor(note.isFavorited ? .yellow : Color("TextColor").opacity(0.55))
                    
                    Text("\(note.favoritesCount)")
                        .font(.custom("OpenSans-Regular", size: textSize))
                        .foregroundColor(Color("TextColor").opacity(0.7))
                }
            }
            .buttonStyle(.plain)
        }
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
