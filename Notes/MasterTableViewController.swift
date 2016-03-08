//
//  MasterTableViewController.swift
//  Notes
//
//  Created by Adithya Bharadwaj on 26/10/15.
//  Copyright (c) 2015 Adithya Bharadwaj. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate {

    
    var noteObjects : NSMutableArray! = NSMutableArray()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
          self.parseLoginSetup()
        
            }
    
    
    func fetchAllObjectsFromLocalDataStore(){
        
        var query : PFQuery = PFQuery(className: "Notes")
        query.fromLocalDatastore()
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if(error == nil){
                var temp : NSArray = objects as! NSArray
                self.noteObjects = temp.mutableCopy() as! NSMutableArray
                self.tableView.reloadData()
            }
            else{
                println(error?.userInfo)
            }
        }
        
    }
    
    func fetchAllObjects(){
        
        //PFObject.unpinAllObjectsInBackgroundWithBlock(nil)
        var query : PFQuery = PFQuery(className: "Notes")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if(error == nil){
                PFObject.pinAllInBackground(objects, block: nil)
                self.fetchAllObjectsFromLocalDataStore()
            }
            else{
                println(error?.userInfo)
            }
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        if(!username.isEmpty || !password.isEmpty){
            return true
        }
        else{
            return false
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Failed to Login")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        /*if let password = info? ["password"] as? String{
            return password.utf16Count >=8
        }*/
        return true
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to SignUp")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("User Cancelled the SignUp")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.noteObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MasterTableViewCell

        var object : PFObject = self.noteObjects.objectAtIndex(indexPath.row) as! PFObject
        cell.masterTitleLabel.text = object.objectForKey("title") as? String
        cell.masterTextLabel.text = object.objectForKey("text") as? String

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("editNote", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var upcoming : AddNoteTableViewController = segue.destinationViewController as! AddNoteTableViewController
        if(segue.identifier == "editNote"){
            let indexPath = self.tableView.indexPathForSelectedRow()
            var object : PFObject = self.noteObjects.objectAtIndex(indexPath!.row) as! PFObject
            upcoming.object = object
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    func parseLoginSetup(){
        
        
        if(PFUser.currentUser() == nil){
            var loginViewController = PFLogInViewController()
            loginViewController.fields = PFLogInFields.UsernameAndPassword | PFLogInFields.LogInButton | PFLogInFields.SignUpButton | PFLogInFields.PasswordForgotten | PFLogInFields.DismissButton
            var loginTitleLogo = UILabel()
            loginTitleLogo.text = "Adithya Bharadwaj"
            loginViewController.logInView?.logo = loginTitleLogo
            loginViewController.delegate = self
            
            
            var signupViewController = PFSignUpViewController()
            var signupTitleLogo = UILabel()
            signupTitleLogo.text = "Adithya Bharadwaj"
            signupViewController.signUpView?.logo = signupTitleLogo
            signupViewController.delegate = self
            
            loginViewController.signUpController = signupViewController
            
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }
        else{
            self.fetchAllObjectsFromLocalDataStore()
            self.fetchAllObjects()
        }

        
    }
    
    @IBAction func buttonParseLogout(sender: AnyObject) {
    
    PFUser.logOut()
        self.parseLoginSetup()
    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
