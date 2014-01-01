//
//  DetailViewController.h
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@class Charity;
@class WalkInfoViewController;

@interface DetailViewController : UIViewController {
    @private
    WalkInfoViewController* walkInfoView;
}

@property (nonatomic) BOOL fromWalkScreen;

@property (weak, nonatomic) IBOutlet UILabel*joined;
@property (weak, nonatomic) IBOutlet UILabel* raised;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView* icon;
@property (weak, nonatomic) IBOutlet UITextView* desc;
@property (weak, nonatomic) IBOutlet UIButton* continueButton;
@property (weak, nonatomic) IBOutlet UIButton* chooseDifferentButton;

- (void)setData:(BOOL) fromWalkScreen walkInfoView:(WalkInfoViewController*) walkInfoView;

@end

