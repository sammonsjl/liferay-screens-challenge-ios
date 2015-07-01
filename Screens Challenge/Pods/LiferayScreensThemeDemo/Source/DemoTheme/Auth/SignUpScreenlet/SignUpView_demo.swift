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
import LiferayScreens

@IBDesignable public class SignUpView_demo: SignUpView_default, KeyboardLayoutable {

	@IBOutlet internal var jobField: UITextField?

	@IBOutlet internal var nameMark: UIImageView?
	@IBOutlet internal var emailMark: UIImageView?
	@IBOutlet internal var jobMark: UIImageView?
	@IBOutlet internal var passwordMark: UIImageView?

	@IBOutlet internal var nameFail: UIImageView?
	@IBOutlet internal var emailFail: UIImageView?
	@IBOutlet internal var jobFail: UIImageView?
	@IBOutlet internal var passwordFail: UIImageView?

	@IBOutlet internal var nameFailMsg: UILabel?
	@IBOutlet internal var emailFailMsg: UILabel?
	@IBOutlet internal var jobFailMsg: UILabel?
	@IBOutlet internal var passwordFailMsg: UILabel?

	@IBOutlet internal var titleLabel: UILabel?
	@IBOutlet internal var nameLabel: UILabel?
	@IBOutlet internal var emailLabel: UILabel?
	@IBOutlet internal var jobLabel: UILabel?
	@IBOutlet internal var passwordLabel: UILabel?


	internal var keyboardManager = KeyboardManager()
	internal var originalFrame: CGRect?
	internal var textInput: UITextField?

	internal var valid = false


	override public var jobTitle: String? {
		get {
			return nullIfEmpty(jobField!.text)
		}
		set {
			jobField!.text = newValue
		}
	}


	//MARK: SignUpView

	override public func onSetTranslations() {
		firstNameField!.placeholder = LocalizedString("demo", "signup-first-name", self)
		lastNameField!.placeholder = LocalizedString("demo", "signup-last-name", self)
		emailAddressField!.placeholder = LocalizedString("demo", "signup-email", self)
		passwordField!.placeholder = LocalizedString("demo", "signup-password", self)
		jobField!.placeholder = LocalizedString("demo", "signup-job", self)
		titleLabel!.text = LocalizedString("demo", "signup-title", self)
		nameLabel!.text = LocalizedString("demo", "signup-name-title", self)
		emailLabel!.text = LocalizedString("demo", "signup-email-title", self)
		passwordLabel!.text = LocalizedString("demo", "signup-password-title", self)
		jobLabel!.text = LocalizedString("demo", "signup-job-title", self)
		nameFailMsg!.text = LocalizedString("demo", "signup-name-error", self)
		emailFailMsg!.text = LocalizedString("demo", "signup-email-error", self)
		jobFailMsg!.text = LocalizedString("demo", "signup-job-error", self)
	}

	override public func onCreated() {
		scrollView?.contentSize = scrollView!.frame.size

		initialSetup((nameMark!, nameFail!, nameFailMsg!))
		initialSetup((emailMark!, emailFail!, emailFailMsg!))
		initialSetup((jobMark!, jobFail!, jobFailMsg!))
		initialSetup((passwordMark!, passwordFail!, passwordFailMsg!))

		BaseScreenlet.setHUDCustomColor(DemoThemeBasicGreen)
	}

	override public func onShow() {
		keyboardManager.registerObserver(self)
	}

	override public func onHide() {
		keyboardManager.unregisterObserver()
	}

	override public func onPreAction(#name: String?, sender: AnyObject?) -> Bool {
		if name == "signup-action" {
			if !valid {
				shakeEffect()
			}

			return valid
		}

		return true
	}

	private func shakeEffect() {
		let shake = CABasicAnimation(keyPath: "position")
		shake.duration = 0.08
		shake.repeatCount = 4
		shake.autoreverses = true
		shake.fromValue = NSValue(CGPoint: CGPointMake(signUpButton!.center.x - 5, signUpButton!.center.y))
		shake.toValue = NSValue(CGPoint: CGPointMake(signUpButton!.center.x + 5, signUpButton!.center.y))
		signUpButton?.layer.addAnimation(shake, forKey: "position")
	}

	private func initialSetup(images: (mark: UIImageView, fail: UIImageView, msg: UILabel)) {

		images.msg.frame.origin.x = self.frame.size.width + 5

		images.mark.alpha = 0
		images.mark.frame.origin.x = -20

		images.fail.alpha = 0
		images.fail.frame.origin.x = 10
	}

	@IBAction internal func simpleTap() {
		self.endEditing(true)
	}

	public func layoutWhenKeyboardShown(var keyboardHeight: CGFloat,
			animation:(time: NSNumber, curve: NSNumber)) {

		let absoluteFrame = convertRect(frame, toView: window!)

		if textInput!.autocorrectionType == UITextAutocorrectionType.Default ||
			textInput!.autocorrectionType == UITextAutocorrectionType.Yes {

			keyboardHeight += KeyboardManager.defaultAutocorrectionBarHeight
		}

		if (absoluteFrame.origin.y + absoluteFrame.size.height >
				UIScreen.mainScreen().bounds.height - keyboardHeight) || originalFrame != nil {

			let newHeight = UIScreen.mainScreen().bounds.height -
					keyboardHeight - absoluteFrame.origin.y

			if Int(newHeight) != Int(self.frame.size.height) {
				if originalFrame == nil {
					originalFrame = frame
				}

				UIView.animateWithDuration(animation.time.doubleValue,
						delay: 0.0,
						options: UIViewAnimationOptions(animation.curve.unsignedLongValue),
						animations: {
							self.frame = CGRectMake(
									self.frame.origin.x,
									self.frame.origin.y,
									self.frame.size.width,
									newHeight)
						},
						completion: { (completed: Bool) in
						})
			}
		}

	}

