import FirebaseFirestore

protocol DraftRepositoryProtocol {
    func fetchDrafts(for userID: String, completion: @escaping ([Draft]) -> Void)
}

final class DraftRepository: DraftRepositoryProtocol {

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
                        title: data["title"] as? String ?? "(Untitled)",
                        content: data["content"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        isFavorited: data["isFavorited"] as? Bool ?? false,
                        isHidden: data["isHidden"] as? Bool ?? false,
                        isArchived: data["isArchived"] as? Bool ?? false
                    )
                } ?? []
                
                completion(drafts)
            }
    }
}
