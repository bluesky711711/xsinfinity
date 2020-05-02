//
//  Fonts.m
//  XSInfinity
//
//  Created by Joseph Marvin Magdadaro on 5/24/18.
//  Copyright © 2018 Joseph Marvin Magdadaro. All rights reserved.
//

#import "Fonts.h"

@implementation Fonts

+ (Fonts *)sharedFonts {
    __strong static Fonts *sharedFonts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFonts = [[Fonts alloc] init];
    });
    return sharedFonts;
}

- (id)init {
    self = [super init];
    return self;
}

//normal s=16, a=18 small font in sketch
//title s=20, a=26 font bold font in sketch
//header s=26, a=30 headline font bold
//navHeader s=34, a=26 Navigation title
//others remain. These are:
    //points in exercises (violet background) - 46


- (UIFont *)headerFont{
    CGFloat size = 30;
    if(IS_IPHONE_5){
        size = 25;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 28;
    }
    
    return [UIFont fontWithName:@"NotoSansHans-Black" size:size];
}

- (UIFont *)headerFontLight{
    CGFloat size = 30;
    if(IS_IPHONE_5){
        size = 25;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 28;
    }
    
    return [UIFont fontWithName:@"NotoSansHans-Light" size:size];
}

- (UIFont *)titleFont{
    CGFloat size = 26;
    if(IS_IPHONE_5){
        size = 18;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 22;
    }
    return [UIFont fontWithName:@"NotoSansHans-Light" size:size];
}

- (UIFont *)titleFontBold{
    CGFloat size = 26;
    if(IS_IPHONE_5){
        size = 18;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 22;
    }
    return [UIFont fontWithName:@"NotoSansHans-Black" size:size];
}

- (UIFont *)normalFont{
    CGFloat size = 18;
    if(IS_IPHONE_5){
        size = 14;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 16;
    }
    return [UIFont fontWithName:@"NotoSansHans-Light" size:size];
}

- (UIFont *)normalFontBold{
    CGFloat size = 18;
    if(IS_IPHONE_5){
        size = 14;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 16;
    }
    return [UIFont fontWithName:@"NotoSansHans-Black" size:size];
}

- (UIFont *)smallFont{
    CGFloat size = 14;
    if(IS_IPHONE_5){
        size = 10;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 12;
    }
    return [UIFont fontWithName:@"NotoSansHans-Light" size:size];
}

- (UIFont *)smallFontBold{
    CGFloat size = 14;
    if(IS_IPHONE_5){
        size = 10;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 12;
    }
    return [UIFont fontWithName:@"NotoSansHans-Black" size:size];
}

- (UIFont *)bigFontBold{
    CGFloat size = (IS_IPHONE_5)? 40: 46;
    return [UIFont fontWithName:@"NotoSansHans-Black" size:size];
}

- (NSString *)normalFontName{
    /*if([LANGUAGE_KEY isEqualToString:@"cn"]){
        return @"MicrosoftYaHei";
    }*/
    return @"NotoSansHans-Light";
}

- (int)normalFontSize{
    CGFloat size = 16;
    if(IS_IPHONE_5){
        size = 14;
    }else if(IS_STANDARD_IPHONE_6_PLUS || IS_STANDARD_IPHONE_6){
        size = 16;
    }
    return size;
}
@end
