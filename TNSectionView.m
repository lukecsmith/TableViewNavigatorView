//
//  TNSectionView.m
//
//  Created by Luke Smith on 26/06/2015.
//  Copyright (c) 2015 Appgroup. All rights reserved.
//  www.appgroup.co.uk

#import "TNSectionView.h"

@implementation TNSectionView

- (id) init
{
    if (self = [super init])
    {
        [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"highlighted"])
    {
        if (self.highlighted)
        {
            [self highlightThisObject];
        } else {
            [self removeHighlight];
        }
    } else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate sectionTouched:self];
    [super touchesBegan:touches withEvent:event];
}

- (void) setUpSubviewsWithHeading:(BOOL)heading pixelBuffer:(CGFloat)pixelBuffer height:(CGFloat)height
{
    NSMutableArray *newConstraints = [NSMutableArray array];
    NSString *verticalConstraint, *horizontalConstraint, *horizontalConstraint2;
    NSDictionary *metrics = @{@"lowPriority":@(UILayoutPriorityDefaultLow)};
    CGFloat subviewHeight;
    if (heading)
    {
        //section has a heading so add both views and constraints
        self.sectionHeadingLabel = [[UILabel alloc] init];
        self.rowsView = [[UIView alloc] init];
        self.sectionHeadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.sectionHeadingLabel.numberOfLines = 0;
        self.sectionHeadingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.sectionHeadingLabel.textAlignment = NSTextAlignmentCenter;
        self.rowsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.sectionHeadingLabel];
        [self addSubview:self.rowsView];
        subviewHeight = (height - (pixelBuffer * 2)) / 2; //height setting for subview accounts for buffers around edges
        verticalConstraint = [NSString stringWithFormat:@"V:|[_sectionHeadingLabel(==%f)][_rowsView(==%f)]|", subviewHeight, subviewHeight];
        horizontalConstraint = [NSString stringWithFormat:@"H:|-%f-[_sectionHeadingLabel]-%f-|", pixelBuffer, pixelBuffer];
        horizontalConstraint2 = [NSString stringWithFormat:@"H:|[_rowsView]|"];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_sectionHeadingLabel, _rowsView)]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(_sectionHeadingLabel)]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint2 options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rowsView)]];
        [self addConstraints:newConstraints];

    } else {
        //no heading so just the row view filling the section area
        self.rowsView = [[UIView alloc] init];
        self.rowsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.rowsView];
        subviewHeight = height - (pixelBuffer * 2);  //height setting for subview accounts for buffers around edges
        verticalConstraint = [NSString stringWithFormat:@"V:|[_rowsView(==%f)]|", subviewHeight];
        horizontalConstraint = [NSString stringWithFormat:@"H:|[_rowsView]|"];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:metrics views:NSDictionaryOfVariableBindings(_rowsView)]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(_rowsView)]];
        [self addConstraints:newConstraints];
    }
}

- (void) highlightThisObject
{
    __weak TNSectionView *weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^
     {
         UIColor *backgroundColor = [weakSelf.delegate colourForSectionBackground:self];
         weakSelf.backgroundColor = backgroundColor;
         weakSelf.sectionHeadingLabel.textColor = [weakSelf.delegate colourForSectionText:self];
     } completion:nil];
}

- (void) removeHighlight
{
    __weak TNSectionView *weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^
     {
         UIColor *backgroundColor = [weakSelf.delegate colourForSectionBackground:self];
         weakSelf.backgroundColor = backgroundColor;
         weakSelf.sectionHeadingLabel.textColor = [weakSelf.delegate colourForSectionText:self];
     } completion:nil];
}

- (void) dealloc
{
    [self removeObserver:self forKeyPath:@"highlighted"];
}

@end
