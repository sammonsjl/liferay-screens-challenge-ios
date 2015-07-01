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


public class SaveUserInteractor: ServerOperationInteractor {

	public var resultUserAttributes: [String:AnyObject]?

	override public func createOperation() -> LiferayUpdateCurrentUserOperation {
		return LiferayUpdateCurrentUserOperation(screenlet: self.screenlet)
	}

	override public func completedOperation(op: ServerOperation) {
		self.resultUserAttributes = (op as! LiferayUpdateCurrentUserOperation).resultUserAttributes
	}

}
