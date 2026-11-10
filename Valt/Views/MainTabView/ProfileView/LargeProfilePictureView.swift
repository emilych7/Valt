import SwiftUI
import PhotosUI

@MainActor
struct LargeProfilePictureView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var bannerManager: BannerManager
    @EnvironmentObject var tabManager: TabManager
    let profileImage: UIImage?
    
    @State private var isPhotoPickerPresented: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageToCrop: UIImage? = nil
    @State private var showCropView: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var appearProgress: CGFloat = 0.0
    @State private var isDismissing: Bool = false
    @State private var dragTranslation: CGSize = .zero
    
    private var displayedImage: UIImage? {
        userViewModel.profileImage ?? profileImage
    }
    
    private var profileURL: URL {
        URL(string: "https://valt.app/@\(userViewModel.username)") ?? URL(string: "https://valt.app")!
    }
    
    private var dragDistance: CGFloat {
        hypot(dragTranslation.width, dragTranslation.height)
    }
    
    private var dragScale: CGFloat {
        let reduction: CGFloat = dragDistance / 700.0
        return max(0.75, 1.0 - reduction)
    }
    
    private var backdropOpacity: Double {
        let reduction: Double = Double(dragDistance) / 450.0
        return max(0.25, 1.0 - reduction)
    }
    
    private var buttonsOpacity: Double {
        let reduction: Double = Double(dragDistance) / 80.0
        return max(0.0, 1.0 - reduction)
    }
    
    private var currentAvatarScale: CGFloat {
        let baseScale: CGFloat = 0.85 + (0.15 * appearProgress)
        return baseScale * dragScale
    }
    
    private var currentBackdropOpacity: Double {
        Double(appearProgress) * backdropOpacity
    }
    
    private var currentButtonsOpacity: Double {
        Double(appearProgress) * buttonsOpacity
    }
    
    private var currentButtonsYOffset: CGFloat {
        (1.0 - appearProgress) * 20.0
    }
    
    var body: some View {
        ZStack {
            enlargedProfileContent
            
            if showCropView, let image = imageToCrop {
                ProfilePhotoCropView(
                    inputImage: image,
                    onCrop: { croppedImage in
                        Task { @MainActor in
                            await userViewModel.uploadProfilePicture(croppedImage)
                            bannerManager.show("Updated Profile Picture", backgroundColor: Color("RequestButtonColor"), icon: "checkmarkIcon")
                        }
                        withAnimation(.easeOut(duration: 0.2)) {
                            showCropView = false
                            imageToCrop = nil
                            selectedItem = nil
                        }
                    },
                    onCancel: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showCropView = false
                            imageToCrop = nil
                            selectedItem = nil
                        }
                    }
                )
                .transition(.opacity)
                .zIndex(200)
            }
        }
        .photosPicker(
            isPresented: $isPhotoPickerPresented,
            selection: $selectedItem,
            matching: .images
        )
        .onChange(of: selectedItem) { _, newValue in
            handleUploadSelectedImage(newValue)
        }
        .alert("Delete Profile Picture?", isPresented: $showDeleteConfirmation) {
            Button("No", role: .cancel) { }
            Button("Yes", role: .destructive) {
                handleDeleteProfilePicture()
            }
        } message: {
            Text("Are you sure you want to delete your profile picture?")
        }
        .onAppear {
            tabManager.setTabBarHidden(true)
            var transaction = Transaction()
            transaction.animation = .easeOut(duration: 0.22)
            withTransaction(transaction) {
                appearProgress = 1.0
            }
        }
        .onDisappear {
            tabManager.setTabBarHidden(false)
        }
    }
    
    private var enlargedProfileContent: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay(Color.black.opacity(0.45))
                .ignoresSafeArea()
                .opacity(currentBackdropOpacity)
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            VStack(spacing: 0) {
                Spacer(minLength: 40)
                
                avatarContainer
                    .scaleEffect(currentAvatarScale)
                    .opacity(appearProgress)
                    .offset(dragTranslation)
                
                Spacer(minLength: 40)
                
                bottomActionsRow
                    .opacity(currentButtonsOpacity)
                    .offset(y: currentButtonsYOffset)
                    .padding(.bottom, 36)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .gesture(
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    guard !isDismissing else { return }
                    dragTranslation = value.translation
                }
                .onEnded { value in
                    guard !isDismissing else { return }
                    let distance = hypot(value.translation.width, value.translation.height)
                    let predictedDistance = hypot(value.predictedEndTranslation.width, value.predictedEndTranslation.height)
                    
                    if distance > 60 || predictedDistance > 120 {
                        dismissWithAnimation(velocityTranslation: value.predictedEndTranslation)
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            dragTranslation = .zero
                        }
                    }
                }
        )
    }
    
    private var avatarContainer: some View {
        ZStack {
            if let image = displayedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 270, height: 270)
                    .clipShape(Circle())
            } else {
                placeholderView
            }
            
            if displayedImage != nil {
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    showDeleteConfirmation = true
                } label: {
                    Circle()
                        .fill(Color("ValtRed"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.35), lineWidth: 2)
                        )
                        .overlay(
                            Image("exitIcon")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                        )
                }
                .offset(x: 92, y: 92)
            }
        }
    }
    
    private var placeholderView: some View {
        Circle()
            .fill(Color("BubbleColor"))
            .frame(width: 270, height: 270)
            .overlay(
                Image(systemName: "camera.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color("TextColor"))
            )
    }
    
    private var bottomActionsRow: some View {
        HStack(spacing: 38) {
            ShareLink(
                item: profileURL,
                subject: Text("Valt Profile"),
                message: Text("Check out @\(userViewModel.username) on Valt!")
            ) {
                actionButtonContent(icon: "person.crop.circle", title: "Share")
            }
            
            Button {
                copyProfileLink()
            } label: {
                actionButtonContent(icon: "link", title: "Copy link")
            }
            
            Button {
                triggerEditPhoto()
            } label: {
                actionButtonContent(icon: "pencil", title: "Edit photo")
            }
        }
    }
    
    private func actionButtonContent(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Circle()
                .foregroundColor(Color("AppBackgroundColor"))
                .frame(width: 62, height: 62)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(Color("TextColor"))
                )
            
            Text(title)
                .font(.custom("OpenSans-Regular", size: 13))
                .foregroundColor(.white)
        }
    }
    
    private func handleUploadSelectedImage(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task { @MainActor in
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            imageToCrop = uiImage
            withAnimation(.easeInOut(duration: 0.25)) {
                showCropView = true
            }
        }
    }
    
    private func copyProfileLink() {
        UIPasteboard.general.string = profileURL.absoluteString
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        bannerManager.show("Link Copied to Clipboard", backgroundColor: Color("RequestButtonColor"), icon: "checkmarkIcon")
    }
    
    private func triggerEditPhoto() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isPhotoPickerPresented = true
    }
    
    private func handleDeleteProfilePicture() {
        dismissWithAnimation()
        Task { @MainActor in
            await userViewModel.deleteProfilePicture()
            bannerManager.show("Profile Picture Removed", backgroundColor: Color("ValtRed"), icon: "trashIcon")
        }
    }
    
    private func dismissWithAnimation(velocityTranslation: CGSize = .zero) {
        guard !isDismissing else { return }
        isDismissing = true
        
        var transaction = Transaction()
        transaction.animation = .easeOut(duration: 0.18)
        withTransaction(transaction) {
            appearProgress = 0.0
            if velocityTranslation != .zero {
                dragTranslation = CGSize(
                    width: velocityTranslation.width * 1.25,
                    height: velocityTranslation.height * 1.25
                )
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            var dismissTransaction = Transaction()
            dismissTransaction.disablesAnimations = true
            withTransaction(dismissTransaction) {
                dismiss()
            }
        }
    }
}

