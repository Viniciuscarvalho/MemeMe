//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Vinicius Carvalho on 15/07/16.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit
import Foundation


class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    var memes: Meme!
    
    @IBOutlet weak var memeView: UIView!
    @IBOutlet weak var imagePickView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!

    var priorKeyboardHeight: CGFloat = 0.0
    
    @IBAction func cancelAndReturnToOriginalView(sender: AnyObject) {
        setToInitialState()
        topTextField.text = ""
        bottomTextField.text = ""
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // share button
    @IBAction func share(sender: AnyObject) {
        let image = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {
            (activityType, completed: Bool, returnedItems: [AnyObject]?, error: NSError? ) in
            // return if cancelled
            if (!completed) { self.save(image) }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        setTextField(topTextField, placeholderTxt: "TOP")
        setTextField(bottomTextField, placeholderTxt: "BOTTOM")
        setToInitialState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //Camera is avaliable on the device
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeKeyboardNotifications()
    }
    
    // hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // camera button
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        presentImagePickerView(.Camera)
    }
    
    // album button
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        presentImagePickerView(.PhotoLibrary)
    }
    
    func presentImagePickerView(sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.allowsEditing = true
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    // Dismiss image picker
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // display the original image to UIImageView box
        let userSelectedImageVal = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePickView.image = userSelectedImageVal
        imagePickView.contentMode = .ScaleAspectFit
        shareButton.enabled = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setTextField(textField: UITextField, placeholderTxt: String) {
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor .blackColor(),
            NSForegroundColorAttributeName : UIColor .whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -4.0
        ]
        
        textField.text = placeholderTxt
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
        textField.delegate = self
        
    }
    
    func setToInitialState() {
    
        shareButton.enabled = false
        memeView.backgroundColor = UIColor.blackColor()
        imagePickView.image = nil
        
    }
    
    // pragma mark - Settings of Keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if ((textField.placeholder == "TOP") || (textField.placeholder == "BOTTOM"))
        {
            textField.placeholder?.removeAll()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField.text == "") {
            if (textField.tag == 1) {
                setTextField(textField, placeholderTxt: "BOTTOM")
            }
            else if (textField.tag == 2) {
                setTextField(textField, placeholderTxt: "TOP")
            }
            else {
                print("INVALID TAG SUPPLIED \(textField.tag)")
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
    // pragma mark - Notifications
    func subscribeKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    // pragma mark - Create Meme Object
    func save(memedImage: UIImage) {
        let meme = Meme(topTextField: topTextField.text, bottomTextField: bottomTextField.text, image: imagePickView.image!, memedImage: memedImage)
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
    func generateMemedImage() -> UIImage {
        // hide toolbar and navbar
        navBar.hidden = true
        toolBar.hidden = true
        
        // render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // show toolbar and navbar
        navBar.hidden = false
        toolBar.hidden = false
        
        return memedImage
    }

}
