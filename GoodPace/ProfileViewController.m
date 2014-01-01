//
//  ProfileViewController.m
//  GoodPace
//
//  Created by Paran, Omer on 12/22/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ProfileViewController.h"

#import "Charity.h"
#import "Globals.h"
#import "Profile.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    // Just in case 
    return userDidLogin;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

#pragma mark - FB

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    profile.fbUser = user;
    
    userDidLogin = YES;
    
    self.fbUserName.text        = user.name;
    self.fbPicView.profileID    = user.id;
    self.fbUserComment.editable = YES;
    
    if (profile.userImg) {
        [self setCustomProfileImg];
    }
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        if (!error) {
            self.fbUserEMail.text = [user objectForKey:@"email"];
        }
    }];
    
    [self.startWalkingButton setEnabled:YES];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    self.fbUserName.text        = @"";
    self.fbUserEMail.text       = @"";
    self.fbPicView.profileID    = 0;
    self.fbUserComment.editable = NO;
    self.doneButton.title       = @"";
    
    userDidLogin = NO;
    [self.startWalkingButton setEnabled:NO];

    [self.profilePic setHidden:YES];
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [UI showOKMsg:alertMessage title:alertTitle];
    }
}

#pragma mark - Delegates

- (IBAction) donePressed:(id)sender {
    self.doneButton.title = @"";
    [self.fbUserComment resignFirstResponder];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.doneButton.title = NSLocalizedString(@"done", nil);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
        case 1:
            mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
        case 2:
            [self setFBProfileImage];
            return;
            
        default:
            return;
    }
    
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    profile.userImg = image;
    [self setCustomProfileImg];
}

- (void) setCustomProfileImg {
    CGRect r = [self.fbPicView frame];
    if (originalYLocation == 0) {
        originalYLocation = r.origin.y;
        r.origin.y = 1450.0f;
        [self.fbPicView setFrame:r];
    }

    [self.profilePic setHidden:NO];
    [self.profilePic setUserInteractionEnabled:YES];
    [self.profilePic setImage:profile.userImg];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    UIView* view = [touch view];
    
    if ( (view == self.fbPicView) || (view == self.profilePic) ){
        [self chosePhotoAction];
    }
}

#pragma mark - Misc

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (activeDonor) {
        self.name.text = activeDonor.name;
        
        [self.icon setImage:activeDonor.icon];
    }
    
    self.fbLoginView.readPermissions = @[@"basic_info", @"email", @"user_likes"];
    self.fbLoginView.delegate = self;
    self.fbUserComment.delegate = self;
    self.fbUserComment.editable = NO;
    self.doneButton.title = @"";
}

- (void) setFBProfileImage {
    
    if (originalYLocation != 0) {
        [self.profilePic setHidden:YES];
        CGRect r = [self.fbPicView frame];
        r.origin.y = originalYLocation;
        [self.fbPicView setFrame:r];
        originalYLocation = 0;
        profile.userImg = nil;
    }
}

- (void) chosePhotoAction{
    
    if (!mediaPicker) {
        mediaPicker = [[UIImagePickerController alloc] init];
        [mediaPicker setDelegate:self];
        mediaPicker.allowsEditing = YES;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:NSLocalizedString(@"Take photo", nil), NSLocalizedString(@"Choose Existing",nil),
                                                                          NSLocalizedString(@"Use Facebook Profile",nil),
                                                                          nil];
        [actionSheet showInView:self.view];
    } else {
        mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:mediaPicker animated:YES completion:nil];
    }
}


@end
