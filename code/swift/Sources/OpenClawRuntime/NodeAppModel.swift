import Foundation
import OpenClawKit

@MainActor
final class NodeAppModel {
    private let calendarService: any CalendarServicing
    private let remindersService: any RemindersServicing

    init(
        calendarService: any CalendarServicing = CalendarService(),
        remindersService: any RemindersServicing = RemindersService())
    {
        self.calendarService = calendarService
        self.remindersService = remindersService
    }

    func _test_handleInvoke(_ req: BridgeInvokeRequest) async -> BridgeInvokeResponse {
        do {
            return try await self.handleInvoke(req)
        } catch {
            return BridgeInvokeResponse(
                id: req.id,
                ok: false,
                error: OpenClawNodeError(
                    code: .invalidRequest,
                    message: "INVALID_REQUEST: \(error.localizedDescription)"))
        }
    }

    static func _test_decodeParams<P: Decodable>(_ type: P.Type, from raw: String?) throws -> P {
        try self.decodeParams(type, from: raw)
    }

    static func _test_encodePayload<P: Encodable>(_ payload: P) throws -> String {
        try self.encodePayload(payload)
    }

    private func handleInvoke(_ req: BridgeInvokeRequest) async throws -> BridgeInvokeResponse {
        switch req.command {
        case OpenClawCalendarCommand.events.rawValue,
             OpenClawCalendarCommand.add.rawValue,
             OpenClawCalendarCommand.update.rawValue:
            return try await self.handleCalendarInvoke(req)
        case OpenClawRemindersCommand.list.rawValue,
             OpenClawRemindersCommand.add.rawValue,
             OpenClawRemindersCommand.update.rawValue:
            return try await self.handleRemindersInvoke(req)
        default:
            return BridgeInvokeResponse(
                id: req.id,
                ok: false,
                error: OpenClawNodeError(code: .invalidRequest, message: "INVALID_REQUEST: unknown command"))
        }
    }

    private func handleCalendarInvoke(_ req: BridgeInvokeRequest) async throws -> BridgeInvokeResponse {
        switch req.command {
        case OpenClawCalendarCommand.events.rawValue:
            let params = (try? Self.decodeParams(OpenClawCalendarEventsParams.self, from: req.paramsJSON)) ??
                OpenClawCalendarEventsParams()
            let payload = try await self.calendarService.events(params: params)
            let json = try Self.encodePayload(payload)
            return BridgeInvokeResponse(id: req.id, ok: true, payloadJSON: json)
        case OpenClawCalendarCommand.add.rawValue:
            let params = try Self.decodeParams(OpenClawCalendarAddParams.self, from: req.paramsJSON)
            let payload = try await self.calendarService.add(params: params)
            let json = try Self.encodePayload(payload)
            return BridgeInvokeResponse(id: req.id, ok: true, payloadJSON: json)
        case OpenClawCalendarCommand.update.rawValue:
            let params = try Self.decodeParams(OpenClawCalendarUpdateParams.self, from: req.paramsJSON)
            let payload = try await self.calendarService.update(params: params)
            let json = try Self.encodePayload(payload)
            return BridgeInvokeResponse(id: req.id, ok: true, payloadJSON: json)
        default:
            return BridgeInvokeResponse(
                id: req.id,
                ok: false,
                error: OpenClawNodeError(code: .invalidRequest, message: "INVALID_REQUEST: unknown command"))
        }
    }

    private func handleRemindersInvoke(_ req: BridgeInvokeRequest) async throws -> BridgeInvokeResponse {
        switch req.command {
        case OpenClawRemindersCommand.list.rawValue:
            let params = (try? Self.decodeParams(OpenClawRemindersListParams.self, from: req.paramsJSON)) ??
                OpenClawRemindersListParams()
            let payload = try await self.remindersService.list(params: params)
            let json = try Self.encodePayload(payload)
            return BridgeInvokeResponse(id: req.id, ok: true, payloadJSON: json)
        case OpenClawRemindersCommand.add.rawValue:
            let params = try Self.decodeParams(OpenClawRemindersAddParams.self, from: req.paramsJSON)
            let payload = try await self.remindersService.add(params: params)
            let json = try Self.encodePayload(payload)
            return BridgeInvokeResponse(id: req.id, ok: true, payloadJSON: json)
        case OpenClawRemindersCommand.update.rawValue:
            let params = try Self.decodeParams(OpenClawRemindersUpdateParams.self, from: req.paramsJSON)
            let payload = try await self.remindersService.update(params: params)
            let json = try Self.encodePayload(payload)
            return BridgeInvokeResponse(id: req.id, ok: true, payloadJSON: json)
        default:
            return BridgeInvokeResponse(
                id: req.id,
                ok: false,
                error: OpenClawNodeError(code: .invalidRequest, message: "INVALID_REQUEST: unknown command"))
        }
    }

    private static func decodeParams<P: Decodable>(_ type: P.Type, from raw: String?) throws -> P {
        guard let raw, let data = raw.data(using: .utf8) else {
            throw NSError(domain: "NodeAppModel", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "paramsJSON required",
            ])
        }
        return try JSONDecoder().decode(type, from: data)
    }

    private static func encodePayload<P: Encodable>(_ payload: P) throws -> String {
        let data = try JSONEncoder().encode(payload)
        guard let json = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "NodeAppModel", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "failed to encode payload",
            ])
        }
        return json
    }
}
