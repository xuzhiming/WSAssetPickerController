//
//  WSAlbumTableViewController.m
//  WSAssetPickerController
//
//  Created by Wesley Smith on 5/12/12.
//  Copyright (c) 2012 Wesley D. Smith. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "WSAlbumTableViewController.h"
#import "WSAssetPickerState.h"
#import "WSAssetTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "WSUtility.h"

@interface WSAlbumTableViewController ()
@property (nonatomic, strong) NSMutableArray *assetGroups; // Model (all groups of assets).
@end


@implementation WSAlbumTableViewController

@synthesize assetPickerState = _assetPickerState;
@synthesize assetGroups = _assetGroups;


#pragma mark - Getters

- (NSMutableArray *)assetGroups
{
    if (!_assetGroups) {
        _assetGroups = [NSMutableArray array];
    }
    
    return _assetGroups;
}

#pragma mark - View Lifecycle


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.wantsFullScreenLayout = YES;
    
    self.assetPickerState.state = WSAssetPickerStatePickingAlbum;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = [[WSUtility bundle] localizedStringForKey:@"g_loading" value:nil table:@"assetstr"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                           target:self 
                                                                                           action:@selector(cancelButtonAction:)];
    
    self.navigationItem.title = [[WSUtility bundle] localizedStringForKey:@"g_message_photo" value:nil table:@"assetstr"];//NSLocalizedStringFromTable(@"g_message_photo", @"assetstr", nil);//@"Albums";
    [self.assetPickerState.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        NSInteger count = [group numberOfAssets];
        if (count == 0) {
            return ;
        }
        // If group is nil, the end has been reached.
//        if (group == nil) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.navigationItem.title = @"Albums";
//            });
//            return;
//        }
        
        // Add the group to the array.
        [self.assetGroups insertObject:group atIndex:0];
        
        // Reload the tableview on the main thread.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failureBlock:^(NSError *error) {
        // TODO: User denied access. Tell them we can't do anything.
    }];
}


#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma  mark - Actions

- (void)cancelButtonAction:(id)sender 
{    
    self.assetPickerState.state = WSAssetPickerStatePickingCancelled;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.assetGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WSAlbumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Get the group from the datasource.
    ALAssetsGroup *group = [self.assetGroups objectAtIndex:indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]]; // TODO: Make this a delegate choice.
    
    // Setup the cell.
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)", [group valueForProperty:ALAssetsGroupPropertyName], [group numberOfAssets]];
    cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [self.assetGroups objectAtIndex:indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]]; // TODO: Make this a delegate choice.
    
    if ([_assetPickdelegate respondsToSelector:@selector(WSAssetPickGroup:with:)]) {
        UIViewController *vc = [_assetPickdelegate WSAssetPickGroup:group with:self.assetPickerState];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    WSAssetTableViewController *assetTableViewController = [[WSAssetTableViewController alloc] initWithStyle:UITableViewStylePlain];
    assetTableViewController.assetPickerState = self.assetPickerState;
    assetTableViewController.assetsGroup = group;
    
    [self.navigationController pushViewController:assetTableViewController animated:YES];
}

#define ROW_HEIGHT 57.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	return ROW_HEIGHT;
}

@end
