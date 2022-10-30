import Combine
import Foundation

public enum SteamUIMode: UInt32 {
    case desktop
    case bigPicture
    case mobile
    case web
}

public extension SteamService {
    
    /// Set the logged in user's UI mode.
    /// This is typically shown as a small icon next to their name in the Steam friends list (phone, controller, etc.)
    func setUIMode(_ uiMode: SteamUIMode)  -> AnyPublisher<Void, SendError> {
        guard case .encrypted = encryption else {
            return Fail(error: SendError.unencryptedConnection).eraseToAnyPublisher()
        }
        
        var request = CMsgClientUIMode()
        request.uimode = uiMode.rawValue
        
        let payload: Data
        do {
            payload = try request.serializedData()
        } catch {
            return Fail(error: SendError.failedToEncode(error)).eraseToAnyPublisher()
        }
        
        let message = ProtobufMessage(
            header: .init(messageType: .kEmsgClientCurrentUimode),
            payload: payload
        )
        
        return send(message)
    }
}
