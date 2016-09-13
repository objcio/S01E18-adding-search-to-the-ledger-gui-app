//
//  LedgerDocumentController.swift
//  LedgerGUI
//
//  Created by Florian Kugler on 01/09/16.
//  Copyright © 2016 objc.io. All rights reserved.
//

import Cocoa

enum Filter {
    case account(String)
    case string(String)
    case year(Int)
}

extension Filter {
    static func parse(_ string: String) -> [Filter] {
        return (try? parser.run(input: ImmutableCharacters(string: string))) ?? [.string(string)]
    }
}

private let year: GenericParser<ImmutableCharacters, (), Filter> = { .year($0) } <^> natural
private let string: GenericParser<ImmutableCharacters, (), Filter> = { .string(String($0)) } <^> noSpace.many1
private let parser: GenericParser<ImmutableCharacters, (), [Filter]> = (year <|> string).separatedBy(spaceWithoutNewline.many1) <* FastParser.eof

struct DocumentState {
    var ledger: Ledger = Ledger()
    var accountFilter: String?
    var searchQuery: String?
    private var filters: [Filter] {
        return Filter.parse(searchQuery ?? "")
    }
    
    var filteredTransactions: [EvaluatedTransaction] {
        return ledger.evaluatedTransactions.filter { transaction in
            return transaction.matches(account: accountFilter) && transaction.matches(filters)
        }
    }
}

final class LedgerDocumentController {
    var documentState = DocumentState() {
        didSet {
            update()
        }
    }
    
    var windowController: LedgerWindowController? {
        didSet {
            windowController?.balanceViewController?.setDidSelect { account in
                self.documentState.accountFilter = account
            }
            windowController?.didSearch = { search in
                self.documentState.searchQuery = search.isEmpty ? nil : search
            }
            update()
        }
    }
    
    func update() {
        DispatchQueue.main.async {
            self.windowController?.balanceViewController?.balanceTree = self.ledger.balanceTree
            self.windowController?.registerViewController?.transactions = self.documentState.filteredTransactions
        }
    }
    
    var ledger: Ledger {
        get { return documentState.ledger }
        set { documentState.ledger = newValue }
    }
}


