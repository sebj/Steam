//
//  UserState.swift
//
//  Copyright © 2020-2021 Sebastian Jachec. All rights reserved.
//

// Also known as Persona State
enum UserState: UInt32 {
    case offline = 0
    case online = 1
    case busy = 2
    case away = 3
    case snooze = 4
    case lookingToTrade = 5
    case lookingToPlay = 6
    case max = 7
}
