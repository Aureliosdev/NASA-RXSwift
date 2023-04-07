//
//  MarsPhoto.swift
//  NASA RxSwift
//
//  Created by Aurelio Le Clarke on 07.04.2023.
//

import Foundation

struct APOD: Codable {
    let title: String
    let explanation: String
    let date: String
    let url: URL
    let hdurl: URL
}
