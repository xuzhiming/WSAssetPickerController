//
//  WSUtility.m
//  Pods
//
//  Created by xzming on 15/6/5.
//
//

#import "WSUtility.h"

@implementation WSUtility


+ (NSBundle *)bundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"WSAsset" withExtension:@"bundle"];
        bundle = [[NSBundle alloc] initWithURL:bundleURL];
    });
    
    return bundle;
}

@end
