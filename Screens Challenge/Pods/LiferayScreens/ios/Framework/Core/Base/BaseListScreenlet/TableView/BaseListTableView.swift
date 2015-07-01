/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/
import UIKit

#if LIFERAY_SCREENS_FRAMEWORK
	import ODRefreshControl
#endif


public class BaseListTableView: BaseListView, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet public var tableView: UITableView?

	internal var refreshControlView: ODRefreshControl?

	internal var refreshClosure: (Void -> Bool)? {
		didSet {
			updateRefreshControl()
		}
	}

	private let cellId = "listCell"


	// MARK: BaseListView

	public override func onCreated() {
		super.onCreated()

		doRegisterCellNib(id: cellId)
	}

	override public func onChangedRows(oldRows: [AnyObject?]) {
		super.onChangedRows(oldRows)

		if oldRows.isEmpty {
			insertFreshRows()
		}
		else if self.rows.isEmpty {
			clearAllRows(oldRows)
		}
		else if let visibleRows = tableView!.indexPathsForVisibleRows() {
			updateVisibleRows(visibleRows)
		}
		else {
			tableView!.reloadData()
		}
	}

	override public func onFinishOperation() {
		if let currentRefreshControl = refreshControlView {
			delayed(0.3) {
				currentRefreshControl.endRefreshing()
			}
		}
	}


	//MARK: UITableViewDataSource

	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return rowCount
	}

	public func tableView(tableView: UITableView,
			cellForRowAtIndexPath
			indexPath: NSIndexPath)
			-> UITableViewCell {

		let cell = doDequeueReusableCell(row: indexPath.row)

		if let row:AnyObject = rows[indexPath.row] {
			doFillLoadedCell(row: indexPath.row, cell: cell, object: row)
		}
		else {
			doFillInProgressCell(row: indexPath.row, cell: cell)

			fetchPageForRow?(indexPath.row)
		}

		return cell
	}

	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: false)

		if let row:AnyObject = rows[indexPath.row] {
			onSelectedRowClosure?(row)
		}
	}

	public func doDequeueReusableCell(#row: Int) -> UITableViewCell {
		var result = tableView!.dequeueReusableCellWithIdentifier("listCell") as? UITableViewCell

		if result == nil {
			result = UITableViewCell(style: .Default, reuseIdentifier: "listCell")
		}

		return result!
	}

	public func doFillLoadedCell(#row: Int, cell: UITableViewCell, object:AnyObject) {
	}

	public func doFillInProgressCell(#row: Int, cell: UITableViewCell) {
	}

	public func doRegisterCellNib(#id: String) {
	}


	//MARK: Internal methods

	internal func updateRefreshControl() {
		if let closureValue = refreshClosure {
			if refreshControlView == nil {
				refreshControlView = ODRefreshControl(inScrollView: self.tableView)
				refreshControlView!.addTarget(self,
						action: "refreshControlBeginRefresh:",
						forControlEvents: UIControlEvents.ValueChanged)
			}
		}
		else if let currentControl = refreshControlView {
			currentControl.endRefreshing()
			currentControl.removeFromSuperview()
			refreshControlView = nil
		}
	}

	internal func refreshControlBeginRefresh(sender:AnyObject?) {
		delayed(0.3) {
			self.refreshClosure?()
			return
		}
	}

	internal func insertFreshRows() {
		let indexPaths = (0..<self.rows.count).map {
			NSIndexPath(forRow: $0, inSection: 0)
		}

		tableView!.insertRowsAtIndexPaths(indexPaths, withRowAnimation:.Top)
	}

	internal func clearAllRows(currentRows: [AnyObject?]) {
		tableView!.beginUpdates()

		for (index,_) in enumerate(currentRows) {
			let indexPath = NSIndexPath(forRow:index, inSection:0)
			tableView!.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		}

		tableView!.endUpdates()
	}

	internal func updateVisibleRows(visibleRows: [AnyObject]) {
		if visibleRows.count > 0 {
			tableView!.reloadRowsAtIndexPaths(visibleRows, withRowAnimation:.None)
		}
		else {
			tableView!.reloadData()
		}
	}

}
