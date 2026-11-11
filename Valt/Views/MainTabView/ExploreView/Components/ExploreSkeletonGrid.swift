import SwiftUI

struct ExploreSkeletonGrid: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    skeletonTallCard
                    
                    VStack(spacing: 12) {
                        skeletonCompactCard
                        skeletonCompactCard
                    }
                    .frame(maxWidth: .infinity)
                }
                
                skeletonSpotlightCard
                
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 12) {
                        skeletonCompactCard
                        skeletonCompactCard
                    }
                    .frame(maxWidth: .infinity)
                    
                    skeletonTallCard
                }
                
                skeletonSpotlightCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .allowsHitTesting(false)
    }
    
    private var skeletonTallCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TextFieldBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("TextColor").opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                    .frame(maxWidth: 100)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                    .frame(maxWidth: 90)
                
                Spacer()
                
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 50, height: 12)
                    Spacer()
                }
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .shimmer()
        .redacted(reason: .placeholder)
    }
    
    private var skeletonCompactCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TextFieldBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("TextColor").opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                    .frame(maxWidth: 80)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                
                Spacer()
            }
            .padding(10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 124)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .shimmer()
        .redacted(reason: .placeholder)
    }
    
    private var skeletonSpotlightCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("TextFieldBackground"))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("TextColor").opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 80, height: 14)
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 50, height: 14)
                }
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                    .frame(maxWidth: 220)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 14)
                
                Spacer()
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 155)
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        .shimmer()
        .redacted(reason: .placeholder)
    }
}

#Preview {
    ExploreSkeletonGrid()
        .background(Color("AppBackgroundColor"))
}
