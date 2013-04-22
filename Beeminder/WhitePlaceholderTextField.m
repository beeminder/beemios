//
//  WhitePlaceholderTextField.m
//  Beeminder
//
//  Created by Andy Brett on 4/22/13.
//  Copyright (c) 2013 Andy Brett. All rights reserved.
//

#import "WhitePlaceholderTextField.h"

@implementation WhitePlaceholderTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor whiteColor] setFill];
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
}

@end
