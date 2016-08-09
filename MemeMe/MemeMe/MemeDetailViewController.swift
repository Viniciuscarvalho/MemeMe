//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Vinicius Carvalho on 08/08/16.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var memeImage: UIImageView!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(MemeDetailViewController.edit))
        
        self.tabBarController?.tabBar.hidden = false
        
        memeImage.image = meme.memedImage
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    func edit() {
    
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        controller.memes = meme
        presentViewController(controller, animated: true, completion: nil)
        
    }
}
