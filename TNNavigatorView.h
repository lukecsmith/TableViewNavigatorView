//
//  TNNavigatorView.h
//
//  Created by Luke Smith on 26/06/2015.
//  Copyright (c) 2015 Appgroup. All rights reserved.
//  www.appgroup.co.uk

/**
 `TNNavigatorView' is a subclass of `UIView' and is intended to both show a complete visual representation of the contents of a tableview, and to allow quick navigation around it.  Both the sections and rows of a UITableview are all represented by visual objects that have 3 purposes - represent each row with an item, allow the clicking on the row icon to scroll the tableview to that row, and also to represent a completion status for the row if that is required.  The rows are also highlighted to show whether they are currently visible in the main tableview.  Integration and use is designed to be as simple as possible with an existing tableview.  Row objects are contained within section objects, which can also represent the completion status of that section if required.
 */

#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#import <UIKit/UIKit.h>
#import "TNSectionView.h"
#import "TNRowView.h"

@protocol TNNavigatorViewDelegate <NSObject>

@optional

- (NSString*) headingTextForSectionNo:(NSInteger)sectionNo; //get the heading text for each section icon
- (BOOL) indexPathIsOneToExclude:(NSIndexPath*)indexPath;   //check if the given indexpath is for a cell that should NOT be represented by a row icon.  This can be used if for eg, you have a heading row object, and its not something that needs representing as a row in the navigator.  This method is called before the building of every row object, to ensure that the row object is necessary.

@end

@interface TNNavigatorView : UIView <TNRowViewDelegate, TNSectionViewDelegate>

@property (nonatomic, assign) id <TNNavigatorViewDelegate> delegate;

@property (nonatomic, strong) UIFont  *headingTextFont;                         //The font for section headings
@property (nonatomic, strong) UIColor *rowVisibleComplete;                      //Colour for row items that are visible (on screen in the tableview) and 'complete'
@property (nonatomic, strong) UIColor *rowNotVisibleComplete;                   //Colour for rows that are complete but not on screen
@property (nonatomic, strong) UIColor *rowVisibleNotComplete;                   //Colour for rows that are not complete, but are on screen
@property (nonatomic, strong) UIColor *rowNotVisibleNotComplete;                //Colour for rows that are not complete, and also not on screen
@property (nonatomic, strong) UIColor *sectionHighlighted;                      //Colour for sections that have any rows currently visible on screen
@property (nonatomic, strong) UIColor *sectionNotHighlighted;                   //Colour for sections that do not have any rows on screen
@property (nonatomic, strong) UIColor *headingTextColorVisibleComplete;         //Text colour for sections that are visible and complete
@property (nonatomic, strong) UIColor *headingTextColorNotVisibleComplete;      //Text colour for sections that are not visible but are complete
@property (nonatomic, strong) UIColor *headingTextColorVisibleNotComplete;      //Text colour for sections the are visible but not complete
@property (nonatomic, strong) UIColor *headingTextColorNotVisibleNotComplete;   //Text colour for headings that are not visible and not complete

@property (nonatomic, assign) CGFloat edgeBuffer;                               //pixel buffer around section objects
@property (nonatomic, assign) CGFloat gapInbetweenRows;                         //pixel buffer inbetween row objects.  For a large tableview with lots of sections and rows, the addition of a gap here can cause some row objects to disappear if there is not enough room.


- (void) visibleCellsChanged;
/**
 `visibleCellsChanged' method is called by scrollviewDidScroll method within the tableview - this allows the highlighting of visible rows and sections.  You must ensure that different colours have been set in the above properties for visible / not visible sections and rows.  Something like this is all that is required, within the tableview class (UITableView is a subclass of UIScrollView) :
 
 - (void) scrollViewDidScroll:(UIScrollView *)scrollView
 {
    [self.tableviewNavigatorView visibleCellsChanged];
 }
 */

- (void) buildNavigatorWithTableview:(UITableView*)tableview headingsShown:(BOOL)headingsShown;
/**
 `buildNavigatorWithTableview:' builds all of the sections and rows objects from scratch.  You pass in the tableview and everything else is done automatically.  The headings shown boolean allows you to turn on and off the showing of section headings.  Theres a further delegate method defined in the above protocol that gets the text for those section headings.
 */

- (void) setRowAtIndexPath:(NSIndexPath*)indexPath asComplete:(BOOL)complete;
/**
 'setRowAtIndexPath:' allows you to change the 'complete' property of a row. This changes its colour scheme (by KVO), as defined in the above colour properties.  This can be ignored if you do not have a concept of complete/incomplete rows in your tableview.  If you do, my normal way is to iterate through all the contents data that populates the tableview, get the complete value for each and pass it in here.  My data for the table also stores the indexpath it goes at.  Like this for eg :
 
 for (ReportItem *item in self.reportSet.reportItems)
 {
    [self.tableviewNavigatorView setRowAtIndexPath:item.indexPath asComplete:[item.valid boolValue]];
 }
 */

- (void) refreshSectionTextColours;
/**
 'refreshSectionTextColours' simply calls to update the colour of the section text objects - generally required if you have completed a row within your table data and want to check to see if the section can also be coloured as 'complete' (ignore if you have no concept of row completion)
 */

@end
