//
//  ICELogViewController.m
//  GoodPace
//
//  Created by Steiner, Ron on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "ICELogViewController.h"
#import "ICEMotionGraphViewController.h"
#import "ICELogger.h"

@interface ICELogViewController ()

@end

@implementation ICELogViewController
{
    NSMutableArray *colors;
}
-(UIColor*) colorForLogLevel: (ICELogLevel) level
{
    UIColor* color = [colors objectAtIndex:level];
    return color;
}

- (void) showGraphView {
    
    ICEMotionGraphViewController*  graphViewController = [[ICEMotionGraphViewController alloc] init];
    graphViewController.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:graphViewController animated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        colors = [NSMutableArray arrayWithObjects:[[UIColor grayColor] colorWithAlphaComponent:0.75],[[UIColor greenColor]colorWithAlphaComponent:0.75], [[UIColor blueColor] colorWithAlphaComponent:0.75] ,[[UIColor orangeColor] colorWithAlphaComponent:0.75], [[UIColor redColor] colorWithAlphaComponent:0.75], nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    [UI addRightButton:self title:@"Graphs" action:@selector(showGraphView)];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [ICELogger numberOfEntries];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogTableCell";
    UITableViewCell *cell = nil;
    
    @try {
        cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    @catch (NSException *exception) {
        cell = nil;
    }
   
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [cell.textLabel.font fontWithSize:18.0];
        cell.detailTextLabel.font = [cell.detailTextLabel.font fontWithSize:8.0];
    }
    
    ICELoggerLogEntry* entry = [ICELogger entryAtIndex:indexPath.row];
    // Configure the cell...
    
    cell.textLabel.text = entry!=nil ? entry.line : nil;
    cell.detailTextLabel.text = entry!=nil ? [NSString stringWithFormat:@"%@\t%@", entry.time, entry.tag] : nil;
    cell.textLabel.textColor = [self colorForLogLevel: entry!=nil? entry.level : 0];

//    UIColor *altCellColor = [self colorForLogLevel: entry!=nil? entry.level : 0];
//    cell.backgroundColor = altCellColor;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
