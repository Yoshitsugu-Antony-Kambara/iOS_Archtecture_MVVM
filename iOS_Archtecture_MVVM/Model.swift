//
//  Model.swift
//  iOS_Archtecture_MVVM
//
//  Created by 神原良継 on 2022/03/22.
//

import Foundation
import RxCocoa
import RxSwift

enum ModelError: Error {
    case invalidId
    case invalidPassword
    case invalidIdAndPassword
}

protocol ModelProtocol {
    func validate(idText: String?, passwordText: String?) -> Observable<Void>
}

final class Model: ModelProtocol {
    func validate(idText: String?, passwordText: String?) -> Observable<Void> {
        switch (idText, passwordText) {
        case (.none, .none):
            return Observable.error(ModelError.invalidIdAndPassword)
        case (.none, .some):
            return Observable.error(ModelError.invalidId)
        case (.some, .none):
            return Observable.error(ModelError.invalidPassword)
        case (let idText?, let passwordText?):
            switch (idText.isEmpty, passwordText.isEmpty) {
            case (true, true):
                return Observable.error(ModelError.invalidIdAndPassword)
            case (false, false):
                return Observable.just(())
            case (false, true):
                return Observable.error(ModelError.invalidPassword)
            case (true, false):
                return Observable.error(ModelError.invalidId)
            }
        }
    }
}
