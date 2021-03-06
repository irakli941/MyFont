//
//  SubscribeViewController.swift
//  MyFonts
//
//  Created by Irakli on 1/23/20.
//  Copyright © 2020 Irakli. All rights reserved.
//

import Foundation
import UIKit
import UPCarouselFlowLayout
import ShimmerSwift
import NVActivityIndicatorView

class SubscribeViewController: UIViewController, NVActivityIndicatorViewable {
    
    // MARK: Outlets & Properties
    @IBOutlet var collectionViewLayout: UPCarouselFlowLayout! {
        didSet {
            collectionViewLayout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 20)
        }
    }
    @IBOutlet var collectionVIew: UICollectionView! {
        didSet {
            collectionVIew.backgroundColor = UIColor.clear
            collectionVIew.isScrollEnabled = false
        }
    }
    
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.isScrollEnabled = false
        }
    }
    
    @IBOutlet var subscribeButton: UIButton! {
        didSet {
            subscribeButton.layer.cornerRadius = subscribeButton.frame.height/4
            subscribeButton.clipsToBounds = true
            subscribeButton.setTitle(NSLocalizedString("subscribe.purchasebutton.title", comment: "Try for Free"), for: .normal)
            subscribeButton.backgroundColor = THEME_MAIN_COLOR
        }
    }
    @IBOutlet var settingsButton: UIButton! {
        didSet {
            settingsButton.image(UIImage(named: "ic_close"), renderingMode: .alwaysTemplate)
            settingsButton.tintColor = THEME_MAIN_COLOR
        }
    }
    @IBOutlet var shimmeringView: ShimmeringView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var subscriptionTOSTextView: UITextView! {
        didSet {
            
            subscriptionTOSTextView.text = subscribeViewModel.SubsribtionTOS
            subscriptionTOSTextView.isScrollEnabled = false
            subscriptionTOSTextView.clipsToBounds = true
            subscriptionTOSTextView.sizeToFit()
        }
    }
    @IBOutlet var subscriptionOfferLabel: UILabel! {
        didSet {
            subscriptionOfferLabel.text = subscribeViewModel.SubscriptionOffer
            subscriptionOfferLabel.textColor = LABEL_MAIN_COLOR
        }
    }
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text = SubscribeModel.Title
            titleLabel.textColor = LABEL_MAIN_COLOR
        }
    }
    @IBOutlet var titleImages: [UIImageView]! {
        didSet {
            for imageView in titleImages! {
//                imageView.image = UIImage(named: "diamond")?.withRenderingMode(.alwaysTemplate)
//                imageView.tintColor = THEME_MAIN_COLOR
            }
        }
    }
    
    @IBOutlet var tosLabel: UIButton! {
        didSet {
            tosLabel.setTitle(NSLocalizedString("subscribe.button.tos", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet var restoreLabel: UIButton! {
        didSet {
            restoreLabel.setTitle(NSLocalizedString("subscribe.button.restore", comment: ""), for: .normal)
        }
    }
    
    @IBOutlet var privacyLabel: UIButton! {
        didSet {
            privacyLabel.setTitle(NSLocalizedString("subscribe.button.privacy", comment: ""), for: .normal)
        }
    }
    
    private var subscribeViewModel = SubscribeModel()
    private var scrollingStep = 0
    @IBOutlet var scrollViewContentWidthAnchor: NSLayoutConstraint!
    @IBOutlet var scrollViewContentHeightAnchor: NSLayoutConstraint!
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocalizedIAP()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if PersistencyManager.shared.isSubscriptionActive() {
            self.goToFinalVC()
        }
        shimmeringView.contentView = subscribeButton
        shimmeringView.isShimmering = true
        Timer.scheduledTimer(timeInterval: 1.8, target: self, selector: #selector(self.autoScroll), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let height = self.view.frame.height - collectionVIew.frame.height + subscriptionTOSTextView.frame.height
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: height)
        scrollViewContentHeightAnchor.constant = height
        scrollViewContentWidthAnchor.constant = view.frame.width
        view.layoutIfNeeded()
    }
    
    // MARK: Actions
    @IBAction func onSubscribeTap(_ sender: UIButton) {
        purchaseSubscription()
    }
    
    // MARK: TODO
    @IBAction func onRestoreTap(_ sender: UIButton) {
        restorePurchases()
    }
    
    @IBAction func onPrivacyPolicyTap(_ sender: UIButton) {
        if let url = URL(string: SubscribeModel.PrivacyURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onTermsofServiceTap(_ sender: UIButton) {
        if let url = URL(string: SubscribeModel.TOSURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func onTapSettings(_ sender: UIButton) {
        goToFinalVC()
    }
    
    private func goToFinalVC() {
        let successViewController = storyboard?.instantiateViewController(withIdentifier: "SuccessViewController") as! SuccessViewController
        successViewController.modalPresentationStyle = .fullScreen
        self.present(successViewController, animated: true, completion: nil)
    }
    
}

// MARK: In App Purchases

extension SubscribeViewController {
    
    private func updateLocalizedIAP() {
        _ = RebeloperStore.inAppPurchases.observeNext { (purchases) in
            for purchase in purchases {
                self.subscribeViewModel = SubscribeModel(localizedPrice: purchase.price)
                self.subscriptionOfferLabel.text = self.subscribeViewModel.SubscriptionOffer
            }
        }
    }
    
    // MARK: TODO change subscription
    private func purchaseSubscription() {
        self.startLoader()
        RebeloperStore.purchase("nonRenewableYearly") { (result) in
            self.stopLoader()
            if result == true {
                PersistencyManager.shared.setSubscriptionActive(withDate: Date())
                self.goToFinalVC()
            }
        }
    }
    
    private func restorePurchases() {
        self.startLoader()
        RebeloperStore.restorePurchases { (result) in
            self.stopLoader()
            if result == true {
                PersistencyManager.shared.setSubscriptionActive(withDate: Date())
                self.showSuccessAlert(with: NSLocalizedString("subscribe.alert.restore.success.message", comment: ""))
            } else {
                self.showErrorAlert(with: NSLocalizedString("subscribe.alert.restore.error.message", comment: ""))
            }
        }
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func showSuccessAlert(with message: String) {
        let alert = UIAlertController(title: NSLocalizedString("subscribe.alert.title.success", comment: message), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func startLoader() {
        startAnimating()
    }
    
    private func stopLoader() {
        stopAnimating()
    }
}

extension SubscribeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    @objc func autoScroll() {
        scrollingStep = scrollingStep + 1
        collectionVIew.scrollToItem(at: IndexPath(row: scrollingStep%SubscribeModel.ShowroomKeyboardsAmount, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    // todo change
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SubscribeModel.ShowroomKeyboardsAmount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! SubscribeCell
        cell.setup(index: indexPath.row)
        return cell
    }
}

extension SubscribeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SubscribeModel.Offer.Offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "offerCell") as! OfferCell
        let offerConfig = SubscribeModel.Offer.Offers[indexPath.row]
        cell.setup(image: offerConfig.icon, text: offerConfig.title)
        return cell
    }
}
