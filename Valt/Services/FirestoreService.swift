import FirebaseFirestore

func fetchDrafts(for userID: String, completion: @escaping ([Draft]) -> Void) {
    let db = Firestore.firestore()
    db.collection("drafts")
        .whereField("userID", isEqualTo: userID)
        .order(by: "timestamp", descending: true)
        .getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching drafts: \(error)")
                completion([])
                return
            }

            let drafts = snapshot?.documents.compactMap { doc -> Draft? in
                let data = doc.data()
                let title = data["title"] as? String ?? "Untitled"
                let content = data["content"] as? String ?? ""
                let isFavorited = data["isFavorited"] as? Bool ?? false
                let isHidden = data["isHidden"] as? Bool ?? false
                
                if let timestamp = data["timestamp"] as? Timestamp {
                    return Draft(
                        id: doc.documentID,
                        title: title,
                        content: content,
                        timestamp: timestamp.dateValue(),
                        isFavorited: isFavorited,
                        isHidden: isHidden
                    )
                } else {
                    // Fallback: if no timestamp, use current Date
                    return Draft(
                        id: doc.documentID,
                        title: title,
                        content: content,
                        timestamp: Date(),
                        isFavorited: isFavorited,
                        isHidden: isHidden
                    )
                }
            } ?? []
            
            completion(drafts)
        }
}




