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


class SessionStorage {

	typealias LoadResult = (session: LRSession, userAttributes: [String:AnyObject])

	private let credentialStore: CredentialsStore

	init(credentialStore: CredentialsStore) {
		self.credentialStore = credentialStore
	}

	init?() {
		let authType = BaseCredentialsStoreKeyChain.storedAuthType()

		if let authType = authType {
			switch authType {
			case .Basic:
				credentialStore = BasicCredentialsStoreKeyChain()
			case .OAuth:
				credentialStore = OAuthCredentialsStoreKeyChain()
			}
		}
		else {
			// Workaround for "All stored properties of a class instance
			// must be initialized before returning nil from an initializer
			credentialStore = BasicCredentialsStoreKeyChain()

			return nil
		}
	}

	func store(#session: LRSession?, userAttributes: [String:AnyObject]) -> Bool {
		if session == nil || userAttributes.isEmpty {
			return false
		}

		return credentialStore.storeCredentials(session,
				userAttributes: userAttributes)
	}

	func remove() -> Bool {
		return credentialStore.removeStoredCredentials()
	}

	func load() -> LoadResult? {
		if credentialStore.loadStoredCredentials() {
			if let loadedAuth = credentialStore.authentication,
					loadedUserAttributes = credentialStore.userAttributes {

				let loadedSession = LRSession(
						server: LiferayServerContext.server,
						authentication: loadedAuth)

				return (loadedSession, loadedUserAttributes)
			}
		}

		return nil
	}

}
