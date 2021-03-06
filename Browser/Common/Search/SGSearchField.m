//
//  SGSearchBar.m
//  Foxbrowser
//
//  Created by Simon Grätzer on 10.08.12.
//  Copyright (c) 2012-2014 Simon Peter Grätzer. All rights reserved.
//
#import "SGSearchField.h"
#include "SGTabDefines.h"

@implementation SGSearchField
@synthesize state = _state;

- (id)initWithFrame:(CGRect)frame  {
    if (self = [super initWithFrame:frame]) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.placeholder = NSLocalizedString(@"Enter URL or search query here", nil);
        self.keyboardType = UIKeyboardTypeASCIICapable;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.textColor = [UIColor darkTextColor];
        self.backgroundColor = UIColorFromHEX(0xDEDEDE);
        
        self.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"magnify"]];
        self.leftViewMode = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ?
            UITextFieldViewModeUnlessEditing : UITextFieldViewModeAlways;
        self.rightViewMode = UITextFieldViewModeUnlessEditing;
        
        CGRect btnRect = CGRectMake(0, 0, 22, 22);
        _reloadItem = [UIButton buttonWithType:UIButtonTypeCustom];
        self.reloadItem.frame = btnRect;
        self.reloadItem.backgroundColor = [UIColor clearColor];
        self.reloadItem.showsTouchWhenHighlighted = YES;
        [self.reloadItem setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
        
        _stopItem = [UIButton buttonWithType:UIButtonTypeCustom];
        self.stopItem.frame = btnRect;
        self.stopItem.backgroundColor = [UIColor clearColor];
        self.stopItem.showsTouchWhenHighlighted = YES;
        [self.stopItem setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
        
        self.state = SGSearchFieldStateDisabled;
        
        self.inputAccessoryView = [self _generateInputAccessoryView];
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    if (self.editing) {
        [super drawTextInRect:rect];
    } else {
        NSString *text = [self.text stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"https://" withString:@""];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            
//            rect.origin.y = [self editingRectForBounds:self.bounds].origin.y;
            rect.origin.y = (self.bounds.size.height - rect.size.height)/2;
            NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
            para.alignment = self.textAlignment;
            [text drawInRect:rect withAttributes:@{NSFontAttributeName:self.font,
                                                   NSForegroundColorAttributeName:self.textColor,
                                                   NSParagraphStyleAttributeName:para}];
        } else {
            [self.textColor setFill];
            [text drawInRect:rect withFont:self.font
               lineBreakMode:NSLineBreakByTruncatingTail
                   alignment:self.textAlignment];
        }
    }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        CGRect textRect = [super rightViewRectForBounds:bounds];
        textRect.origin.x -= 5;
        return textRect;
    }
    return [super rightViewRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        CGRect textRect = [super leftViewRectForBounds:bounds];
        textRect.origin.x += 5;
        return textRect;
    }
    return [super leftViewRectForBounds:bounds];
}

- (IBAction)addText:(UIBarButtonItem *)sender {
    [self insertText:sender.title];
}

- (void)setState:(SGSearchFieldState)state {
    if (_state == state) return;
    
    _state = state;
    switch (state) {
        case SGSearchFieldStateDisabled:
            self.reloadItem.enabled = NO;
            self.rightView = self.reloadItem;
            break;
            
        case SGSearchFieldStateReload:
            self.reloadItem.enabled = YES;
            self.rightView = self.reloadItem;
            break;
            
        case SGSearchFieldStateStop:
            self.rightView = self.stopItem;
            break;
    }
}

- (UIView *)_generateInputAccessoryView {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.superview.bounds.size.width, kSGToolbarHeight)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
        && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        toolbar.translucent = YES;
        toolbar.tintColor = kSGBrowserBarColor;
    }
    
    UIBarButtonItem *btn, *flex, *fix;
    flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                         target:nil action:nil];
    fix = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                        target:nil action:nil];
    fix.width = 10;
    
    NSArray *titles = @[@":", @".", @"-", @"/", @".com"];
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:titles.count];
    [buttons addObject:flex];
    for (NSString *title in titles) {
        btn = [[UIBarButtonItem alloc] initWithTitle:title
                                               style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(addText:)];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
            && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
            btn.tintColor = [UIColor lightGrayColor];
        }
        
        btn.width = 40.;
        [buttons addObject:btn];
        [buttons addObject:fix];
    }
    [buttons addObject:flex];
    toolbar.items = buttons;
    return toolbar;
}

@end
