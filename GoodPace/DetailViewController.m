//
//  DetailViewController.m
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "WalkInfoViewController.h"

#import "Charity.h"
#import "Globals.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setData:(BOOL) fromWalkScreen walkInfoView:(WalkInfoViewController*) _walkInfoView {
    self.fromWalkScreen = fromWalkScreen;
        
    if (_walkInfoView) {
        walkInfoView = _walkInfoView;
    }
        
    // Update the view.
    [self configureView];
}

- (void)configureView {
    // Update the user interface for the detail item.

    self.nameLabel.text = activeDonor.name;
        
    self.joined.text = [NSString stringWithFormat:@"%@ %@", activeDonor.joined, NSLocalizedString(@"joined", nil)];
        
    self.raised.text = [NSString stringWithFormat:@"$%@ %@", activeDonor.moneyRaised, NSLocalizedString(@"raised", nil)];
    self.desc.text = [NSString stringWithFormat:@"%@\n\n%@", activeDonor.description , activeDonor.url];

    [self.icon setImage:activeDonor.icon];
        
    self.continueButton.hidden = self.fromWalkScreen;
    self.chooseDifferentButton.hidden = !self.fromWalkScreen;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UNUSED(sender);
    
    if (!self.fromWalkScreen) {
    }
    else {
        MasterViewController* donorsListCtrl = (MasterViewController*) [segue destinationViewController];
        [donorsListCtrl setFromWalkScreen:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureView];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // If are removed , update the walk screen if we got here from the walk screen
    //if (walkInfoView && self.fromWalkScreen && ![[self.navigationController viewControllers] containsObject:self]) {
      //  [walkInfoView setData:self.charity];
//    }
}

@end
