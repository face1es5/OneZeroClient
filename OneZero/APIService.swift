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
    
    func postVideo(for videoData: Data, name filename: String, completion: @escaping (Result<String, Error>) -> Void) async {
        guard let url = URL(string: addr) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        
        // boundary
        let boundary = "__\(UUID().uuidString)__"
        req.setValue("multipart/form-data; charset=utf-8; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //set body
        var body = Data()
        let mimeType = "video/mp4"
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"video\"; filename=\"\(filename)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n")
        body.append("\r\n")
        body.append(videoData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        req.httpBody = body
        
        //send
        URLSession.shared.dataTask(with: req) { data, response, error in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("error", error ?? URLError(.badServerResponse))
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("Status code should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                completion(.failure(APIError.invalidResponseCode(response.statusCode)))
                return
            }
            
            guard let resMessage = String(data: data, encoding: .utf8) else {
                completion(.failure(APIError.corruptData))
                return
            }
            
            completion(.success(resMessage))
            
        }.resume()
        
    }
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponseStatus
    case invalidResponseCode(Int)
    case dataTaskError(String)
    case corruptData
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Request URL is invalid.", comment: "")
        case .invalidResponseStatus:
            return NSLocalizedString("Invalid response or response code.", comment: "")
        case .invalidResponseCode(let code):
            return NSLocalizedString("Invalid response code: \(code)", comment: "")
        case .dataTaskError(let string):
            return string
        case .corruptData:
            return NSLocalizedString("Received data appears to be corrput.", comment: "")
        case .decodingError(let string):
            return string
        }
    }
}

/**
 Extends Data to support append string directly(automately encode string into utf8).
 */

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
