//
//  VideoFiltersToolView.swift
//  VideoEditorKit
//
//  Created by Codex on 29.06.2026.
//

import SwiftUI

struct VideoFiltersToolView: View {

    // MARK: - Public Properties

    let selectedFilter: VideoFilter
    /// Called whenever the user selects a filter swatch.
    ///
    /// The parent tool owns the draft state and immediately pushes the new value to
    /// `VideoPlayerManager`, so this view stays as a stateless picker.
    private let onSelectFilter: (VideoFilter) -> Void

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(VideoFilter.allCases) { filter in
                    filterButton(filter)
                }
            }
            .safeAreaPadding(.horizontal)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Initializer

    init(
        selectedFilter: VideoFilter,
        onSelectFilter: @escaping (VideoFilter) -> Void
    ) {
        self.selectedFilter = selectedFilter
        self.onSelectFilter = onSelectFilter
    }

    // MARK: - Private Methods

    private func filterButton(_ filter: VideoFilter) -> some View {
        let isSelected = selectedFilter == filter

        return Button {
            onSelectFilter(filter)
        } label: {
            VStack(spacing: 10) {
                // The swatch is an affordance only. Actual pixel processing happens
                // in the shared Core Image pipeline so preview and export remain identical.
                filterSwatch(filter)
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.white, Theme.accent)
                                .padding(6)
                        }
                    }

                Text(filter.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 88)
            .padding(8)
            .card(
                cornerRadius: 18,
                prominent: isSelected,
                tint: isSelected ? Theme.accent : Theme.secondary
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(filter.title)
    }

    private func filterSwatch(_ filter: VideoFilter) -> some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(filterSwatchFill(filter))
            .frame(width: 72, height: 72)
            .overlay {
                Image(systemName: filter.systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
            }
    }

    private func filterSwatchFill(_ filter: VideoFilter) -> LinearGradient {
        switch filter {
        case .none:
            // Neutral gray communicates that no Core Image filter will be applied.
            LinearGradient(
                colors: [.gray.opacity(0.45), .gray.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .vivid:
            LinearGradient(colors: [.pink, .orange, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .warm:
            LinearGradient(colors: [.orange, .yellow, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cool:
            LinearGradient(colors: [.cyan, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .chrome:
            LinearGradient(colors: [.purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .fade:
            LinearGradient(
                colors: [.mint.opacity(0.8), .gray.opacity(0.45)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mono:
            LinearGradient(colors: [.white, .gray, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .noir:
            LinearGradient(colors: [.black, .gray.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

}

#Preview {
    VideoFiltersToolView(selectedFilter: .vivid) { _ in }
        .preferredColorScheme(.dark)
}
