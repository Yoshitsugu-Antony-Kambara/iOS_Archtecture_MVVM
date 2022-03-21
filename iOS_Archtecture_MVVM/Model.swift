//
//  Model.swift
//  iOS_Archtecture_MVVM
//
//  Created by 神原良継 on 2022/03/22.
//
/**
 Modelの責務
 ・protocol化して疎結合に、テスタブルにする
 ・Observableを返却して、ViewModelとの建て付けをよくする
 **/


import Foundation
import RxCocoa
import RxSwift

enum ModelError: Error {
    case invalidId
    case invalidPassword
    case invalidIdAndPassword
}

/**
 ViewModelからはModelに直接依存するのではなく、Modelのprotocolに依存するようにしておくと、DIができるようになる。
 疎結合になってテスタブルにもなる
 ViewModelにModelを外部から注入できるようにすることで、ModelをTextBoudbleと置き換えて、特定の入力のみを返すようにできる。←テストしやすくなる
 **/
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
