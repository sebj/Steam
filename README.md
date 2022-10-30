# 💨 Steam

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsebj%2Fsteam%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/sebj/steam)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fsebj%2Fsteam%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/sebj/steam)
[![MIT License](https://img.shields.io/github/license/sebj/steam?color=lightgray)](LICENSE)
[![Build & Test](https://github.com/sebj/steam/workflows/Build%20and%20Test/badge.svg)](https://github.com/sebj/steam/actions/workflows/build-and-test.yaml)

A Swift package to directly interact with [Steam](https://store.steampowered.com).

* Login to a Steam account (via password or 2FA code)
* Retrieve basic user info
    * Steam identifier
    * Account flags
    * Steam Community vanity profile URL
    * Friends list Steam identifiers & friend status
* Add/remove friends

## Installation

### Swift Package Manager (Xcode):
1. From the **File** menu, select **Add Packages…**
2. Enter "https://github.com/sebj/steam" into the package repository URL text field

### Swift Package Manager (standalone):

Add the following to the `dependencies` of your `Package.swift` file:

`.package(url: "https://github.com/sebj/Steam.git", ...)`

## Usage

1. Choose a server from `SteamServer.defaultServers` or fetch the latest Steam server list using `SteamServersFetcher`.
2. Instantiate a `SteamService` and connect to the chosen server (`connect`).
3. `login`
4. Receive user information and friends list, and use any functions that require user authentication (`addFriend`, `removeFriend` etc) as desired.

## Protobufs

Several Steam Protobufs from [SteamDatabase/Protobufs](https://github.com/SteamDatabase/Protobufs) and their converted Swift models (via [Swift Protobuf](https://github.com/apple/swift-protobuf)) are bundled with this library, as Swift packages do not currently support running scripts/custom build phase actions (which would ideally be used to clone the Protobufs repo, convert and copy the relevant files).

## License

This library is released under the MIT license. See the [LICENSE](LICENSE) file for more information.

## Related Libraries

* [Philipp15b/go-steam](https://github.com/Philipp15b/go-steam)
* [seishun/node-steam](https://github.com/seishun/node-steam)
* [ValvePython/steam](https://github.com/ValvePython/steam)
