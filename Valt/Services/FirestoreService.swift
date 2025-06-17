import FirebaseFirestore

func fetchDrafts(for userID: String, completion: @escaping ([Draft]) -> Void) {
    let db = Firestore.firestore()
    db.collection("drafts")
        .whereField("userID", isEqualTo: userID)
        .order(by: "timestamp", descending: true) // optional
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
                return Draft(id: doc.documentID, title: title, content: content)
            } ?? []
            
            completion(drafts)
        }
}

