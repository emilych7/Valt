import FirebaseFirestore

protocol DraftRepositoryProtocol {
    func fetchDrafts(for userID: String) async throws -> [Draft]
    func fetchDraftsForUsername(username: String) async throws -> [Draft]
    func deleteDraft(draftID: String) async throws
    func saveDraft(draft: Draft) async throws
    func updateDraft(draftID: String, with fields: [AnyHashable: Any]) async throws

    func searchUsernames(prefix: String, limit: Int) async throws -> [String]
    func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft]
}

final class DraftRepository: DraftRepositoryProtocol {
    let db = Firestore.firestore()

    func searchUsernames(prefix: String, limit: Int = 15) async throws -> [String] {
        let q = prefix.lowercased()
        if q.isEmpty { return [] }

        // Firestore prefix query trick: endAt is prefix + \u{f8ff}
        let end = q + "\u{f8ff}"

        let snapshot = try await db.collection("usernames")
            .order(by: FieldPath.documentID())
            .start(at: [q])
            .end(at: [end])
            .limit(to: limit)
            .getDocuments()

        // Return canonical username (documentID)
        return snapshot.documents.map { $0.documentID }
    }

    func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft] {
        let usersQuery = db.collection("users")
            .whereField("username", isEqualTo: username)
            .limit(to: 1)
        let userSnap = try await usersQuery.getDocuments()

        guard let userDoc = userSnap.documents.first else { return [] }
        let userID = userDoc.documentID

        // Get published drafts for that userID
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
                prompt: data["prompt"] as? String ?? ""
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
            "prompt": draft.prompt
            
        ]
        try await db.collection("drafts").document(draft.id).setData(data)
    }
}
