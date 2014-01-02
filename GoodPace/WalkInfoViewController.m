//
//  WalkInfoViewController.m
//  GoodPace
//
//  Created by Paran, Omer on 12/25/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "WalkInfoViewController.h"

#import "DetailViewController.h"
#import "Globals.h"
#import "Profile.h"
#import "Pledge.h"
#import "Charity.h"
#import "MyCharity.h"
#import "LogViewController.h"
#import "LogObj.h"
#import "Facebook.h"
#import "ICEMotionMonitor.h"

//#import "CorePlot-CocoaTouch.h"

static const int NUM_SECTIONS = 1;
static const int NUM_FIXED_ROWS = 4;
static const int DONOR_POS = 0;
static const int TOP_IMG_POS = 1;
static const int TOTAL_STEPS_POS = 2;
static const int PLEDGES_POS = 3;
static const int TOP_IMG_HEIGHT = 177;
static const int INFO_CELL_HEIGHT = 70;

static const int MONEY_LABEL_TAG = 1;

static const int TOP_IMG_LABEL_TAG = 2;
static const int USE_PHONE_TAG = 3;
static const int USE_FITBIT_TAG = 4;

static const int eMailIndex = 0;
static const int eFaceBookIndex = 1;
static const int eTwitterIndex = 2;

@interface WalkInfoViewController ()

@end

@implementation WalkInfoViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    messaureBy = eNone;

    #ifdef DEBUG
    [UI addRightButton:self title:@"Logs" action:@selector(showLogView)];
    #endif 
}

- (void)viewWillAppear:(BOOL)animated {
    myCharity = [profile myCharityByName:activeDonor.name];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    UITableViewCell* clickedCell = (UITableViewCell*) sender;
    
    return clickedCell.accessoryType != UITableViewCellAccessoryNone;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController* detailViewController = (DetailViewController*) [segue destinationViewController];
    [detailViewController setData:YES walkInfoView:self];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int numRows = NUM_FIXED_ROWS;
    
    // Return the number of rows in the section.
    NSArray* pledges = myCharity.getPledges;
    
    if (pledges) {
       numRows += [pledges count];
    }
    
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch(indexPath.row) {
        case TOP_IMG_POS:
            return TOP_IMG_HEIGHT;
            
        case TOTAL_STEPS_POS:
        case PLEDGES_POS:
            return INFO_CELL_HEIGHT;
            
        default:
            return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
            
        case DONOR_POS:
            [self createDonorCell:cell];
            break;
            
        case TOP_IMG_POS:
            [self createTopImgCell:cell];
            break;
            
        case TOTAL_STEPS_POS:
            [self createStepsCell:cell];
            break;
            
        case PLEDGES_POS:
            [self createTotalPledgesCell:cell];
            break;
            
        default:
            [self createPledgeCell:cell pledgeIndex:indexPath.row - PLEDGES_POS - 1];
            break;
    }
    
    return cell;
}

#pragma mark - Misc

- (void) createTopImgCell:(UITableViewCell*) cell {
    
    if (messaureBy == eNone) {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 321, TOP_IMG_HEIGHT)];
        imv.image=[UIImage imageNamed:@"walkInfoFrame.png"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        imv.tag = TOP_IMG_LABEL_TAG;
        [cell.contentView addSubview:imv];
        
        UILabel* welcomeToWalkLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,10,150,40)];
        welcomeToWalkLabel.text = @"Welcome to this walk";
        welcomeToWalkLabel.font = [UIFont boldSystemFontOfSize:12];
        [cell.contentView addSubview:welcomeToWalkLabel];
        
        UILabel* trackQueLabel = [[UILabel alloc] initWithFrame:CGRectMake(70,30,210,40)];
        trackQueLabel.text = @"How would you like to track steps?";
        trackQueLabel.font = [UIFont systemFontOfSize:12];
        [cell.contentView addSubview:trackQueLabel];
        
        UIButton* useMyIphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        useMyIphoneButton.frame = CGRectMake(65,60, 200, 40);
        [useMyIphoneButton addTarget:self action:@selector(usePhone:) forControlEvents:UIControlEventTouchUpInside];
        [useMyIphoneButton setImage:[UIImage imageNamed:@"usePhone.png"] forState:UIControlStateNormal];
        useMyIphoneButton.tag = USE_PHONE_TAG;
        [cell addSubview:useMyIphoneButton];
        
        UIButton* useMyFitBitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        useMyFitBitButton.frame = CGRectMake(65,110, 200, 40);
        [useMyFitBitButton addTarget:self action:@selector(useFitBit:) forControlEvents:UIControlEventTouchUpInside];
        [useMyFitBitButton setImage:[UIImage imageNamed:@"useFitBit.png"] forState:UIControlStateNormal];
        useMyFitBitButton.tag = USE_FITBIT_TAG;
        [cell addSubview:useMyFitBitButton];
    }
    else {
        // Remove old tag, for cases which choose a different donor for this walk from this screen
        UIView *removeView  = [cell viewWithTag:TOP_IMG_LABEL_TAG];
        [removeView removeFromSuperview];
        
        removeView  = [cell viewWithTag:USE_PHONE_TAG];
        [removeView removeFromSuperview];
        
        removeView  = [cell viewWithTag:USE_FITBIT_TAG];
        [removeView removeFromSuperview];

        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 321, TOP_IMG_HEIGHT)];
        imv.image=[UIImage imageNamed:@"walkingProgress.png"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:imv];
        
        stepsLabel = [[UILabel alloc] initWithFrame:CGRectMake(120,50,210,40)];
        stepsLabel.text = [NSString stringWithFormat:@"%@/", myCharity.steps];
        stepsLabel.textColor = [UIColor greenColor];
        stepsLabel.font = [UIFont boldSystemFontOfSize:26];
        [cell.contentView addSubview:stepsLabel];
        
        UILabel* stepsGoalLabel = [[UILabel alloc] initWithFrame:CGRectMake(120,80,210,40)];
        stepsGoalLabel.text = [NSString stringWithFormat:@"%d", [myCharity goalOfSteps]];
        stepsGoalLabel.textColor = [UIColor blackColor];
        stepsGoalLabel.font = [UIFont boldSystemFontOfSize:26];
        [cell.contentView addSubview:stepsGoalLabel];
        
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(140,100,210,40)];
        textLabel.text = @"steps";
        textLabel.textColor = [UIColor grayColor];
        textLabel.font = [UIFont systemFontOfSize:11];
        [cell.contentView addSubview:textLabel];

    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (IBAction) useFitBit:(id)sender {
    messaureBy = eFitBit;
    [stepsManager setHandler:self messaureBy:eFitBit];
    [self.tableView reloadData];
    [stepsManager start];
}