	public func layoutWhenKeyboardHidden() {
		if let originalFrameValue = originalFrame {
			self.frame = originalFrameValue
			originalFrame = nil
		}
	}


	//MARK: UITextFieldDelegate

	override public func textFieldDidBeginEditing(textField: UITextField) {
		textInput = textField
	}

	public func textField(textField: UITextField!,
			shouldChangeCharactersInRange range: NSRange,
			replacementString string: String!)
			-> Bool {

		let newText = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString:string)

		var mark: UIImageView?
		var fail: UIImageView?
		var label: UILabel?
		var msg: UILabel?
		var preValidation = false
		var keepMessage = false

		let bundle = NSBundle(forClass: self.dynamicType)

		switch textField {
			case firstNameField!:
				mark = nameMark
				fail = nameFail
				label = nameLabel
				msg = nameFailMsg
				valid = (lastNameField!.text != "" && newText != "")
			case lastNameField!:
				mark = nameMark
				fail = nameFail
				label = nameLabel
				msg = nameFailMsg
				valid = (firstNameField!.text != "" && newText != "")
			case emailAddressField!:
				mark = emailMark
				fail = emailFail
				label = emailLabel
				msg = emailFailMsg
        		valid = newText.isValidEmail
			case passwordField!:
				mark = passwordMark
				fail = passwordFail
				label = passwordLabel
				msg = passwordFailMsg

				switch (newText.passwordStrengh) {
					case (let strength)
					where strength < 0.2:
						valid = false
						passwordFailMsg!.text = NSLocalizedString("demo-signup-password-error-1",
								tableName: "demo",
								bundle: bundle,
								value: "",
								comment: "")
						passwordFailMsg!.textColor = UIColor.redColor()

					case (let strength)
					where strength < 0.3:
						valid = false
						passwordFailMsg!.text = NSLocalizedString("demo-signup-password-error-2",
								tableName: "demo",
								bundle: bundle,
								value: "",
								comment: "")
						passwordFailMsg!.textColor = UIColor.redColor()

					case (let strength)
					where strength < 0.4:
						valid = true
						passwordFailMsg!.text = NSLocalizedString("demo-signup-password-error-3",
								tableName: "demo",
								bundle: bundle,
								value: "",
								comment: "")
						passwordFailMsg!.textColor = UIColor.orangeColor()

					default:
						valid = true
						passwordFailMsg!.text = NSLocalizedString("demo-signup-password-error-4",
								tableName: "demo",
								bundle: bundle,
								value: "",
								comment: "")
						passwordFailMsg!.textColor = nameLabel!.textColor
				}

				preValidation = true
				keepMessage = true
			case jobField!:
				mark = jobMark
				fail = jobFail
				label = jobLabel
				msg = jobFailMsg
				valid = (newText != "")
			default: ()
		}

		if valid {
			hideValidationError((mark!, fail!, label!, msg!), keepMessage: keepMessage)
		}
		else {
			showValidationError((mark!, fail!, label!, msg!), preValidation: preValidation)
		}

		return true
	}

	private func showValidationError(
			controls: (mark: UIImageView, fail: UIImageView, label: UILabel, msg: UILabel),
			preValidation: Bool) {

		if controls.mark.frame.origin.x > 0 {
			// change mark by fail

			UIView.animateWithDuration(0.2,
					delay: 0,
					options: UIViewAnimationOptions.CurveEaseInOut,
					animations: {
						controls.mark.alpha = 0.0
					},
					completion: { Bool -> Void  in
						UIView.animateWithDuration(0.3,
							delay: 0,
							options: UIViewAnimationOptions.CurveEaseInOut,
							animations: {
								controls.fail.alpha = 1.0
								controls.msg.frame.origin.x =
										self.frame.size.width - controls.msg.frame.size.width - 10
							},
							completion: nil)
					})
		}
		else if preValidation {
			// in cross
			controls.fail.frame.origin.x = -20

			UIView.animateWithDuration(0.3,
					delay: 0,
					options: UIViewAnimationOptions.CurveEaseInOut,
					animations: {
						controls.fail.alpha = 1.0
						controls.mark.frame.origin.x = controls.label.frame.origin.x
						controls.fail.frame.origin.x = controls.label.frame.origin.x
						controls.label.frame.origin.x = controls.label.frame.origin.x + 20
						controls.msg.frame.origin.x =
								self.frame.size.width - controls.msg.frame.size.width - 10
					},
					completion: nil)
		}
	}

	private func hideValidationError(
			controls: (mark: UIImageView, fail: UIImageView, label: UILabel, msg: UILabel),
			keepMessage: Bool) {

		if controls.mark.frame.origin.x < 0 {
			// in

			UIView.animateWithDuration(0.3,
					delay: 0,
					options: UIViewAnimationOptions.CurveEaseInOut,
					animations: {
						controls.mark.alpha = 1.0
						controls.mark.frame.origin.x = controls.label.frame.origin.x
						controls.label.frame.origin.x = controls.label.frame.origin.x + 20
					},
					completion: nil)
		}
		else {
			if controls.fail.alpha == 1.0 {
				// change fail by mark

				UIView.animateWithDuration(0.2,
					delay: 0,
					options: UIViewAnimationOptions.CurveEaseInOut,
					animations: {
						controls.fail.alpha = 0.0
						if !keepMessage {
							controls.msg.frame.origin.x = self.frame.size.width + 5
						}
					},
					completion: { Bool -> Void  in
						UIView.animateWithDuration(0.3,
							delay: 0,
							options: UIViewAnimationOptions.CurveEaseInOut,
							animations: {
								controls.mark.alpha = 1.0
							},
							completion: nil)
					})
			}
		}
	}
}
