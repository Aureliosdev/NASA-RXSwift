//
//  ViewController.swift
//  NASA RxSwift
//
//  Created by Aurelio Le Clarke on 07.04.2023.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
class ViewController: UIViewController {
    
    var apodList: [APOD] = []
    private let disposeBag = DisposeBag()
    private let apodViewModel = APODViewModel(apodService: APODService())
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        DispatchQueue.global(qos: .utility).async {
             self.preloadImages(with: self.apodList)
         }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(explanationLabel)
        view.addSubview(imageView)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 9.0/16.0),
            
            explanationLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            explanationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            explanationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            explanationLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func bindUI() {
        apodViewModel.fetchAPOD()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] apod in
                self?.updateUI(with: apod)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateUI(with apod: APOD) {
        titleLabel.text = apod.title
        explanationLabel.text = apod.explanation
        let imageObservable = URLSession.shared.rx.data(request: URLRequest(url: apod.hdurl))
            .map { UIImage(data: $0) }
            .observeOn(MainScheduler.asyncInstance)
            .catchErrorJustReturn(nil)
        imageObservable.bind(to: imageView.rx.image).disposed(by: disposeBag)
    }
    
    @objc private func datePickerValueChanged() {
        apodViewModel.setDate(datePicker.date)
    }
    func preloadImages(with apodList: [APOD]) {
        for apod in apodList {
            guard let imageUrl = URL(string: apod.hdurl.absoluteString) else { continue }
            KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.cacheOriginalImage]) { result in
                switch result {
                case .success(let imageResult):
                    print("Image loaded: \(imageResult.image)")
                case .failure(let error):
                    print("Image load error: \(error)")
                }
            }
        }
    }
}
