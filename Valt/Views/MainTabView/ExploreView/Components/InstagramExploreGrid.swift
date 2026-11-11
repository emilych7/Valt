import SwiftUI

struct InstagramExploreGrid: View {
    let notes: [ExploreNote]
    let promptSuggestions: [String]
    let onSelectNote: (ExploreNote) -> Void
    let onAuthorTap: (OtherUser) -> Void
    let onFavoriteToggle: (ExploreNote) -> Void
    let onSelectPrompt: (String) -> Void
    let onRefresh: () async -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                if !notes.isEmpty {
                    mosaicContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.always, axes: .vertical)
        .refreshable {
            await onRefresh()
        }
        .onAppear {
            UIScrollView.appearance().bounces = true
            UIScrollView.appearance().alwaysBounceVertical = true
        }
    }
    
    @ViewBuilder
    private var mosaicContent: some View {
        let clusters = buildClusters(from: notes)
        
        ForEach(clusters.indices, id: \.self) { index in
            let cluster = clusters[index]
            
            switch cluster {
            case .noteLeft(let note, let suggestions):
                HStack(alignment: .top, spacing: 12) {
                    ExploreNoteCard(
                        note: note,
                        span: .tall,
                        onSelect: onSelectNote,
                        onAuthorTap: onAuthorTap,
                        onFavoriteToggle: onFavoriteToggle
                    )
                    
                    VStack(spacing: 12) {
                        ForEach(suggestions.indices, id: \.self) { sIdx in
                            let prompt = suggestions[sIdx]
                            ExplorePromptSuggestionCard(
                                prompt: prompt,
                                style: .compact,
                                onTap: {
                                    onSelectPrompt(prompt)
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
            case .noteRight(let note, let suggestions):
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 12) {
                        ForEach(suggestions.indices, id: \.self) { sIdx in
                            let prompt = suggestions[sIdx]
                            ExplorePromptSuggestionCard(
                                prompt: prompt,
                                style: .compact,
                                onTap: {
                                    onSelectPrompt(prompt)
                                }
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    ExploreNoteCard(
                        note: note,
                        span: .tall,
                        onSelect: onSelectNote,
                        onAuthorTap: onAuthorTap,
                        onFavoriteToggle: onFavoriteToggle
                    )
                }
                
            case .spotlight(let note):
                ExploreNoteCard(
                    note: note,
                    span: .spotlight,
                    onSelect: onSelectNote,
                    onAuthorTap: onAuthorTap,
                    onFavoriteToggle: onFavoriteToggle
                )
            }
        }
    }
    
    private func suggestionsForPair(at pairIndex: Int) -> [String] {
        guard !promptSuggestions.isEmpty else { return [] }
        let startIndex = pairIndex * 2
        var items: [String] = []
        for offset in 0..<2 {
            let promptIndex = (startIndex + offset) % promptSuggestions.count
            items.append(promptSuggestions[promptIndex])
        }
        return items
    }
    
    private enum ExploreCluster {
        case noteLeft(note: ExploreNote, suggestions: [String])
        case noteRight(note: ExploreNote, suggestions: [String])
        case spotlight(note: ExploreNote)
    }
    
    private func buildClusters(from items: [ExploreNote]) -> [ExploreCluster] {
        var clusters: [ExploreCluster] = []
        var promptPairIndex = 0
        
        for (index, note) in items.enumerated() {
            switch index % 3 {
            case 0:
                let pair = suggestionsForPair(at: promptPairIndex)
                promptPairIndex += 1
                clusters.append(.noteLeft(note: note, suggestions: pair))
            case 1:
                let pair = suggestionsForPair(at: promptPairIndex)
                promptPairIndex += 1
                clusters.append(.noteRight(note: note, suggestions: pair))
            case 2:
                clusters.append(.spotlight(note: note))
            default:
                let pair = suggestionsForPair(at: promptPairIndex)
                promptPairIndex += 1
                clusters.append(.noteLeft(note: note, suggestions: pair))
            }
        }
        
        return clusters
    }
}
