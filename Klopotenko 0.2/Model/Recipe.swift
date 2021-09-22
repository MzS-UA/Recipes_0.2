//
//  Recipe.swift
//  Klopotenko 0.2
//
//  Created by Михайло Дяків on 11.08.2021.
//

import Foundation
import UIKit

struct Recipe {
    public let titleRecipe: String
    public let imageRecipe: String
    public let shortText: String
    public let category: String
    public let date: String
    public let fullText: String
    public let vegan: Bool
    public let featured: Bool
    public let unicID: String
}

struct Indredient {
    public let title: String
    public let quanity: Int
    public var checked: Bool
    }

struct SumIndredient {
    public let title: String
    public let quanity: Int
    }

struct MySettings {
    public let name: String
    public var check: Bool
}
