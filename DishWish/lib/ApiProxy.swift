//
//  ApiProxy.swift
//  DishWish
//
//  Created by Choi Siu Lun Alan on 16/4/2025.
//

import Foundation




struct RecipeRequestModel: Encodable {
    let ingredients: [String]
    let mealType: String?
    let maxTime: Int?
    let cuisine: String?
    let diet: String?
    let allergens: String?
    let number: Int?
}

class APIProxy {
    static let shared = APIProxy()
    private let baseURL = URL(string: "https://proxy.siulun1.com")!  // Your actual proxy domain

    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }

    func post<T: Encodable>(
        path: String,
        body: T,
        headers: [String: String] = [:],
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let data = data else {
                return completion(.failure(NSError(domain: "EmptyResponse", code: 0)))
            }
            completion(.success(data))
        }.resume()
    }

    func get(
        path: String,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems

        guard let url = components.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let data = data else {
                return completion(.failure(NSError(domain: "EmptyResponse", code: 0)))
            }
            completion(.success(data))
        }.resume()
    }

    // Predict endpoint
    func predict(base64Image: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let body = ["image_base64": base64Image]
        post(path: "predict", body: body, headers: [:], completion: completion)
    }

    // Spoonacular recipes
    func fetchRecipes(request: RecipeRequestModel, completion: @escaping (Result<Data, Error>) -> Void) {
        post(path: "spoonacular/recipes", body: request, headers: [:], completion: completion)
    }

    // Nutritionix NLP
    func fetchNutritionInfo(query: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let body = ["query": query]
        post(path: "nutritionix/nlp", body: body, headers: [:], completion: completion)
    }

    // Nutritionix Auto-complete
    func autoCompleteFood(expression: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let items = [URLQueryItem(name: "expression", value: expression)]
        get(path: "nutritionix/auto_complete", queryItems: items, headers: [:], completion: completion)
    }
}
