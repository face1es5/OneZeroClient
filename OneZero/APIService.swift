//
//  APIService.swift
//  OneZero
//
//  Created by Fish on 14/8/2024.
//

import Foundation

class APIService {
    let addr: String
    init(to urlString: String) {
        addr = urlString
    }

    func getJSON<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) async throws -> T {
        guard let url = URL(string: addr) else { throw APIError.invalidURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200 ... 299) ~= httpResponse.statusCode
            else { throw APIError.invalidResponseStatus }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw APIError.decodingError(error.localizedDescription)
            }
        } catch {
            throw APIError.dataTaskError(error.localizedDescription)
        }
    }

    func rawJSON() async throws -> Any {
        guard let url = URL(string: addr) else { throw APIError.invalidURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200 ... 299) ~= httpResponse.statusCode
            else { throw APIError.invalidResponseStatus }
            return try JSONSerialization.jsonObject(with: data)
        } catch {
            throw APIError.dataTaskError(error.localizedDescription)
        }
    }

    func postVideo(for videoData: Data, name filename: String) async -> Result<String, Error> {
        guard let url = URL(string: addr) else {
            return .failure(APIError.invalidURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        // boundary
        let boundary = "__\(UUID().uuidString)__"
        req.setValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // set body
        var body = Data()
        let mimeType = "video/mp4"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"video\"; filename*=UTF-8''\(filename.urlEncode())\r\n")
        body.append("Content-Type: \(mimeType)\r\n")
        body.append("\r\n")
        body.append(videoData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")

        req.httpBody = body

        // send
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299) ~= httpResponse.statusCode
            else {
                return .failure(APIError.invalidResponseCode((response as? HTTPURLResponse)?.statusCode ?? 500))
            }
            guard let resMessage = String(data: data, encoding: .utf8) else {
                return .failure(APIError.corruptData)
            }
            return .success(resMessage)
        } catch let urlError as URLError {
            return .failure(APIError.urlError(urlError.localizedDescription))
        } catch {
            return .failure(error)
        }
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus
    case invalidResponseCode(Int)
    case urlError(String)
    case dataTaskError(String)
    case corruptData
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Request URL is invalid.", comment: "")
        case .invalidResponseStatus:
            return NSLocalizedString("Invalid response or response code.", comment: "")
        case let .invalidResponseCode(code):
            return NSLocalizedString("Invalid response code", comment: "") + " - \(code)."
        case let .dataTaskError(string):
            return string
        case .corruptData:
            return NSLocalizedString("Received data appears to be corrput.", comment: "")
        case let .decodingError(string):
            return string
        case let .urlError(string):
            return string
        }
    }
}
