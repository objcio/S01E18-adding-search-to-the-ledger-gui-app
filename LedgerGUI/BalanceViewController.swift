//
//  Balance.swift
//  LedgerGUI
//
//  Created by Florian on 06/07/16.
//  Copyright © 2016 objc.io. All rights reserved.
//

import Cocoa

class BalanceViewController: NSViewController {
    lazy var dataSourceAndDelegate: OutlineDataSourceAndDelegate<BalanceTreeNode, BalanceCell> = OutlineDataSourceAndDelegate(configure: self.configureCell)

    var balanceTree: [BalanceTreeNode] = [] {
        didSet {
            guard balanceTree != oldValue else { return }
            dataSourceAndDelegate.rootItems = balanceTree
            outlineView?.reloadData() // TODO use a diff?
            outlineView?.expandItem(nil, expandChildren: true)
        }
    }

    @IBOutlet weak var outlineView: NSOutlineView? {
        didSet {
            dataSourceAndDelegate.configure = self.configureCell
            outlineView?.dataSource = dataSourceAndDelegate
            outlineView?.delegate = dataSourceAndDelegate
        }
    }

    func setDidSelect(_ didSelect: @escaping (_ account: String?) -> ()) {
        dataSourceAndDelegate.didSelect = { balanceTreeItem in
            didSelect(balanceTreeItem?.accountName)
        }
    }

    func configureCell(item: BalanceTreeNode, cell: BalanceCell) {
        cell.titleLabel.stringValue = item.title
        let (key, value) = item.amount.value.first! // TODO
        if item.amount.value.count > 1 {
            Swift.print("Cannot display multiple amounts yet...")
        }
        
        let amount = Amount(value, commodity: key)
        cell.amount.stringValue = amount.displayValue
        cell.amount.textColor = amount.color
    }
}

class BalanceCell: NSTableCellView {
    @IBOutlet weak var amount: NSTextField!
    @IBOutlet weak var titleLabel: NSTextField!
    
}

