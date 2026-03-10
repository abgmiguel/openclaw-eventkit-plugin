import Foundation

public struct BridgeInvokeRequest: Codable, Sendable {
    public let type: String
    public let id: String
    public let command: String
    public let paramsJSON: String?

    public init(type: String = "invoke", id: String, command: String, paramsJSON: String? = nil) {
        self.type = type
        self.id = id
        self.command = command
        self.paramsJSON = paramsJSON
    }
}

public struct BridgeInvokeResponse: Codable, Sendable {
    public let type: String
    public let id: String
    public let ok: Bool
    public let payloadJSON: String?
    public let error: OpenClawNodeError?

    public init(
        type: String = "invoke-res",
        id: String,
        ok: Bool,
        payloadJSON: String? = nil,
        error: OpenClawNodeError? = nil)
    {
        self.type = type
        self.id = id
        self.ok = ok
        self.payloadJSON = payloadJSON
        self.error = error
    }
}
