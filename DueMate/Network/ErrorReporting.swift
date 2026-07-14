//
//  ErrorReporting.swift
//  DueMate
//
//  Created by Codex on 3/2/26.
//

import Foundation

@MainActor
protocol ErrorReporting {}

extension ErrorReporting {
    func reportError(_ error: Error) async {
        await ErrorHandler.shared.handle(error)
    }
}
