//
//  UILabel+CustomLabel.m
//  XSInfinity
//
//  Created by Jerk Nino Magdadaro on 01/11/2018.
//  Copyright © 2018 Jerk Magz. All rights reserved.
//

#import "UILabel+CustomLabel.h"

@implementation UILabel (CustomLabel)

-(void)setLineHeight {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString  alloc] initWithString:self.text];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    //[style setLineSpacing:1.5];
    [style setLineHeightMultiple:1.4];
    [attrString addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, self.text.length)];
    self.attributedText = attrString;
}



@end
