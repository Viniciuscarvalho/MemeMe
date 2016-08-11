//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Vinicius Carvalho on 08/08/16.
//  Copyright © 2016 Vinicius Carvalho. All rights reserved.
//

import Foundation
import UIKit

class MemeTableViewController: UITableViewController {
    
    var memes: [Meme] {
    
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell")
        let meme = memes[indexPath.row]
        
        cell?.textLabel?.text = meme.topTextField! + "..." + meme.bottomTextField!
        cell?.imageView?.image = meme.memedImage
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        controller.meme = memes[indexPath.row]
        self.navigationController!.pushViewController(controller, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    

}
