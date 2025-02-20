//
//  User.swift
//  CountriesSwiftUI
//
//  Created by Osamu Sakamoto on 2025/02/22.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//
import SwiftData

enum Gender: Int, CaseIterable, Codable {
    case unknown = 0
    case male = 1
    case female = 2
    case unspecified = 3
}

@Model final class User : DBModel2 {
    var name: String
    var age: Int?
    var gender: Gender = Gender.unknown
    init(name: String, age: Int? = nil, gender: Gender = .unknown) {
        self.name = name
        self.age = age
        self.gender = gender
    }
}

class Trackers {
    static let user:FW.MutableModelStateTracker<User> = {FWImpl.MainModelStateTracker<User>()}()
}
