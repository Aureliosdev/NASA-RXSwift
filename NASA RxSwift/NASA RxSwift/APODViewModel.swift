//
//  MarsPhotosAPI.swift
//  NASA RxSwift
//
//  Created by Aurelio Le Clarke on 07.04.2023.
//


import Foundation
import RxSwift

class APODViewModel {
    private let apodService: APODService
    private let date = BehaviorSubject<Date>(value: Date())
    
    init(apodService: APODService) {
        self.apodService = apodService
    }
    
    func fetchAPOD() -> Observable<APOD> {
        return date.asObservable().flatMap { [apodService] date in
            apodService.fetchAPOD(for: date)
        }
    }
    
    func setDate(_ date: Date) {
        self.date.onNext(date)
    }
}

