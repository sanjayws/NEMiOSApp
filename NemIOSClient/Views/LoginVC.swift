import UIKit

class LoginVC: AbstractViewController, UITableViewDelegate, APIManagerDelegate, WalletCellDelegate
{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWallet: UIButton!
    
    
    
    //MARK: - Variables

    let observer :NSNotificationCenter = NSNotificationCenter.defaultCenter()
    var timer :NSTimer!
    var state :[String] = ["none"]
    
    var dataManager :CoreDataManager = CoreDataManager()
    var apiManager :APIManager = APIManager()
    
    var wallets :[Wallet] = [Wallet]()
    var selectedIndex :Int  = -1
    
    private var _isEditing = false
    
    //MARK: - Load Methods

    override func viewDidLoad() {
        super.viewDidLoad()
                
        wallets  = dataManager.getWallets()
        
        if State.fromVC != SegueToLoginVC {
            State.fromVC = SegueToLoginVC
        }
                
        State.currentVC = SegueToLoginVC
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.layer.cornerRadius = 5
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "manageState", userInfo: nil, repeats: true)
    }

    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBAction

    @IBAction func addNewWallet(sender: AnyObject) {
        
        if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
            (self.delegate as! MainVCDelegate).pageSelected(SegueToAddAccountVC)
        }
    }
    
    @IBAction func editButtonTouchUpInside(sender: AnyObject) {
        
        for cell in self.tableView.visibleCells() {
            (cell as! WalletCell).inEditingState = !_isEditing
            (cell as! WalletCell).layoutCell(animated: !_isEditing)
        }
        
        _isEditing = !_isEditing
    }
    
    //MARK: - TableView Delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : WalletCell = self.tableView.dequeueReusableCellWithIdentifier("walletCell") as! WalletCell
        cell.inEditingState = _isEditing
        cell.delegate = self
        var cellData  :Wallet = wallets[indexPath.row]
        cell.walletName.text = cellData.login as String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if State.currentServer != nil {
            State.currentWallet = wallets[indexPath.row]
            apiManager.heartbeat(State.currentServer!)
        }
        else {
            State.toVC = SegueToServerVC
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToServerVC)
            }
        }
    }
    
    //MARK: - WalletCell Delegate
    
    func deleteCell(cell :UITableViewCell){
        var index :NSIndexPath = tableView.indexPathForCell(cell)!
        
        if index.row < wallets.count {
            dataManager.deleteWallet(wallet: wallets[index.row])
            wallets.removeAtIndex(index.row)

            tableView.deleteRowsAtIndexPaths([index], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    //MARK: - APIManagerDelegate Methods
    
    final func heartbeatSuccessed() {
        state.append("logIN")
    }
    
    final func heartbeatDenied() {
        state.append("serverDenied")
    }
    
    //MARK: - APIManagerDelegate Methods Helper
    
    final func manageState() {
        switch state.last! {
        case "logIN" :
            
            APIManager().timeSynchronize(State.currentServer!)
            
            timer.invalidate()
            for var index :Int = 0 ; index < state.count ; index++
            {
                if state[index] == "serverDenied"
                {
                    state.removeAtIndex(index)
                    index--
                }
            }
            State.toVC = SegueToMessages
            
            if self.delegate != nil && self.delegate!.respondsToSelector("pageSelected:") {
                (self.delegate as! MainVCDelegate).pageSelected(SegueToDashboard)
            }
            
            state.removeLast()
            
        case "serverDenied" :
            
            timer.invalidate()
            
            var alert :UIAlertView = UIAlertView(   title: NSLocalizedString("INFO", comment: "Title"),
                                                    message: NSLocalizedString("SERVER_UNAVAILABLE", comment: "Description"), delegate: self, cancelButtonTitle: "OK")
            alert.show()
            state.removeLast()
            
        default :
            break
        }
    }
}
