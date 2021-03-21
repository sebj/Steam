//
//  Publisher+Sink.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

import Combine

extension Publisher {
    func sink() -> AnyCancellable {
        sink { _ in } receiveValue: { _ in }
    }
}
