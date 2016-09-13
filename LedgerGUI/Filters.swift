//
//  Filters.swift
//  LedgerGUI
//
//  Created by Florian Kugler on 01/09/16.
//  Copyright © 2016 objc.io. All rights reserved.
//

import Foundation


extension EvaluatedTransaction {
    func matches(account: String?) -> Bool {
        guard let account = account else { return true }
        return matches(Filter.account(account))
    }

    func matches(string: String?) -> Bool {
        guard let string = string else { return true }
        return matches(Filter.string(string))
    }

    func matches(_ search: [Filter]) -> Bool {
        return search.all(matches)
    }
    
    func matches(_ search: Filter) -> Bool {
        switch search {
        case .account:
            return postings.first { $0.matches(search) } != nil
        case .string(let string):
            return title.lowercased().contains(string.lowercased()) || postings.first { $0.matches(search) } != nil
        case .year(let year):
            return date.year == year
        }
    }
}

extension EvaluatedPosting {
    func matches(_ search: String) -> Bool {
        return matches(Filter.string(search))
    }
    
    func matches(_ search: [Filter]) -> Bool {
        return search.all(matches)
    }
    
    func matches(_ search: Filter) -> Bool {
        switch search {
        case .account(let name):
            return account.hasPrefix(name)
        case .string(let string):
            return account.lowercased().contains(string.lowercased()) || amount.displayValue.contains(string)
        case .year:
            return false
        }
    }
}

