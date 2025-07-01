import Foundation

protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var parameters: [String: String]? { get }
    
    func makeRequest() throws -> URLRequest
}

struct MLSStatsEndpoint: APIEndpoint {
    let baseURL = "https://gist.githubusercontent.com"
    let path: String
    let method = "GET"
    let headers: [String: String]? = ["Accept": "application/json"]
    let parameters: [String: String]? = nil
    
    static func teamStats() -> Self {
        MLSStatsEndpoint(
            path: "/dnTeixeira/b317ed413ca9dc17ddf01d307b923376/raw/1ab5fc269c0dcecbef5afbf31d25eca634a64bcb/mls_data.json"
        )
    }
    
    func makeRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        components.path = path
        components.queryItems = parameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        
        return request
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid server response"
        case .serverError(let code): return "Server error (code: \(code))"
        case .decodingError(let error): return "Decoding error: \(error.localizedDescription)"
        }
    }
}
