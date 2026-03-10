import EventKit

enum EventKitAuthorization {
    struct Access: Sendable, Equatable {
        let read: Bool
        let write: Bool
    }

    static func access(status: EKAuthorizationStatus) -> Access {
        switch status {
        case .authorized, .fullAccess:
            return Access(read: true, write: true)
        case .writeOnly:
            return Access(read: false, write: true)
        case .notDetermined:
            // Don’t prompt during node.invoke; prompts block the invoke and lead to timeouts.
            return Access(read: false, write: false)
        case .restricted, .denied:
            return Access(read: false, write: false)
        @unknown default:
            return Access(read: false, write: false)
        }
    }

    static func allowsRead(status: EKAuthorizationStatus) -> Bool {
        self.access(status: status).read
    }

    static func allowsWrite(status: EKAuthorizationStatus) -> Bool {
        self.access(status: status).write
    }
}
