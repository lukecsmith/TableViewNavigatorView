//
//  TNSectionView.h
//
//  Created by Luke Smith on 26/06/2015.
//  Copyright (c) 2015 Appgroup. All rights reserved.
//  www.appgroup.co.uk

#import <UIKit/UIKit.h>

@protocol TNSectionViewDelegate <NSObject>

@required

- (UIColor*) colourForSectionBackground:(id)sender;
- (UIColor*) colourForSectionText:(id)sender;
- (void) sectionTouched:(id)sender;

@end

@interface TNSectionView : UIView

@property (assign, nonatomic) id <TNSectionViewDelegate> delegate;
@property (nonatomic, assign) NSInteger sectionNo;
@property (strong, nonatomic) UILabel *sectionHeadingLabel;
@property (strong, nonatomic) UIView *rowsView;
@property (assign, nonatomic) BOOL highlighted;
@property (strong, nonatomic) NSArray *allRows;

- (void) setUpSubviewsWithHeading:(BOOL)heading pixelBuffer:(CGFloat)pixelBuffer height:(CGFloat)height;

@end
