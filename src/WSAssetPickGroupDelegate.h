//
//  WSAssetPickGroupDelegate.h
//  WSAssetPickerController
//
//  Created by xzming on 14/12/5.
//  Copyright (c) 2014年 Wesley D. Smith. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class WSAssetPickerState;

@protocol WSAssetPickGroupDelegate <NSObject>

@optional
-(UIViewController*)WSAssetPickGroup:(ALAssetsGroup *)assetGroup with:(WSAssetPickerState*)state;

@end
