//
//  YoutubeApiHelper.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 16/4/2025.
//

import Foundation

struct YoutubeVideo: Codable {
    let title: String
    let thumbnailURL: URL
    let videoId: String
    let duration: String
    let videoURL: String
}

struct YoutubeApiHelper {
    static let apiKey = "AIzaSyDLqac41Ko1J_V0sY0jRMzrN3NU-6gfG44"
    static let baseURL = "https://www.googleapis.com/youtube/v3"

    static func fetchTrendingFoodVideos(maxResults: Int = 5) async throws -> [YoutubeVideo] {
        // Step 1: Search for food videos
        let searchURL = "\(baseURL)/search?part=snippet&q=food&videoDuration=long&maxResults=\(maxResults)&type=video&key=\(apiKey)"
        let (searchData, _) = try await URLSession.shared.data(from: URL(string: searchURL)!)
        let searchResult = try JSONDecoder().decode(SearchResponse.self, from: searchData)

        let videoIds = searchResult.items.map { $0.id.videoId }.joined(separator: ",")

        // Step 2: Get video details
        let detailURL = "\(baseURL)/videos?part=snippet,contentDetails&id=\(videoIds)&key=\(apiKey)"
        let (detailData, _) = try await URLSession.shared.data(from: URL(string: detailURL)!)
        let detailResult = try JSONDecoder().decode(VideoDetailResponse.self, from: detailData)

        return detailResult.items.map {
            YoutubeVideo(
                title: $0.snippet.title,
                thumbnailURL: URL(string: $0.snippet.thumbnails.medium.url)!,
                videoId: $0.id,
                duration: $0.contentDetails.duration,
                videoURL: "https://www.youtube.com/watch?v=\($0.id)"
            )
        }
    }
}

// MARK: - API Response Models

struct SearchResponse: Codable {
    let items: [SearchItem]
}

struct SearchItem: Codable {
    let id: SearchId
}

struct SearchId: Codable {
    let videoId: String
}

struct VideoDetailResponse: Codable {
    let items: [VideoDetail]
}

struct VideoDetail: Codable {
    let id: String
    let snippet: VideoSnippet
    let contentDetails: VideoContentDetails
}

struct VideoSnippet: Codable {
    let title: String
    let thumbnails: ThumbnailContainer
}

struct ThumbnailContainer: Codable {
    let medium: Thumbnail
}

struct Thumbnail: Codable {
    let url: String
}

struct VideoContentDetails: Codable {
    let duration: String
}
