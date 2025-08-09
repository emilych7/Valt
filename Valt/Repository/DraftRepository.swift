import FirebaseFirestore

protocol DraftRepositoryProtocol {
    func fetchDrafts(for userID: String, completion: @escaping ([Draft]) -> Void)
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
            // Firestore prefix query trick: endAt is prefix + \u{f8ff}
            let end = q + "\u{f8ff}"

            let snapshot = try await db.collection("users")
                .order(by: "username_lowercase")
                .start(at: [q])
                .end(at: [end])
                .limit(to: limit)
                .getDocuments()

            // Return the canonical `username` field (preserve original casing for display)
            return snapshot.documents.compactMap { $0.data()["username"] as? String }
        }

        /// Fetch all published drafts for a given username.
        func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft] {
            // 1) Resolve username -> userID
            let usersQuery = db.collection("users")
                .whereField("username", isEqualTo: username)
                .limit(to: 1)
            let userSnap = try await usersQuery.getDocuments()

            guard let userDoc = userSnap.documents.first else {
                return []
            }
            let userID = userDoc.documentID

            // 2) Query drafts where userID matches and isPublished == true
            let snapshot = try await db.collection("drafts")
                .whereField("userID", isEqualTo: userID)
                .whereField("isPublished", isEqualTo: true)
                .getDocuments()

            // Map to Draft
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
                    isPrompted: data["isPrompted"] as? Bool ?? false
                )
            }
        }
    
    
    func fetchDraftsForUsername(username: String) async throws -> [Draft] {
        let usersQuery = db.collection("users").whereField("username", isEqualTo: username).limit(to: 1)
        let querySnapshot = try await usersQuery.getDocuments()
        
        if let userDocument = querySnapshot.documents.first {
            let userID = userDocument.documentID
    
            return try await fetchDrafts(for: userID)
        } else {
            print("User with username '\(username)' not found.")
            return []
        }
    }
    
    func deleteDraft(draftID: String) async throws {
        let draftRef = db.collection("drafts").document(draftID)
        try await draftRef.delete()
        print("Draft document with ID \(draftID) successfully deleted.")
    }
    
    func fetchDrafts(for userID: String) async throws -> [Draft] {
        let snapshot = try await db.collection("drafts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()

        let drafts = snapshot.documents.map { doc -> Draft in
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
                isPrompted: data["isPrompted"] as? Bool ?? false
            )
        }
        return drafts
    }

    func fetchDrafts(for userID: String, completion: @escaping ([Draft]) -> Void) {
        Firestore.firestore()
            .collection("drafts")
            .whereField("userID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching drafts: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let drafts = snapshot?.documents.map { doc -> Draft in
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
                        isPrompted: data["isPrompted"] as? Bool ?? false
                    )
                } ?? []
                
                completion(drafts)
            }
    }
    
    func updateDraft(draftID: String, with fields: [AnyHashable: Any]) async throws {
            try await db.collection("drafts").document(draftID).updateData(fields)
        }
    
    // Save a draft to Firestore
    func saveDraft(draft: Draft) async throws {
        let draftData: [String: Any] = [
            "id": draft.id,
            "userID": draft.userID,
            "title": draft.title,
            "content": draft.content,
            "timestamp": Timestamp(date: draft.timestamp),
            "isFavorited": draft.isFavorited,
            "isHidden": draft.isHidden,
            "isArchived": draft.isArchived,
            "isPublished": draft.isPublished
        ]
        
        try await db.collection("drafts").document(draft.id).setData(draftData)
        print("Draft with ID \(draft.id) saved successfully.")
    }
}
