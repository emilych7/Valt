import FirebaseFirestore

protocol DraftRepositoryProtocol {
    func fetchDrafts(for userID: String, completion: @escaping ([Draft]) -> Void)
    func fetchDrafts(for userID: String) async throws -> [Draft]
    func fetchDraftsForUsername(username: String) async throws -> [Draft]
    func deleteDraft(draftID: String) async throws
    // Added the missing function to the protocol
    func saveDraft(draft: Draft) async throws
}

final class DraftRepository: DraftRepositoryProtocol {
    let db = Firestore.firestore()
    
    func fetchDraftsForUsername(username: String) async throws -> [Draft] {
        // 1. Asynchronously query the "users" collection.
        let usersQuery = db.collection("users").whereField("username", isEqualTo: username).limit(to: 1)
        let querySnapshot = try await usersQuery.getDocuments()
        
        // 2. Check if a user document was found. If not, throw a specific error.
        if let userDocument = querySnapshot.documents.first {
            // If found, get the userID.
            let userID = userDocument.documentID
            
            // 3. Call the other async function to fetch the drafts and return the result directly.
            return try await fetchDrafts(for: userID)
        } else {
            // If no user is found, print a message and return an empty array.
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

        // Manually map the documents to Draft objects, providing default values.
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
                isPublished: data["isPublished"] as? Bool ?? false
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
                        isPublished: data["isPublished"] as? Bool ?? false
                    )
                } ?? []
                
                completion(drafts)
            }
    }
    
    // Added the missing function to save a draft to Firestore
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