- (IBAction) usePhone:(id)sender {
    messaureBy = eDevice;
    [stepsManager setHandler:self messaureBy:eDevice];
    
    [self.tableView reloadData];
    [stepsManager start];
}

- (void) update:(NSInteger) steps {
    stepsLabel.text = [NSString stringWithFormat:@"%d /", [myCharity.steps intValue] + (int) steps];
    [stepsLabel setNeedsDisplay];
//    stepsLabel.text = [NSString stringWithFormat:@"%d",  steps];
    [myCharity addSteps:(int) steps];
}

- (void) createDonorCell:(UITableViewCell*) cell {

    cell.textLabel.text = activeDonor.name;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;

    cell.detailTextLabel.text = @"";
    
    if (messaureBy == eNone) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
     else {
         cell.accessoryType = UITableViewCellAccessoryNone;
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
     }
    
    
    cell.imageView.image = activeDonor.icon;
}

- (void) createStepsCell:(UITableViewCell*) cell {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (myCharity) {
        cell.textLabel.text = myCharity.steps;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:40];
        cell.textLabel.textColor = [UIColor greenColor];
        
        cell.detailTextLabel.text = @"Total steps\t\t\t\t\t Total Raised";
        
        UILabel* moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(220,8,150,40)];
        moneyLabel.text = [NSString stringWithFormat:@"$%@", myCharity.momeyRaised];
        moneyLabel.tag = MONEY_LABEL_TAG;
        moneyLabel.font = [UIFont boldSystemFontOfSize:40];
        
        // Remove old tag, for cases which choose a different donor for this walk from this screen
        UIView *removeView  = [cell viewWithTag:MONEY_LABEL_TAG];
        [removeView removeFromSuperview];
        
        [cell addSubview:moneyLabel];
    }
}

- (void) createTotalPledgesCell:(UITableViewCell*) cell {
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSArray* pledges = myCharity.getPledges;
    const long numPledges = [pledges count];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", (int) numPledges];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:40];
    cell.textLabel.textColor = [UIColor greenColor];
    
    cell.detailTextLabel.text = @"Pledges\t\t\t\t\t\t Get pledges";
    
    // Plus Image
    
    UIButton* plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(240,10, 32, 32);
    [plusButton addTarget:self action:@selector(addPledge:) forControlEvents:UIControlEventTouchUpInside];
    [plusButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [cell addSubview:plusButton];
}

- (IBAction) addPledge:(id)sender {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Send an email", nil), NSLocalizedString(@"Share on Facebook",nil),
                                                                      NSLocalizedString(@"Share on Twitter",nil),
                                  nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case eMailIndex:
            break;
            
        case eFaceBookIndex:
            [ICEFacebook share];
            break;
            
        case eTwitterIndex:
            return;
            
        default:
            return;
    }
}

- (void) showLogView {

    ICEMotionMonitor* monitor = [ICEMotionMonitor sharedMonitor];
    [monitor stopStepsCounting];
    LogViewController*  logViewController = [[LogViewController alloc] init];
    logViewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:logViewController animated:YES];
}

- (void) createPledgeCell:(UITableViewCell*) cell pledgeIndex:(long) pledgeIndex{
    
    NSArray* pledges = myCharity.getPledges;
    Pledge* pledge = pledges[pledgeIndex];
    
    if (pledge) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ pledged $%@ for your %@ steps", pledge.name, pledge.moneyGiven, pledge.neededSteps];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        cell.detailTextLabel.text = @"";
        cell.imageView.image = pledge.icon;
    }
}

@end
