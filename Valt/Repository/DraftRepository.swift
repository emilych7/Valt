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
    func fetchExploreNotes() async throws -> [ExploreNote]
}

extension DraftRepositoryProtocol {
    func fetchExploreNotes() async throws -> [ExploreNote] {
        return ExploreNote.sampleNotes
    }
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
                profileImageURL: "",
                publishedDrafts: []
            )
        }
    }

    func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft] {
        let clean = username.replacingOccurrences(of: "@", with: "").lowercased()
        
        var userID: String? = nil
        
        if let usernameDoc = try? await db.collection("usernames").document(clean).getDocument(),
           let data = usernameDoc.data(),
           let uid = data["userID"] as? String {
            userID = uid
        }
        
        if userID == nil {
            let userSnapshot = try? await db.collection("users")
                .whereField("username", isEqualTo: clean)
                .limit(to: 1)
                .getDocuments()
            if let userDoc = userSnapshot?.documents.first {
                userID = userDoc.documentID
            }
        }
        
        guard let resolvedUID = userID, !resolvedUID.isEmpty else {
            return []
        }

        let snapshot = try await db.collection("drafts")
            .whereField("userID", isEqualTo: resolvedUID)
            .whereField("isPublished", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.map { doc in
            let data = doc.data()
            return Draft(
                id: doc.documentID,
                userID: data["userID"] as? String ?? resolvedUID,
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
                isPrompted: data["isPrompted"] as? Bool ?? false
            )
        }
    }

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
            "prompt": draft.prompt ?? "",
            "isPrompted": draft.isPrompted
        ]
        try await db.collection("drafts").document(draft.id).setData(data)
    }
    
    func getProfileImageURL(for userID: String) async -> String {
        guard !userID.isEmpty else { return "" }
        let storageRef = Storage.storage().reference().child("profilePictures/\(userID).jpg")
        do {
            let url = try await storageRef.downloadURL()
            return url.absoluteString
        } catch {
            return ""
        }
    }
    
    func fetchExploreNotes() async throws -> [ExploreNote] {
        do {
            let snapshot = try await db.collection("drafts")
                .whereField("isPublished", isEqualTo: true)
                .limit(to: 30)
                .getDocuments()
            
            if !snapshot.documents.isEmpty {
                let sortedDocs = snapshot.documents.sorted { doc1, doc2 in
                    let t1 = (doc1.data()["timestamp"] as? Timestamp)?.dateValue() ?? .distantPast
                    let t2 = (doc2.data()["timestamp"] as? Timestamp)?.dateValue() ?? .distantPast
                    return t1 > t2
                }
                
                let userIDs = Array(Set(sortedDocs.compactMap { $0.data()["userID"] as? String }.filter { !$0.isEmpty }))
                
                let authors = await withTaskGroup(of: (String, (username: String, profileImageURL: String)).self) { group in
                    for uid in userIDs {
                        group.addTask {
                            var username = ""
                            do {
                                let userDoc = try await self.db.collection("users").document(uid).getDocument()
                                if let data = userDoc.data(), let name = data["username"] as? String, !name.isEmpty {
                                    let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
                                    username = clean.hasPrefix("@") ? clean : "@\(clean)"
                                }
                            } catch { }
                            
                            if username.isEmpty {
                                do {
                                    let usernameSnapshot = try await self.db.collection("usernames")
                                        .whereField("userID", isEqualTo: uid)
                                        .limit(to: 1)
                                        .getDocuments()
                                    if let doc = usernameSnapshot.documents.first {
                                        let name = doc.documentID.trimmingCharacters(in: .whitespacesAndNewlines)
                                        if !name.isEmpty {
                                            username = name.hasPrefix("@") ? name : "@\(name)"
                                        }
                                    }
                                } catch { }
                            }
                            
                            if username.isEmpty {
                                username = "@user"
                            }
                            
                            let photoURL = await self.getProfileImageURL(for: uid)
                            return (uid, (username: username, profileImageURL: photoURL))
                        }
                    }
                    
                    var map: [String: (username: String, profileImageURL: String)] = [:]
                    for await (uid, info) in group {
                        map[uid] = info
                    }
                    return map
                }
                
                var notes: [ExploreNote] = []
                for (index, doc) in sortedDocs.enumerated() {
                    let data = doc.data()
                    let userID = data["userID"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let content = data["content"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let prompt = data["prompt"] as? String
                    let isPrompted = data["isPrompted"] as? Bool ?? (prompt != nil && !prompt!.isEmpty)
                    let isFavorited = data["isFavorited"] as? Bool ?? false
                    
                    let authorInfo = authors[userID]
                    let authorUsername = authorInfo?.username ?? (userID.isEmpty ? "@user" : "@user_\(userID.prefix(5))")
                    let authorImageURL = authorInfo?.profileImageURL ?? ""
                    
                    let span: ExploreGridSpan
                    switch index % 6 {
                    case 0: span = .tall
                    case 1, 2: span = .compact
                    case 3, 4: span = .standard
                    default: span = .spotlight
                    }
                    
                    let note = ExploreNote(
                        id: doc.documentID,
                        title: title.isEmpty ? "Community Note" : title,
                        content: content,
                        authorUsername: authorUsername,
                        authorID: userID,
                        authorProfileImageURL: authorImageURL,
                        timestamp: timestamp,
                        prompt: prompt,
                        isPrompted: isPrompted,
                        category: isPrompted ? "Prompts" : "Reflections",
                        favoritesCount: 0,
                        isFavorited: isFavorited,
                        layoutSpan: span
                    )
                    notes.append(note)
                }
                if !notes.isEmpty {
                    return notes
                }
            }
        } catch {
            print("Failed to fetch explore notes from Firestore: \(error.localizedDescription)")
        }
        return ExploreNote.sampleNotes
    }
}
