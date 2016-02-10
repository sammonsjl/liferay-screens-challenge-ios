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
import LROAuth


class OAuthInteractor: Interactor, LRCallback {

	var resultUserAttributes: [String:AnyObject]?

	let consumerKey: String
	let consumerSecret: String

	var webViewController: OAuthWebViewController?

	var OAuthConfig: LROAuthConfig?
	var OAuthSession: LRSession?

	init(screenlet: BaseScreenlet,
			consumerKey: String,
			consumerSecret: String) {

		self.consumerKey = consumerKey
		self.consumerSecret = consumerSecret

		super.init(screenlet: screenlet)
	}

	override func start() -> Bool {
		if screenlet.presentingViewController == nil {
			println("ERROR: You need to set the presentingViewController before start OAuthInteractor")

			return false
		}

		OAuthConfig = LROAuthConfig(
			server: LiferayServerContext.server,
			consumerKey: consumerKey,
			consumerSecret: consumerSecret,
			callbackURL: "screens://oauth_callback")

		return requestToken()
	}

	private func requestToken() -> Bool {
		LRRequestToken.requestTokenWithConfig(
				OAuthConfig,
				onSuccess: {
					if let URL = NSURL(string: $0.authorizeTokenURL) {
						self.showWebView(URL)
					}
					else {
						println("ERROR: OAuth's authorizeTokenURL is not valid: \($0.authorizeTokenURL)")
						let err = NSError.errorWithCause(.InvalidServerResponse)
						self.onFailure?(err)
					}
				},
				onFailure: { err in
					println("ERROR: Cannot get request token")
					self.onFailure?(err)
				}
		)

		return true
	}

	private func showWebView(URL: NSURL) {
		webViewController = OAuthWebViewController(
				URL: URL,
				themeName: screenlet.themeName ?? "default")

		webViewController!.onAuthorized = { [weak webViewController] OAuthVerifier in
			webViewController?.dismissViewControllerAnimated(true, completion: nil)

			self.OAuthConfig?.verifier = OAuthVerifier

			self.requestAccessToken()
		}

		if let vc = screenlet.presentingViewController {
			vc.presentViewController(webViewController!, animated: true, completion: nil)
		}
	}

	private func requestAccessToken() {
		LRAccessToken.accessTokenWithConfig(
				OAuthConfig,
				onSuccess: { config in
					self.requestUserAttributes(config)
				},
				onFailure: { err in
					println("ERROR: Cannot get access token")
					self.onFailure?(err)
				}
		)
	}

	private func requestUserAttributes(config: LROAuthConfig) {
		OAuthSession = LRSession(
				server: LiferayServerContext.server,
				authentication: LROAuth(config: config))
		OAuthSession!.callback = self

		let srv = LRScreensuserService_v62(session: OAuthSession!)

		var outError: NSError?
		srv.getCurrentUser(&outError)
	}

	func onFailure(error: NSError!) {
		onFailure?(error)
	}

	func onSuccess(result: AnyObject!) {
		if let resultValue = result as? [String:AnyObject] {
			resultUserAttributes = resultValue

			SessionContext.createOAuthSession(
					authentication: OAuthSession!.authentication as! LROAuth,
					userAttributes: resultValue)

			onSuccess?()
		}
	}

}
