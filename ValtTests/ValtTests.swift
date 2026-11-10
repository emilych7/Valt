//
//  ValtTests.swift
//  ValtTests
//
//  Created by Emily Chrisann Hernandez on 6/6/25.
//

import Testing
import Foundation
import FirebaseFirestore
import FirebaseAuth
@testable import Valt

final class MockDraftRepository: DraftRepositoryProtocol {
    var drafts: [Draft] = []
    
    func fetchDrafts(for userID: String) async throws -> [Draft] {
        return drafts
    }
    
    func fetchDraftsForUsername(username: String) async throws -> [Draft] {
        return drafts
    }
    
    func deleteDraft(draftID: String) async throws {
        drafts.removeAll { $0.id == draftID }
    }
    
    func saveDraft(draft: Draft) async throws {
        drafts.append(draft)
    }
    
    func updateDraft(draftID: String, with fields: [AnyHashable : Any]) async throws {
        if let index = drafts.firstIndex(where: { $0.id == draftID }) {
            for (key, value) in fields {
                if let strKey = key as? String {
                    drafts[index].updateField(key: strKey, value: value)
                }
            }
        }
    }
    
    func searchUsers(prefix: String, limit: Int) async throws -> [OtherUser] {
        return []
    }
    
    func fetchPublishedDrafts(forUsername username: String) async throws -> [Draft] {
        return drafts.filter { $0.isPublished }
    }
    
    func getProfileImageURL(for userID: String) async -> String {
        return ""
    }
    
    func fetchExploreNotes() async throws -> [ExploreNote] {
        return ExploreNote.sampleNotes
    }
}

final class MockUserRepository: UserRepositoryProtocol {
    var profile: (username: String?, pin: String?) = ("@testuser", "1234")
    var profilePicture: (image: UIImage?, downloadURL: URL?) = (nil, nil)
    var savedPin: String? = nil
    var uploadedImage: UIImage? = nil
    var reloaded: Bool = false
    var profileExists: Bool = true
    var usernameAvailable: Bool = true
    var emailAvailable: Bool = true
    var currentUID: String? = "mock-uid-123"
    var currentUserEmail: String? = "mock@example.com"
    var updatedUsername: (old: String, new: String)? = nil
    var updatedAppearance: String? = nil

    func fetchUserProfile(uid: String) async throws -> (username: String?, pin: String?) {
        return profile
    }

    func fetchProfilePicture(uid: String) async throws -> (image: UIImage?, downloadURL: URL?) {
        return profilePicture
    }

    func uploadProfilePicture(uid: String, image: UIImage) async throws {
        uploadedImage = image
    }

    func deleteProfilePicture(uid: String) async throws {
        profilePicture = (nil, nil)
        uploadedImage = nil
    }

    func savePin(uid: String, pin: String) async throws {
        savedPin = pin
    }

    func reloadUser() async throws {
        reloaded = true
    }

    func doesProfileExist(uid: String) async throws -> Bool {
        return profileExists
    }

    func isUsernameAvailable(_ username: String) async throws -> Bool {
        return usernameAvailable
    }

    func isEmailAvailable(_ email: String) async throws -> Bool {
        return emailAvailable
    }

    func createProfile(uid: String, username: String, email: String) async throws {
        profile = (username, nil)
    }

    func updateUsername(uid: String, oldName: String, newName: String) async throws {
        updatedUsername = (oldName, newName)
        profile = (newName, profile.pin)
    }

    func updateEmail(to newEmail: String) async throws {
        currentUserEmail = newEmail
    }

    func updateAppearancePreference(uid: String, appearance: String) async throws {
        updatedAppearance = appearance
    }

    func deleteAccount(password: String?) async throws {
        profileExists = false
    }

    func fetchEmailForUsername(_ username: String) async throws -> String? {
        return currentUserEmail
    }
}

@Suite struct ValtTests {

