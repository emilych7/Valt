import FirebaseFirestore
import FirebaseStorage

protocol DraftRepositoryProtocol {
    func fetchDrafts(for userID: String) async throws -> [Draft]
    func fetchDraftsForUsername(username: String) async throws -> [Draft]
    func deleteDraft(draftID: String) async throws
    func saveDraft(draft: Draft) async throws
    func updateDraft(draftID: String, with fields: [AnyHashable: Any]) async throws
    func searchUsers(prefix: String, limit: Int) async throws -> [OtherUser]
    func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft]
    func getProfileImageURL(for userID: String) async -> String
}

final class DraftRepository: DraftRepositoryProtocol {
    let db = Firestore.firestore()

    func searchUsers(prefix: String, limit: Int = 15) async throws -> [OtherUser] {
        let q = prefix.lowercased()
        if q.isEmpty { return [] }

        let end = q + "\u{f8ff}"

        let snapshot = try await db.collection("usernames")
            .order(by: FieldPath.documentID())
            .start(at: [q])
            .end(at: [end])
            .limit(to: limit)
            .getDocuments()

        return snapshot.documents.map { doc in
            let data = doc.data()
            let username = doc.documentID
            let userID = data["userID"] as? String ?? ""
            
            return OtherUser(
                id: userID,
                username: username,
                profileImageURL: "", // Resolve this in the ExploreViewModel
                publishedDrafts: []
            )
        }
    }

    func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft] {
        let userDoc = try await db.collection("usernames").document(username).getDocument()
        
        guard let data = userDoc.data(),
              let userID = data["userID"] as? String else {
            print("No userID found in 'usernames' for \(username)")
            return []
        }
        
        print("Successfully resolved \(username) to \(userID)")

        let snapshot = try await db.collection("drafts")
            .whereField("userID", isEqualTo: userID)
            .whereField("isPublished", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.map { doc in
            let data = doc.data()
            return Draft(
                id: doc.documentID,
                userID: data["userID"] as? String ?? "",
                title: data["title"] as? String ?? "(Untitled)",
                content: data["content"] as? String ?? "",
                timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                isFavorited: data["isFavorited"] as? Bool ?? false,
                isHidden: data["isHidden"] as? Bool ?? false,
                isArchived: data["isArchived"] as? Bool ?? false,
                isPublished: data["isPublished"] as? Bool ?? false,
                prompt: data["prompt"] as? String ?? "",
                isPrompted: data["isPrompted"] as? Bool ?? false
            )
        }
    }

    // Fetch all drafts for a user
    func fetchDrafts(for userID: String) async throws -> [Draft] {
        let snapshot = try await db.collection("drafts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()

        return snapshot.documents.map { doc in
            let data = doc.data()
            return Draft(
                id: doc.documentID,
                userID: data["userID"] as? String ?? "",
                title: data["title"] as? String ?? "(Untitled)",
                content: data["content"] as? String ?? "",
                timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                isFavorited: data["isFavorited"] as? Bool ?? false,
                isHidden: data["isHidden"] as? Bool ?? false,
                isArchived: data["isArchived"] as? Bool ?? false,
                isPublished: data["isPublished"] as? Bool ?? false,
                prompt: data["prompt"] as? String ?? "",
                isPrompted: data["prompt"] as? Bool ?? false
            )
        }
    }

    // Fetch drafts by username (resolves to userID)
    func fetchDraftsForUsername(username: String) async throws -> [Draft] {
        let usersQuery = db.collection("users")
            .whereField("username", isEqualTo: username)
            .limit(to: 1)
        let querySnapshot = try await usersQuery.getDocuments()

        guard let userDocument = querySnapshot.documents.first else {
            return []
        }
        let userID = userDocument.documentID
        return try await fetchDrafts(for: userID)
    }

    func deleteDraft(draftID: String) async throws {
        try await db.collection("drafts").document(draftID).delete()
    }

    func updateDraft(draftID: String, with fields: [AnyHashable: Any]) async throws {
        try await db.collection("drafts").document(draftID).updateData(fields)
    }

    func saveDraft(draft: Draft) async throws {
        let data: [String: Any] = [
            "id": draft.id,
            "userID": draft.userID,
            "title": draft.title,
            "content": draft.content,
            "timestamp": Timestamp(date: draft.timestamp),
            "isFavorited": draft.isFavorited,
            "isHidden": draft.isHidden,
            "isArchived": draft.isArchived,
            "isPublished": draft.isPublished,
            "prompt": draft.prompt ?? ""
            
        ]
        try await db.collection("drafts").document(draft.id).setData(data)
    }
    
    func getProfileImageURL(for userID: String) async -> String {
        let storageRef = Storage.storage().reference().child("profilePictures/\(userID).jpg")
        do {
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            // Return empty so ExploreView knows to use the default profile pic fallback
            return ""
        }
    }
}
