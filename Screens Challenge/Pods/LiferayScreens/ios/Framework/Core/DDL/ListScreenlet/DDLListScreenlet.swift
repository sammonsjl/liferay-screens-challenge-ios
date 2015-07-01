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


@objc public protocol DDLListScreenletDelegate {

	optional func screenlet(screenlet: DDLListScreenlet,
			onDDLListResponseRecords records: [DDLRecord])

	optional func screenlet(screenlet: DDLListScreenlet,
			onDDLListError error: NSError)

	optional func screenlet(screenlet: DDLListScreenlet,
			onDDLSelectedRecord record: DDLRecord)

}


@IBDesignable public class DDLListScreenlet: BaseListScreenlet {

	@IBInspectable public var userId: Int64 = 0
	@IBInspectable public var recordSetId: Int64 = 0

	@IBInspectable public var labelFields: String? {
		didSet {
			(screenletView as? DDLListViewModel)?.labelFields = parseFields(labelFields)
		}
	}

	@IBOutlet public weak var delegate: DDLListScreenletDelegate?

	public var viewModel: DDLListViewModel {
		return screenletView as! DDLListViewModel
	}


	//MARK: BaseListScreenlet

	override public func onCreated() {
		super.onCreated()

		viewModel.labelFields = parseFields(self.labelFields)
	}

	override internal func createPageLoadInteractor(
			#page: Int,
			computeRowCount: Bool)
			-> BaseListPageLoadInteractor {

		return DDLListPageLoadInteractor(
				screenlet: self,
				page: page,
				computeRowCount: computeRowCount,
				userId: self.userId,
				recordSetId: self.recordSetId)
	}

	override internal func onLoadPageError(#page: Int, error: NSError) {
		super.onLoadPageError(page: page, error: error)

		delegate?.screenlet?(self, onDDLListError: error)
	}

	override internal func onLoadPageResult(#page: Int, rows: [AnyObject], rowCount: Int) {
		super.onLoadPageResult(page: page, rows: rows, rowCount: rowCount)

		delegate?.screenlet?(self,
				onDDLListResponseRecords: rows as! [DDLRecord])
	}

	override internal func onSelectedRow(row: AnyObject) {
		delegate?.screenlet?(self,
				onDDLSelectedRecord: row as! DDLRecord)
	}


	//MARK: Private methods

	private func parseFields(fields: String?) -> [String] {
		var result: [String] = []

		if let fieldsValue = fields {
			let dirtyFields = (fieldsValue as NSString).componentsSeparatedByString(",")
			result = dirtyFields.map() {
				$0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
			}
			result = result.filter() { return $0 != "" }
		}

		return result
	}

}