    @Test @MainActor func testUserViewModelClearDataResetsAllState() async throws {
        let mockRepo = MockDraftRepository()
        let viewModel = UserViewModel(repository: mockRepo)
        
        // Mutate state to simulate an active user session
        let sampleDraft = Draft(
            id: "draft-1",
            userID: "user-123",
            title: "Test Note",
            content: "Hello world",
            timestamp: Date(),
            isFavorited: true,
            isHidden: true,
            isArchived: false,
            isPublished: true,
            prompt: "What inspired you?",
            isPrompted: true
        )
        viewModel.drafts = [sampleDraft]
        viewModel.username = "@testuser"
        viewModel.followerCount = 42
        viewModel.hasPinSet = true
        viewModel.isUnlocked = true
        viewModel.enteredPin = "1234"
        viewModel.newPin = "5678"
        viewModel.confirmNewPin = "5678"
        viewModel.shakeAttempts = 2
        viewModel.cardLoadingState = .error("Some error")
        viewModel.userLoadingState = .loading
        viewModel.profileLoadingState = .loading
        
        // Execute clearData
        viewModel.clearData()
        
        // Assert all properties are completely reset
        #expect(viewModel.drafts.isEmpty)
        #expect(viewModel.username == "@username")
        #expect(viewModel.followerCount == 0)
        #expect(viewModel.profileImage == nil)
        #expect(viewModel.profilePictureURL == nil)
        #expect(viewModel.hasPinSet == false)
        #expect(viewModel.isUnlocked == false)
        #expect(viewModel.enteredPin == "")
        #expect(viewModel.newPin == "")
        #expect(viewModel.confirmNewPin == "")
        #expect(viewModel.shakeAttempts == 0)
        #expect(viewModel.cardLoadingState == .complete)
        #expect(viewModel.userLoadingState == .complete)
        #expect(viewModel.profileLoadingState == .empty)
    }
    
    @Test func testDraftUpdateFieldWithIsPrompted() throws {
        var draft = Draft(
            id: "draft-1",
            userID: "user-1",
            title: "Initial Title",
            content: "Initial Content",
            timestamp: Date(),
            isFavorited: false,
            isHidden: false,
            isArchived: false,
            isPublished: false,
            prompt: nil,
            isPrompted: false
        )
        
        #expect(draft.isPrompted == false)
        
        draft.updateField(key: "isPrompted", value: true)
        #expect(draft.isPrompted == true)
        
        draft.updateField(key: "prompt", value: "New prompt question?")
        #expect(draft.prompt == "New prompt question?")
    }
    
    @Test func testUnauthenticatedErrorDetection() throws {
        let firestoreUnauth = NSError(
            domain: FirestoreErrorDomain,
            code: FirestoreErrorCode.unauthenticated.rawValue,
            userInfo: nil
        )
        #expect(firestoreUnauth.isUnauthenticatedError == true)
        
        let firestorePermDenied = NSError(
            domain: FirestoreErrorDomain,
            code: FirestoreErrorCode.permissionDenied.rawValue,
            userInfo: nil
        )
        #expect(firestorePermDenied.isUnauthenticatedError == true)
        
        let authUserNotFound = NSError(
            domain: AuthErrorDomain,
            code: AuthErrorCode.userNotFound.rawValue,
            userInfo: nil
        )
        #expect(authUserNotFound.isUnauthenticatedError == true)
        
        let genericError = NSError(
            domain: "CustomDomain",
            code: 500,
            userInfo: nil
        )
        #expect(genericError.isUnauthenticatedError == false)
    }
    
    @Test @MainActor func testUserViewModelWithMockRepositories() async throws {
        let mockDraftRepo = MockDraftRepository()
        let mockUserRepo = MockUserRepository()
        let viewModel = UserViewModel(repository: mockDraftRepo, userRepository: mockUserRepo)
        
        #expect(viewModel.username == "@username")
        #expect(viewModel.hasPinSet == false)
        #expect(viewModel.drafts.isEmpty)
    }
    
    @Test @MainActor func testSettingsViewModelWithMockRepository() async throws {
        let mockUserRepo = MockUserRepository()
        let settingsVM = SettingsViewModel(userRepository: mockUserRepo)
        
        settingsVM.checkUsernameAvailability(for: "uniqueName", currentUsername: "oldName")
        try await Task.sleep(nanoseconds: 600_000_000)
        #expect(settingsVM.usernameSelectionState == .valid)
        
        try await settingsVM.updateUsername(to: "brandNewName", oldName: "oldName")
        #expect(mockUserRepo.updatedUsername?.new == "brandNewName")
    }
}
