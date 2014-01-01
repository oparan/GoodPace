//
//  MasterViewController.m
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "Profile.h"
#import "Globals.h"
#import "Charity.h"

static const int NUM_SECTIONS = 1;
static const int TOP_IMG = 0;
static const int TOP_IMG_HEIGHT = 329;


@implementation MasterViewController

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int numRows = 0;

    if(!fromWalkScreen) {
        numRows = 1;
    }
    
    if (charities) {
        numRows += [charities count];
    }
    
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if ( !fromWalkScreen && (indexPath.row == TOP_IMG)) {
        UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 321, TOP_IMG_HEIGHT)];
        imv.image=[UIImage imageNamed:@"startImage.png"];
        [cell.contentView addSubview:imv];
    }
    else {
        long donorIndex = indexPath.row;
        if (!fromWalkScreen) {
            donorIndex--;
        }
        
        Charity* charity = (Charity*) [charities objectAtIndex:donorIndex];
        
        // Top Line
        cell.textLabel.text = charity.name;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        
        // Subtitle
        cell.detailTextLabel.text = [NSString stringWithFormat:@"      %@\t\t$%@", charity.joined, charity.moneyRaised];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor greenColor];
        
        if (fromWalkScreen) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // Walking Man little image
        UIImageView* imv = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 16, 16)];
        imv.image = walkManImg;
        [cell.detailTextLabel addSubview:imv];

        [cell.imageView setImage:charity.icon];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (fromWalkScreen) {
        activeDonor = charities[indexPath.row];
        
        [detailViewController setData:YES walkInfoView:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!fromWalkScreen && (indexPath.row == TOP_IMG)) {
        return TOP_IMG_HEIGHT;
    }
    
    return 54;
}

#pragma mark - View

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (fromWalkScreen) {
        return NO;
    }

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    return indexPath.row != TOP_IMG;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        activeDonor = charities[indexPath.row - 1];
        
        DetailViewController* _detailViewController = (DetailViewController*) [segue destinationViewController];
        [_detailViewController setData:NO walkInfoView:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    charities = [[profile getCharities] allValues];
    
    if (!walkManImg ){
        walkManImg = [UIImage imageNamed:@"walkMan.png"];
    }
    
    if (fromWalkScreen) {
        self.navItem.title = NSLocalizedString(@"Charities", nil);
    }
}

#pragma mark - Misc

- (void) setFromWalkScreen:(DetailViewController*) _detailViewController {
    fromWalkScreen = YES;
    detailViewController = _detailViewController;
}


@end
