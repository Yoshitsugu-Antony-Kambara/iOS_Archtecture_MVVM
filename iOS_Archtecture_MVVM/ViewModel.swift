//
//  ViewModel.swift
//  iOS_Archtecture_MVVM
//
//  Created by 神原良継 on 2022/03/22.
//
/**
 ViewModelの責務
 ・Viewに表示するためのデータを保持する（今回はデータの保持はしない。するときは、BehaviorRelay使うとか？）
 ・Viewからイベントを受け取り、Modelの処理を呼び出す
 ・Viewからイベントを受け取り、加工して値を更新する
 **/


import UIKit
import RxSwift
import RxCocoa
import Combine

final class ViewModel {
    let validationText: Observable<String>
    let loadLabelColor: Observable<UIColor>
    
    //textFieldの文字列の入力・変更イベントに同期して、Modelのvalidate(idText:,passwordText:)を呼び出すよう関連付け
    init(idTextObservable: Observable<String?>,
         passwordTextObservable: Observable<String?>,
         model: ModelProtocol) {
        let event = Observable
            .combineLatest(idTextObservable, passwordTextObservable)
            .skip(1)
            .flatMap { idText, passwordText -> Observable<Event<Void>> in
                return model
                    .validate(idText: idText, passwordText: passwordText)
                    //onNext, onError,onCompleteのイベントをObservable<Event<Void>>に変換してそれぞれ別のストリームとして扱えるようにしてる
                    .materialize()
            }
            .share()    //Hotにして、一つの入力に対してこれ以降のObservableがそれぞれ独立したストリームとしてデータ更新を行えるようにしてる←この結果をeventで保持しておいて、以降の処理で利用する。
        
        self.validationText = event
            .flatMap { event -> Observable<String> in
                switch event {
                case .next:
                    return .just("OK!!!")
                case let .error(error as ModelError):
                    return .just(error.errorText)
                case .error, .completed:
                    return .empty()
                }
            }
            .startWith("IDとPasswordを入力してください")
        
        self.loadLabelColor = event
            .flatMap { event -> Observable<UIColor> in
                switch event {
                case .next:
                    return .just(.green)
                case .error:
                    return .just(.red)
                case .completed:
                    return .empty()
                }
            }
    }
}

extension ModelError {
    fileprivate var errorText: String {
        switch self {
        case .invalidIdAndPassword:
            return "IDとPasswordが未入力です"
        case .invalidId:
            return "IDが未入力です"
        case .invalidPassword:
            return "Passowrdが未入力です"
        }
    }
}
