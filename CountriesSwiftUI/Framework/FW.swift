//
//  Base.swift
//
//  Created by Osamu Sakamoto on 2025/02/20.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//

import Foundation
import os

/// namespace for framework classes
public enum FW {
}

/// namespace for famework implementation classes
///  These classes are intended to use in initialization for DI
public enum FWImpl {
}

extension FWImpl {
    /// logger used in FW. this method is internal to FW
    static let logger = {Logger(subsystem: Bundle.main.bundleIdentifier ?? "jp.yopper.swift-ui-architecture", category: "FW")}()
}

