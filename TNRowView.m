//
//  TNRowView.m
//
//  Created by Luke Smith on 26/06/2015.
//  Copyright (c) 2015 Appgroup. All rights reserved.
//  www.appgroup.co.uk

#import "TNRowView.h"

@implementation TNRowView

- (id) init
{
    if (self = [super init])
    {
        [self addObserver:self forKeyPath:@"visible" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"complete" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"visible"])
    {
        [self animateBackgroundColourChange];
    } else if (object == self && [keyPath isEqualToString:@"complete"])
    {
        [self animateBackgroundColourChange];
    } else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) animateBackgroundColourChange
{
    UIColor *newColour = [self.delegate colourForRowObject:self];
    __weak TNRowView *weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{weakSelf.backgroundColor = newColour;} completion:nil];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate rowTouched:self];
    //not calling [super touchesBegan] because we dont want the sectionView to also call sectionTouched - that call interferes with the actions of this one.
}

- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"visible"];
    [self removeObserver:self forKeyPath:@"complete"];
}

@end
