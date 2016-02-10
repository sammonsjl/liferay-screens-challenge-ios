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
	import LRMobileSDK
	import KeychainAccess
#endif


public class BasicCredentialsStoreKeyChain : BaseCredentialsStoreKeyChain {

	override public func storeAuth(#keychain: Keychain, auth: LRAuthentication) {
		let basicAuth = auth as! LRBasicAuthentication

		keychain.set(AuthType.Basic.rawValue, key: "auth_type")
		keychain.set(basicAuth.username, key: "basicauth_username")
		keychain.set(basicAuth.password, key: "basicauth_password")
	}

	override public func loadAuth(#keychain: Keychain) -> LRAuthentication? {
		let username = keychain.get("basicauth_username")
		let password = keychain.get("basicauth_password")

		if let username = username,
				password = password {

			return LRBasicAuthentication(
					username: username,
					password: password)
		}

		return nil
	}

}
