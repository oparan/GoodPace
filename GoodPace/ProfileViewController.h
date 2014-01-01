//
//  ProfileViewController.h
//  GoodPace
//
//  Created by Paran, Omer on 12/22/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@class Charity;

@interface ProfileViewController : UIViewController <FBLoginViewDelegate, UITextViewDelegate, UINavigationControllerDelegate,
                                                     UIImagePickerControllerDelegate, UIActionSheetDelegate>{
    @private
    UIImagePickerController* mediaPicker;
                                                         
    @private
    int originalYLocation;
                                                         
    @private
    BOOL userDidLogin;
}

// Information about chosen donor
@property (weak, nonatomic) IBOutlet UIImageView* icon;
@property (weak, nonatomic) IBOutlet UIImageView* profilePic;
@property (weak, nonatomic) IBOutlet UILabel* name;

@property (weak, nonatomic) IBOutlet UIButton* startWalkingButton;

// This button is shown / hidden based on the appereance of the keyboard
@property (weak, nonatomic) IBOutlet UIBarButtonItem* doneButton;

@property (weak, nonatomic) IBOutlet FBLoginView*           fbLoginView;
@property (weak, nonatomic) IBOutlet UITextField*           fbUserName;
@property (weak, nonatomic) IBOutlet UITextField*           fbUserEMail;
@property (weak, nonatomic) IBOutlet UITextView*            fbUserComment;
@property (weak, nonatomic) IBOutlet FBProfilePictureView*  fbPicView;

- (IBAction) donePressed:(id)sender;

@end

