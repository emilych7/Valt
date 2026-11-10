import Foundation

enum ExploreGridSpan: String, Codable {
    case standard
    case tall
    case compact
    case spotlight
}

struct ExploreNote: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var content: String
    var authorUsername: String
    var authorID: String
    var authorProfileImageURL: String
    var timestamp: Date
    var prompt: String?
    var isPrompted: Bool
    var category: String
    var favoritesCount: Int
    var isFavorited: Bool
    var layoutSpan: ExploreGridSpan
    
    var likesCount: Int {
        get { favoritesCount }
        set { favoritesCount = newValue }
    }
    
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var formattedDate: String {
        timestamp.formatted(.dateTime.month(.abbreviated).day().year())
    }
    
    var asDraft: Draft {
        Draft(
            id: id,
            userID: authorID,
            title: title,
            content: content,
            timestamp: timestamp,
            isFavorited: isFavorited,
            isHidden: false,
            isArchived: false,
            isPublished: true,
            prompt: prompt,
            isPrompted: isPrompted
        )
    }
    
    var asOtherUser: OtherUser {
        OtherUser(
            id: authorID,
            username: authorUsername,
            profileImageURL: authorProfileImageURL,
            publishedDrafts: [asDraft]
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ExploreNote, rhs: ExploreNote) -> Bool {
        lhs.id == rhs.id && lhs.isFavorited == rhs.isFavorited && lhs.favoritesCount == rhs.favoritesCount
    }
}

extension ExploreNote {
    static let sampleNotes: [ExploreNote] = [
        ExploreNote(
            id: "exp_1",
            title: "The Art of Subtraction",
            content: "We think adding more tools will simplify our life, but true clarity almost always comes from subtraction. Clearing out the mental and digital noise isn't an absence of ambition—it is the fierce protection of deep focus. When in doubt, ask: what can I remove today?",
            authorUsername: "@elena_v",
            authorID: "user_elena",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-3600 * 4),
            prompt: "What is something non-essential you recently stopped doing?",
            isPrompted: true,
            category: "Reflections",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .tall
        ),
        ExploreNote(
            id: "exp_2",
            title: "Sunday Coffee & Architecture",
            content: "Warm sunlight slicing through raw concrete at 7 AM. Walking through an empty city before anyone else is awake gives you a rare perspective on space and silence.",
            authorUsername: "@marcus_k",
            authorID: "user_marcus",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-3600 * 12),
            prompt: nil,
            isPrompted: false,
            category: "Creative",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .compact
        ),
        ExploreNote(
            id: "exp_3",
            title: "The Focus Muscle",
            content: "Attention is not a personality trait; it is a muscle. If you do not deliberately carve out uninterrupted blocks of stillness, the modern world will eagerly claim them for you.",
            authorUsername: "@clara_dev",
            authorID: "user_clara",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-3600 * 20),
            prompt: nil,
            isPrompted: false,
            category: "Thoughts",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .compact
        ),
        ExploreNote(
            id: "exp_4",
            title: "Books That Rewired My Thinking",
            content: "Three titles I find myself returning to every year:\n1. The Creative Act — Rick Rubin\n2. Thinking in Systems — Donella Meadows\n3. Letters from a Stoic — Seneca.\nEach one changes how you observe the everyday world.",
            authorUsername: "@jordan_t",
            authorID: "user_jordan",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 1.5),
            prompt: "What book altered the way you make daily decisions?",
            isPrompted: true,
            category: "Reflections",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .standard
        ),
        ExploreNote(
            id: "exp_5",
            title: "Designing for Stillness",
            content: "The best interfaces never scream for your attention. They hold space for your thoughts, quietly do what you ask of them, and then get completely out of the way.",
            authorUsername: "@avery_design",
            authorID: "user_avery",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 2),
            prompt: nil,
            isPrompted: false,
            category: "Creative",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .standard
        ),
        ExploreNote(
            id: "exp_6",
            title: "Evening Gratitude & Micro-Moments",
            content: "Three quiet moments today:\n• The smell of rain just before the storm broke\n• Writing down an idea that had been stuck in my head for three days\n• Dinner with a childhood friend who reminds me of who I am when nobody is watching.",
            authorUsername: "@maya_reads",
            authorID: "user_maya",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 3),
            prompt: "What brought you unexpected peace today?",
            isPrompted: true,
            category: "Prompts",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .spotlight
        ),
        ExploreNote(
            id: "exp_7",
            title: "Digital Minimalism Rule",
            content: "Treat your home screen like your physical desk. If an app doesn't serve a clear, deliberate purpose, move it out of sight.",
            authorUsername: "@kai_zen",
            authorID: "user_kai",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 3.5),
            prompt: nil,
            isPrompted: false,
            category: "Thoughts",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .compact
        ),
        ExploreNote(
            id: "exp_8",
            title: "Done is Better Than Perfect",
            content: "Perfectionism is just procrastination wearing a sharp suit. Ship the draft, write the messy sentence, embrace iteration.",
            authorUsername: "@mateo_n",
            authorID: "user_mateo",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 4),
            prompt: nil,
            isPrompted: false,
            category: "Quotes",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .compact
        ),
        ExploreNote(
            id: "exp_9",
            title: "Why Writing Daily Unlocks Clarity",
            content: "Writing isn't merely recording what you already know. Most of the time, putting words on a page is the only way to figure out what you genuinely believe. The blank page is a mirror for your instincts.",
            authorUsername: "@sora_m",
            authorID: "user_sora",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 5),
            prompt: "Write about an opinion you've changed your mind about.",
            isPrompted: true,
            category: "Prompts",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .tall
        ),
        ExploreNote(
            id: "exp_10",
            title: "A Letter to My 20-Year-Old Self",
            content: "You don't need the next ten years planned down to the week. You simply need to make the next honorable choice, stay relentlessly curious, and trust compounding over time.",
            authorUsername: "@noah_w",
            authorID: "user_noah",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 6),
            prompt: nil,
            isPrompted: false,
            category: "Reflections",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .standard
        ),
        ExploreNote(
            id: "exp_11",
            title: "On Creative Resilience",
            content: "Inspiration is wonderful when it strikes, but routine is what actually builds bodies of work. Show up when you feel inspired, but show up especially when you don't.",
            authorUsername: "@lyra_t",
            authorID: "user_lyra",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 7),
            prompt: "What habit has kept you going through doubt?",
            isPrompted: true,
            category: "Reflections",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .standard
        ),
        ExploreNote(
            id: "exp_12",
            title: "The Quiet Luxury of Time",
            content: "Having an afternoon with no scheduled calls, no notifications, and an unread notebook is the highest status symbol of the 21st century.",
            authorUsername: "@hannah_b",
            authorID: "user_hannah",
            authorProfileImageURL: "",
            timestamp: Date().addingTimeInterval(-86400 * 8),
            prompt: nil,
            isPrompted: false,
            category: "Quotes",
            favoritesCount: 0,
            isFavorited: false,
            layoutSpan: .spotlight
        )
    ]
}
