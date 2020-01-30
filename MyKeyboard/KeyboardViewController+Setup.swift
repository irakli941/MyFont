//
//  KeyboardViewController+Setup.swift
//  KeyboardKitDemoKeyboard
//
//  Created by Daniel Saidi on 2019-10-15.
//  Copyright © 2018 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import UIKit

extension KeyboardViewController {
    
    func setupKeyboard() {
        setupKeyboard(for: view.bounds.size)
    }
    
    func setupKeyboard(for size: CGSize) {
        DispatchQueue.main.async {
            self.setupKeyboardAsync(for: size)
        }
    }
    
    func setupKeyboardAsync(for size: CGSize) {
        
        KeyboardManager.sharedInstance.currentKeyboard = keyboardType
        keyboardStackView.removeAllArrangedSubviews()
        switch keyboardType {
        case .alphabetic(let uppercased):
            setupAlphabeticKeyboard(uppercased: uppercased, index: KeyboardManager.sharedInstance.currentIndex)
        case .alpabetic(let uppercased, let index):
            KeyboardManager.sharedInstance.currentIndex = index
            setupAlphabeticKeyboard(uppercased: uppercased, index: index)
        case .numeric: setupNumericKeyboard()
        case .symbolic: setupSymbolicKeyboard()
        case .settings:
            allKeyboardsView()
            return
        default: return
        }
        addFontToolbar(index: KeyboardManager.sharedInstance.currentIndex)
    }
    
    func setupAlphabeticKeyboard(uppercased: Bool = false, index: Int) {

        if FontKeyboard.ViewModel.keyboards[index].characters[1].count == 0 {
            setupEmojiKeyboard(index: index)
            return
        }
        AlphabeticKeyboard.characters = FontKeyboard.ViewModel.keyboards[index].characters
        if let upperCasedFont = FontKeyboard.ViewModel.keyboards[index].upperCharacters {
            AlphabeticKeyboard.upperCasedCharacters = upperCasedFont
        } else {
            AlphabeticKeyboard.upperCasedCharacters = []
        }
        

        let keyboard = AlphabeticKeyboard(uppercased: uppercased, in: self)
        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
        keyboardStackView.addArrangedSubviews(rows)
    }
    
    private func setupEmojiKeyboard(index: Int) {
        var keyboard = EmojiKeyboard(in: self)
        keyboard.actions = []
        let isLandscape = view.frame.width > 400
        let rowsPerPage = isLandscape ? 4 : 3
        let buttonsPerRow = isLandscape ? 5 : 4
        for i in stride(from: 0, to: FontKeyboard.ViewModel.keyboards[index].characters[0].count, by: 1) {
            let char = KeyboardAction.character(FontKeyboard.ViewModel.keyboards[1].characters[0][i])
            keyboard.actions.append(char)
        }
        let config = KeyboardButtonRowCollectionView.Configuration(rowHeight: 40, rowsPerPage: rowsPerPage, buttonsPerRow: buttonsPerRow)
        let view = KeyboardButtonRowCollectionView(actions: keyboard.actions, configuration: config) { [unowned self] in return self.button(for: $0) }
        let bottom = buttonRow(for: keyboard.bottomActions, distribution: .fillProportionally)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        keyboardStackView.addArrangedSubview(view)
        keyboardStackView.addArrangedSubview(bottom)
    }
    
    private func allKeyboardsView() {
        var keyboard = EmojiKeyboard(in: self)
        keyboard.actions = []
        let isLandscape = view.frame.width > 400
        let rowsPerPage = isLandscape ? 4 : 4
        let buttonsPerRow = isLandscape ? 5 : 4
        for i in stride(from: 0, to: FontKeyboard.ViewModel.keyboards.count, by: 1) {
            let kb = KeyboardAction.switchToKeyboard(.alpabetic(uppercased: false, index: i))
            keyboard.actions.append(kb)
        }
        
        if !isLatestPhone() {
            keyboard.actions.insert(KeyboardAction.switchKeyboard, at: 0)
        }
        
        let config = KeyboardButtonRowCollectionView.Configuration(rowHeight: 40, rowsPerPage: rowsPerPage, buttonsPerRow: buttonsPerRow)
        let view = KeyboardButtonRowCollectionView(actions: keyboard.actions, configuration: config) { [unowned self] in return self.button(for: $0) }
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        keyboardStackView.addArrangedSubview(view)
        
    }
    
    private func addFontToolbar(index: Int) {
        var fontsToAdd: [KeyboardAction] = []
        let settingsKeyboard = KeyboardAction.switchToKeyboard(.settings)
        for i in stride(from: 0, to: FontKeyboard.ViewModel.keyboards.count, by: 1) {
            let keyBoard = KeyboardAction.switchToKeyboard(.alpabetic(uppercased: false, index: i))
            fontsToAdd.append(keyBoard)
        }
        fontsToAdd.insert(settingsKeyboard, at: 0)
        fontsToAdd.insert(KeyboardAction.switchKeyboard, at: 0)
        let rowsPerPage = 2
        let buttonsPerRow = 4
        let config = KeyboardButtonRowCollectionView.Configuration(rowHeight: 40, rowsPerPage: rowsPerPage, buttonsPerRow: buttonsPerRow)
        let view = KeyboardButtonRowCollectionView(actions: fontsToAdd, configuration: config) { [unowned self] in return self.button(for: $0) }
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        keyboardStackView.insertArrangedSubview(view, at: 0)
//        view.scrollToItem(at: IndexPath(row: index, section: 0), at: .right, animated: false)
    }
    
    func setupNumericKeyboard() {
        let keyboard = NumericKeyboard(in: self)
        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
        keyboardStackView.addArrangedSubviews(rows)
    }
    
    func setupSymbolicKeyboard() {
        let keyboard = SymbolicKeyboard(in: self)
        let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
        keyboardStackView.addArrangedSubviews(rows)
    }
}
