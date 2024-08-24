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
        guard let url = URL(string: addr.urlEncode()) else { throw APIError.invalidURL }
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

    /// Post media data server.
    func postMediaData(for mediaData: Data, name filename: String, extension suffix: String) async -> Result<String, Error> {
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
        let mimeType = MediaFactory.mimeType(suffix)
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"media\"; filename*=UTF-8''\(filename.urlEncode())\r\n")
        body.append("Content-Type: \(mimeType)\r\n")
        body.append("\r\n")
        body.append(mediaData)
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
    
    /// Post serialized json data of object.
    func postJson<T: Encodable>(_ object: T) async -> Result<String, Error> {
        guard let url = URL(string: addr) else { return .failure(APIError.invalidURL) }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        guard
            let body = try? JSONEncoder().encode(object)
        else {
            return .failure(APIError.encondingError("Encode type of \(type(of: object)) failed."))
        }
        req.httpBody = body
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299) ~= httpResponse.statusCode
            else {
                return .failure(APIError.invalidResponseCode((response as? HTTPURLResponse)?.statusCode ?? 500))
            }
            guard let message = String(data: data, encoding: .utf8) else {
                return .failure(APIError.corruptData)
            }
            return .success(message)
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
    case encondingError(String)

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
        case let .encondingError(string):
            return string
        }
    }
}
