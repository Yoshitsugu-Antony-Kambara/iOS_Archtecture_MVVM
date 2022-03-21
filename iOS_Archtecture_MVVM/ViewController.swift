//
//  ViewController.swift
//  iOS_Archtecture_MVVM
//
//  Created by 神原良継 on 2022/03/22.
//
/**
 ViewControllerの責務
 ・ユーザの入力をViewModelに伝搬する
 ・自身の状態とViewModelの状態をデータバインディングする
 ・ViewModelから返されるイベントを元に描画処理を実行する
 **/


import UIKit
import RxSwift

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet private weak var idTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var validationLabel: UILabel!
    
    private lazy var viewModel = ViewModel(
        //idTextFieldとpasswordTextFieldにObservableを渡す(イベント流す)
        idTextObservable: idTextField.rx.text.asObservable(),
        passwordTextObservable: passwordTextField.rx.text.asObservable(),
        model: Model()
    )
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ここでviewModelのvalidationTextとViewControllerのvalidationLabelをバインディングしてる
        //このバインディングによって、validationTextが変更されるのに同期して、validationLabelの文字列も変更される
        viewModel.validationText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        //ここでViewModelのloadLabelColorとViewControllerのloadLabelColorをバインディングしてる
        viewModel.loadLabelColor
            .bind(to: loadLabelColor)
            .disposed(by: disposeBag)

    }
    
    //色の更新処理をBinder化
    //idTextObservableとpassowrdTextObservableからViewModelにイベントを伝搬し、ViewModel内のプレゼンテーションロジックで生じる色の更新をきっかけに更新される。
    private var loadLabelColor: Binder<UIColor> {
        return Binder(self) { me, color in
            me.validationLabel.textColor = color
        }
    }
}

