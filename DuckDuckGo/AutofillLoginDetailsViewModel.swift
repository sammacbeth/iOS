//
//  AutofillLoginDetailsViewModel.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import BrowserServicesKit
import SwiftUI
import Core

protocol AutofillLoginDetailsViewModelDelegate: AnyObject {
    func autofillLoginDetailsViewModelDidSave()
}

final class AutofillLoginDetailsViewModel: ObservableObject {
    enum ViewMode {
        case edit
        case view
        case new
    }
    
    enum PasteboardCopyAction {
        case username
        case password
        case address
    }
    
    weak var delegate: AutofillLoginDetailsViewModelDelegate?
    var account: SecureVaultModels.WebsiteAccount?
    
    @ObservedObject var headerViewModel: AutofillLoginDetailsHeaderViewModel
    @Published var isPasswordHidden = true
    @Published var username = ""
    @Published var password = ""
    @Published var address = ""
    @Published var title = ""
    @Published var selectedCell: UUID?
    @Published var viewMode: ViewMode = .view {
        didSet {
            selectedCell = nil
        }
    }
    
    private var passwordData: Data {
        password.data(using: .utf8)!
    }
    
    var navigationTitle: String {
        switch viewMode {
        case .edit:
            return UserText.autofillLoginDetailsEditTitle
        case .view:
            return UserText.autofillLoginDetailsDefaultTitle
        case .new:
            return UserText.autofillLoginDetailsNewTitle
        }
    }
    
    var shouldShowSaveButton: Bool {
        guard viewMode == .new else { return false }
        
        return !username.isEmpty || !password.isEmpty || !address.isEmpty || !title.isEmpty
    }
    
    var userVisiblePassword: String {
        let passwordHider = PasswordHider(password: password)
        return isPasswordHidden ? passwordHider.hiddenPassword : passwordHider.password
    }

    internal init(account: SecureVaultModels.WebsiteAccount? = nil) {
        self.account = account
        self.headerViewModel = AutofillLoginDetailsHeaderViewModel()
        if let account = account {
            self.updateData(with: account)
        } else {
            viewMode = .new
        }
    }
    
    private func updateData(with account: SecureVaultModels.WebsiteAccount) {
        self.account = account
        username = account.username
        address = account.domain
        title = account.name
        headerViewModel.updateData(with: account)
        setupPassword(with: account)
    }
    
    func toggleEditMode() {
        withAnimation {
            if viewMode == .edit {
                viewMode = .view
            } else {
                viewMode = .edit
            }
        }
    }
    
    func copyToPasteboard(_ action: PasteboardCopyAction) {
        var message = ""
        switch action {
        case .username:
            message = UserText.autofillCopyToastUsernameCopied
            UIPasteboard.general.string = username
        case .password:
            message = UserText.autofillCopyToastPasswordCopied
            UIPasteboard.general.string = password
        case .address:
            message = UserText.autofillCopyToastAddressCopied
            UIPasteboard.general.string = address
        }
        
        presentCopyConfirmation(message: message)
    }
    
    private func presentCopyConfirmation(message: String) {
        DispatchQueue.main.async {
            ActionMessageView.present(message: message,
                                      actionTitle: "",
                                      onAction: {})
        }
    }
    
    private func setupPassword(with account: SecureVaultModels.WebsiteAccount) {
        do {
            if let accountID = account.id {
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                
                if let credential = try
                    vault.websiteCredentialsFor(accountId: accountID) {
                    self.password = String(data: credential.password, encoding: .utf8) ?? ""
                }
            }
        } catch {
            Pixel.fire(pixel: .secureVaultError)
        }
    }

    func save() {
        do {
            switch viewMode {
            case .edit:
                guard let accountID = account?.id else {
                    assertionFailure("Trying to save edited account, but the account doesn't exist")
                    return
                }
                
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                
                if var credential = try vault.websiteCredentialsFor(accountId: accountID) {
                    credential.account.username = username
                    credential.account.title = title
                    credential.account.domain = address
                    credential.password = passwordData
                    
                    try vault.storeWebsiteCredentials(credential)
                    delegate?.autofillLoginDetailsViewModelDidSave()
                    
                    // Refetch after save to get updated properties like "lastUpdated"
                    if let newCredential = try vault.websiteCredentialsFor(accountId: accountID) {
                        self.updateData(with: newCredential.account)
                    }
                    
                    viewMode = .view
                }
            case .view:
                break
            case .new:
                let vault = try SecureVaultFactory.default.makeVault(errorReporter: SecureVaultErrorReporter.shared)
                
                let account = SecureVaultModels.WebsiteAccount(title: title, username: username, domain: address)
                let credentials = SecureVaultModels.WebsiteCredentials(account: account, password: passwordData)

                let id = try vault.storeWebsiteCredentials(credentials)
                
                delegate?.autofillLoginDetailsViewModelDidSave()
                
                // Refetch after save to get updated properties like "lastUpdated"
                if let newCredential = try vault.websiteCredentialsFor(accountId: id) {
                    self.updateData(with: newCredential.account)
                }
                
                viewMode = .view
            }
        } catch {
            Pixel.fire(pixel: .secureVaultError)
        }
    }
}

final class AutofillLoginDetailsHeaderViewModel: ObservableObject {
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var domain: String = ""
    
    func updateData(with account: SecureVaultModels.WebsiteAccount) {
        self.title = account.name
        self.subtitle = UserText.autofillLoginDetailsLastUpdated(for: (dateFormatter.string(from: account.lastUpdated)))
        self.domain = account.domain
    }

}
