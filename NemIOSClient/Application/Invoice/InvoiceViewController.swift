//
//  InvoiceViewController.swift
//
//  This file is covered by the LICENSE file in the root of this project.
//  Copyright (c) 2016 NEM
//

import UIKit


/// The view controller that lets the user create and scan invoices.
class InvoiceViewController: UIViewController {
    
    // MARK: - View Controller Properties
    
    var account: Account?
    
    // MARK: - View Controller Outlets

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var createInvoiceContainerView: UIView!
    @IBOutlet weak var scanInvoiceContainerView: UIView!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account = getAccount()
        
        guard account != nil else {
            print("Critical: Account not available!")
            return
        }
        
        updateViewControllerAppearanceOnViewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewControllerAppearanceOnViewWillAppear()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
        case "embedInvoiceAccountInfoViewController":
            
            let destinationViewController = segue.destination as! InvoiceAccountInfoViewController
            destinationViewController.account = account
            
        default:
            return
        }
    }
    
    // MARK: - View Controller Helper Methods
    
    /// Updates the appearance (coloring, titles) of the view controller on view did load.
    fileprivate func updateViewControllerAppearanceOnViewDidLoad() {
        
        tabBarController?.title = "MY_INFO".localized()
        
        segmentedControl.setTitle("MY_INFO".localized(), forSegmentAt: 0)
        segmentedControl.setTitle("NEW_INVOICE".localized(), forSegmentAt: 1)
        segmentedControl.setTitle("SCAN_QR".localized(), forSegmentAt: 2)
        
        infoContainerView.isHidden = false
        createInvoiceContainerView.isHidden = true
        scanInvoiceContainerView.isHidden = true
    }
    
    /// Updates the appearance (coloring, titles) of the view controller on view will appear.
    fileprivate func updateViewControllerAppearanceOnViewWillAppear() {
        
        tabBarController?.navigationItem.rightBarButtonItem = nil
        handleSegmentChange(segmentedControl)
    }
    
    /**
        Fetches the account from the parent account detail tab bar controller.
     
        - Returns: The current account.
     */
    fileprivate func getAccount() -> Account? {
        
        var account: Account?
        
        if let accountDetailTabBarController = tabBarController as? AccountDetailTabBarController {
            guard accountDetailTabBarController.account != nil else {
                return account
            }
            
            account = accountDetailTabBarController.account!
        }
        
        return account
    }
    
    // MARK: - View Controller Outlet Actions

    @IBAction func handleSegmentChange(_ sender: UISegmentedControl) {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0 :
            
            infoContainerView.isHidden = false
            createInvoiceContainerView.isHidden = true
            scanInvoiceContainerView.isHidden = true
            
            tabBarController?.title = "MY_INFO".localized()
            
        case 1 :
            
            createInvoiceContainerView.isHidden = false
            infoContainerView.isHidden = true
            scanInvoiceContainerView.isHidden = true

            tabBarController?.title = "NEW_INVOICE".localized()
            
        case 2 :
            
            scanInvoiceContainerView.isHidden = false
            infoContainerView.isHidden = true
            createInvoiceContainerView.isHidden = true
            
            tabBarController?.title = "SCAN_QR".localized()

        default:
            break
        }
    }
}
