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


public class SignUpView_default: BaseScreenletView, SignUpViewModel {

	@IBOutlet public var emailAddressField: UITextField?
	@IBOutlet public var passwordField: UITextField?
	@IBOutlet public var firstNameField: UITextField?
	@IBOutlet public var lastNameField: UITextField?
	@IBOutlet public var signUpButton: UIButton?
	@IBOutlet public var emailAddressBackground: UIImageView?
	@IBOutlet public var passwordBackground: UIImageView?
	@IBOutlet public var firstNameBackground: UIImageView?
	@IBOutlet public var lastNameBackground: UIImageView?

	@IBOutlet public var scrollView: UIScrollView?


	//MARK: BaseScreenletView

	override public func onStartOperation() {
		signUpButton!.enabled = false
	}

	override public func onFinishOperation() {
		signUpButton!.enabled = true
	}


	//MARK: BaseScreenletView

	override public func onCreated() {
		super.onCreated()

		setButtonDefaultStyle(signUpButton)

		scrollView?.contentSize = scrollView!.frame.size

		BaseScreenlet.setHUDCustomColor(DefaultThemeBasicBlue)
	}

	override public func onSetTranslations() {
		firstNameField?.placeholder = LocalizedString("default", "first-name-placeholder", self)
		lastNameField?.placeholder = LocalizedString("default", "last-name-placeholder", self)
		emailAddressField?.placeholder = LocalizedString("default", "auth-method-email", self)
		passwordField?.placeholder = LocalizedString("default", "password-placeholder", self)

		signUpButton?.replaceAttributedTitle(
				LocalizedString("default", "sign-up-button", self),
				forState: .Normal)
	}

	//MARK: SignUpViewModel

	public var emailAddress: String? {
		get {
			return nullIfEmpty(emailAddressField!.text)
		}
		set {
			emailAddressField!.text = newValue
		}
	}

	public var password: String? {
		get {
			return nullIfEmpty(passwordField!.text)
		}
		set {
			passwordField!.text = newValue
		}
	}

	public var firstName: String? {
		get {
			return nullIfEmpty(firstNameField!.text)
		}
		set {
			firstNameField!.text = newValue
		}
	}

	public var lastName: String? {
		get {
			return nullIfEmpty(lastNameField!.text)
		}
		set {
			lastNameField!.text = newValue
		}
	}

	public var editCurrentUser: Bool = false {
		didSet {
			let key: String
			let actionName: String

			if editCurrentUser {
				key = "save-button"
				actionName = "save-action"

				self.firstName = SessionContext.userAttribute("firstName") as? String
				self.middleName = SessionContext.userAttribute("middleName") as? String
				self.lastName = SessionContext.userAttribute("lastName") as? String
				self.emailAddress = SessionContext.userAttribute("emailAddress") as? String
				self.password = SessionContext.currentBasicPassword
				self.screenName = SessionContext.userAttribute("screenName") as? String
				self.jobTitle = SessionContext.userAttribute("jobTitle") as? String
			}
			else {
				key = "sign-up-button"
				actionName = "signup-action"
			}

			self.signUpButton?.replaceAttributedTitle(
					LocalizedString("default", key, self),
					forState: .Normal)

			self.signUpButton?.restorationIdentifier = actionName
		}
	}


	// The following properties are not supported in this theme but
	// may be supported in a child theme

	public var screenName: String? {
		get { return nil }
		set {}
	}

	public var middleName: String? {
		get { return nil }
		set {}
	}

	public var jobTitle: String? {
		get { return nil }
		set {}
	}


	//MARK: UITextFieldDelegate

	public func textFieldDidBeginEditing(textField: UITextField!) {
		emailAddressBackground?.highlighted = (textField == emailAddressField)
		passwordBackground?.highlighted = (textField == passwordField)
		firstNameBackground?.highlighted = (textField == firstNameField)
		lastNameBackground?.highlighted = (textField == lastNameField)
	}

}
