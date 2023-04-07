//
//  MarsViewModel.swift
//  NASA RxSwift
//
//  Created by Aurelio Le Clarke on 07.04.2023.
//


import Foundation
import RxSwift

class APODService {
    private let baseUrl = "https://api.nasa.gov/planetary/apod"
    private let apiKey = "2wBQznMgCk3mSK3nXaY1g7igvmfWMxYi7mjt7XyW"
    private let urlSession = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    
    func fetchAPOD(for date: Date) -> Observable<APOD> {
        let url = URL(string: "\(baseUrl)?api_key=\(apiKey)&date=\(formattedDate(from: date))")!
        let request = URLRequest(url: url)
        return urlSession.rx.data(request: request)
            .map { [jsonDecoder] data in
                try jsonDecoder.decode(APOD.self, from: data)
            }
    }
    
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
}
