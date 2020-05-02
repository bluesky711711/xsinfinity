//
//  Colors.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/24/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "Colors.h"

@implementation Colors

+ (Colors *)sharedColors {
    __strong static Colors *sharedColors = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedColors = [[Colors alloc] init];
    });
    return sharedColors;
}

- (id)init {
    self = [super init];
    return self;
}

- (UIColor *)easyColor{
    return [self colorWithHexString:@"#2DC4A4"];
}

- (UIColor *)mediumColor{
    return [self colorWithHexString:@"#E69A20"];
}

- (UIColor *)hardColor{
    return [self colorWithHexString:@"#C42D2D"];
}

- (UIColor *)blueColor{
    return [self colorWithHexString:@"#5B9CFC"];
}

- (UIColor *)lightBlueColor{
    return [self colorWithHexString:@"#6b95ce"];
}

- (UIColor *)greenColor{
    return [self colorWithHexString:@"#62A41B"];
}

- (UIColor *)orangeColor{
    return [self colorWithHexString:@"#FC715B"];
}

- (UIColor *)purpleColor{
    return [self colorWithHexString:@"#B168CC"];
}

- (UIColor *)darkColor{
    return [self colorWithHexString:@"#555555"];
}

- (UIColor *)pinkColor{
    return [self colorWithHexString:@"#DA6466"];
}

- (UIColor *)warning{
    return [self colorWithHexString:@"#C90000"];
}

- (UIColor *)lightGray{
    return [self colorWithHexString:@"#d9d9db"];
}

#pragma mark: Hex to UICOLOR

- (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:(UInt32)x];
}

- (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

@end
