//
//  TNRowView.h
//
//  Created by Luke Smith on 26/06/2015.
//  Copyright (c) 2015 Appgroup. All rights reserved.
//  www.appgroup.co.uk

#import <UIKit/UIKit.h>

@protocol TNRowViewDelegate <NSObject>

@required

- (UIColor*) colourForRowObject:(id)sender;
- (void) rowTouched:(id)sender;

@end

@interface TNRowView : UIView

@property (nonatomic, assign) id <TNRowViewDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL complete;

@end