@MainActor
struct ProfilePhotoCropView: View {
    @Environment(\.dismiss) var dismiss
    let inputImage: UIImage
    var onCrop: (UIImage) -> Void
    var onCancel: (() -> Void)? = nil
    
    private let cropDiameter: CGFloat = 280
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var isInteracting: Bool = false
    @State private var imageDisplaySize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("AppBackgroundColor")
                    .ignoresSafeArea()
                
                imageLayer(screenSize: geometry.size)
                
                CircularCutoutMask(diameter: cropDiameter)
                    .fill(style: FillStyle(eoFill: true))
                    .foregroundColor(Color.black.opacity(0.65))
                    .allowsHitTesting(false)
                
                circleBorderAndGrid
                    .allowsHitTesting(false)
                
                VStack(spacing: 0) {
                    topNavigationBar
                        .padding(.top, max(geometry.safeAreaInsets.top, 60))
                    
                    Spacer()
                    
                    bottomHint
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            setupInitialImageFit()
        }
    }
    
    private func imageLayer(screenSize: CGSize) -> some View {
        Image(uiImage: inputImage)
            .resizable()
            .scaledToFit()
            .frame(width: imageDisplaySize.width, height: imageDisplaySize.height)
            .scaleEffect(scale)
            .offset(offset)
            .position(x: screenSize.width / 2.0, y: screenSize.height / 2.0)
            .gesture(
                SimultaneousGesture(
                    magnificationGesture,
                    dragGesture
                )
            )
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                isInteracting = true
                let newScale = lastScale * value
                scale = max(0.85, min(4.0, newScale))
            }
            .onEnded { value in
                isInteracting = false
                let finalScale = max(1.0, min(3.5, lastScale * value))
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    scale = finalScale
                    lastScale = finalScale
                    offset = clampOffset(offset, forScale: finalScale)
                    lastOffset = offset
                }
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isInteracting = true
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { value in
                isInteracting = false
                lastOffset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    offset = clampOffset(lastOffset, forScale: scale)
                    lastOffset = offset
                }
            }
    }
    
    private var circleBorderAndGrid: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.85), lineWidth: 1.5)
                .frame(width: cropDiameter, height: cropDiameter)
            
            ZStack {
                HStack {
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1)
                    Spacer()
                }
                VStack {
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                    Spacer()
                    Rectangle().fill(Color.white.opacity(0.3)).frame(height: 1)
                    Spacer()
                }
            }
            .frame(width: cropDiameter, height: cropDiameter)
            .clipShape(Circle())
            .opacity(isInteracting ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.2), value: isInteracting)
        }
    }
    
    private var topNavigationBar: some View {
        HStack {
            Button {
                if let onCancel = onCancel {
                    onCancel()
                } else {
                    dismiss()
                }
            } label: {
                Image("exitIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Text("Move and Scale")
                .font(.custom("OpenSans-SemiBold", size: 17))
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                handleCropAndComplete()
            } label: {
                Image("checkmarkIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
    }
    
    private var bottomHint: some View {
        Text("Drag to reposition · Pinch to zoom")
            .font(.custom("OpenSans-Regular", size: 13))
            .foregroundColor(Color.white.opacity(0.7))
            .padding(.bottom, 24)
    }
    
    private func setupInitialImageFit() {
        let imgW = inputImage.size.width
        let imgH = inputImage.size.height
        guard imgW > 0, imgH > 0 else { return }
        
        let aspect = imgW / imgH
        if aspect > 1.0 {
            imageDisplaySize = CGSize(width: cropDiameter * aspect, height: cropDiameter)
        } else {
            imageDisplaySize = CGSize(width: cropDiameter, height: cropDiameter / aspect)
        }
        
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }
    
    private func clampOffset(_ targetOffset: CGSize, forScale currentScale: CGFloat) -> CGSize {
        let renderedW = imageDisplaySize.width * currentScale
        let renderedH = imageDisplaySize.height * currentScale
        
        let maxX = max(0, (renderedW - cropDiameter) / 2.0)
        let maxY = max(0, (renderedH - cropDiameter) / 2.0)
        
        let clampedX = min(max(targetOffset.width, -maxX), maxX)
        let clampedY = min(max(targetOffset.height, -maxY), maxY)
        
        return CGSize(width: clampedX, height: clampedY)
    }
    
    private func handleCropAndComplete() {
        if let cropped = cropImage() {
            onCrop(cropped)
            if onCancel == nil {
                dismiss()
            }
        }
    }
    
    private func cropImage() -> UIImage? {
        let normalized = normalizeOrientation(inputImage)
        let renderedW = imageDisplaySize.width * scale
        let renderedH = imageDisplaySize.height * scale
        guard renderedW > 0, renderedH > 0 else { return nil }
        
        let scaleToPixels = normalized.size.width / renderedW
        let cropSizePixels = cropDiameter * scaleToPixels
        
        let cropX = ((renderedW - cropDiameter) / 2.0 - offset.width) * scaleToPixels
        let cropY = ((renderedH - cropDiameter) / 2.0 - offset.height) * scaleToPixels
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropSizePixels, height: cropSizePixels)
        
        let outputSize = CGSize(width: 600, height: 600)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        
        return renderer.image { _ in
            let drawWidth = normalized.size.width * (outputSize.width / cropRect.width)
            let drawHeight = normalized.size.height * (outputSize.height / cropRect.height)
            let drawX = -cropRect.origin.x * (outputSize.width / cropRect.width)
            let drawY = -cropRect.origin.y * (outputSize.height / cropRect.height)
            
            let drawRect = CGRect(x: drawX, y: drawY, width: drawWidth, height: drawHeight)
            normalized.draw(in: drawRect)
        }
    }
    
    private func normalizeOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}

struct CircularCutoutMask: Shape {
    let diameter: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let circleRect = CGRect(
            x: center.x - diameter / 2.0,
            y: center.y - diameter / 2.0,
            width: diameter,
            height: diameter
        )
        path.addEllipse(in: circleRect)
        return path
    }
}

#Preview("With Image") {
    LargeProfilePictureView(
        profileImage: UIImage(systemName: "person.crop.circle.fill")
    )
    .environmentObject(UserViewModel.preview)
    .environmentObject(BannerManager())
    .environmentObject(TabManager())
}

#Preview("Empty State") {
    LargeProfilePictureView(
        profileImage: nil
    )
    .environmentObject(UserViewModel.previewEmpty)
    .environmentObject(BannerManager())
    .environmentObject(TabManager())
}
