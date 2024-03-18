//
//  HomeViewController.swift
//  mfp-Insurance
//


import UIKit

class AnalyzerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // cell reuse id (cells that scroll out of view can be reused)
    let cellReuseIdentifier = "prototype"
    
    @IBOutlet weak var totalcostlabel: UILabel!
    // don't forget to hook this up from the storyboard
    @IBOutlet var tableView: UITableView!
    
    static var damagelist: [Damage] = [Damage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cost:Int = 0
        for damage in AnalyzerViewController.damagelist {
             cost = cost + damage.cost
        }
        if (cost > 0) {
            totalcostlabel.text = "Total Cost : $" + String(cost)
        } else {
             totalcostlabel.text = ""
        }
       
        tableView.rowHeight = 84
        tableView.delegate = self
        tableView.dataSource = self
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        var cost:Int = 0
        for damage in AnalyzerViewController.damagelist {
            cost = cost + damage.cost
        }
        if (cost > 0) {
            totalcostlabel.text = "Total Cost : $" + String(cost)
        } else {
            totalcostlabel.text = ""
        }
        super.viewWillAppear(animated)
    }
    
    @IBAction func submitReport(_ sender: Any) {
        let alert = UIAlertController(title: "Success", message: "Succesfully uploaded the report", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.cancel, handler: {(alert: UIAlertAction!) in
            // Reset Items
            self.totalcostlabel.text = ""
            AnalyzerViewController.damagelist.removeAll()
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AnalyzerViewController.damagelist.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! DamageViewCell
        // set the text from the data model
        cell.type.text =  AnalyzerViewController.damagelist[indexPath.row].type
        cell.cost.text = "$ " + String(AnalyzerViewController.damagelist[indexPath.row].cost)
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
}
