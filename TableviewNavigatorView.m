//
//  TableviewNavigatorView.m
//
//  Created by Luke Smith on 26/06/2015.
//  Copyright (c) 2015 Appgroup. All rights reserved.
//  www.appgroup.co.uk

#import "TableviewNavigatorView.h"
#import "TNExcludedView.h"

@interface TableviewNavigatorView ()

@property (nonatomic, weak) UITableView *tableview;

@property (nonatomic, strong) NSMutableArray *sectionViews;
@property (nonatomic, strong) NSMutableArray *rowViews;

@end

@implementation TableviewNavigatorView

- (void) awakeFromNib
{
    //create default (placeholder) settings for colours, gaps etc.
    [self setRowNotVisibleComplete:[UIColor greenColor]];
    [self setRowVisibleComplete:[UIColor yellowColor]];
    [self setRowNotVisibleNotComplete:[UIColor lightGrayColor]];
    [self setRowVisibleNotComplete:RGB(213, 205, 205)];
    
    [self setHeadingTextColorVisibleComplete:[UIColor yellowColor]];
    [self setHeadingTextColorNotVisibleComplete:[UIColor greenColor]];
    [self setHeadingTextColorVisibleNotComplete:[UIColor lightGrayColor]];
    [self setHeadingTextColorNotVisibleNotComplete:[UIColor darkGrayColor]];
    
    [self setSectionHighlighted:[UIColor grayColor]];
    [self setSectionNotHighlighted:[UIColor clearColor]];
    [self setHeadingTextFont:[UIFont systemFontOfSize:12]];
    [self setEdgeBuffer:6];
    [self setGapInbetweenRows:1];
}

- (void) buildNavigatorWithTableview:(UITableView*)tableview headingsShown:(BOOL)headingsShown
{
    self.tableview = tableview;
    
    //clear the view to rebuild all sections and rows
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeConstraints:self.constraints];
    self.rowViews = [NSMutableArray array];
    self.sectionViews = [NSMutableArray array];
    
    //get the number of sections count from the tableview and go through creating a section view for each
    for (int i = 0; i < tableview.numberOfSections; i++)
    {
        TNSectionView *sectionView = [[TNSectionView alloc] init];
        sectionView.sectionNo = i;
        [sectionView setUpSubviewsWithHeading:headingsShown pixelBuffer:self.edgeBuffer height:self.frame.size.height];
        [sectionView setDelegate:self];
        
        //if headings required, set up the headings view
        if (headingsShown)
        {
            if ([self.delegate respondsToSelector:@selector(headingTextForSectionNo:)])
            {
                sectionView.sectionHeadingLabel.text = [self.delegate headingTextForSectionNo:i];
            }
            [sectionView.sectionHeadingLabel setFont:self.headingTextFont];
            [sectionView.sectionHeadingLabel setTextColor:[self colourForSectionText:sectionView]];
        }
        
        [self.sectionViews addObject:sectionView];
        [self addSubview:sectionView];
        
        //get the count for number of rows for this section, and add a row view for each one
        NSMutableArray *rows = [NSMutableArray array];
        for (int j = 0; j < [tableview numberOfRowsInSection:i]; j++)
        {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
            BOOL excludeRow = NO;
            if ([self.delegate respondsToSelector:@selector(indexPathIsOneToExclude:)])
            {
                excludeRow = [self.delegate indexPathIsOneToExclude:newIndexPath];
            }
            if (!excludeRow)
            {
                TNRowView *rowView = [[TNRowView alloc] init];
                rowView.indexPath = newIndexPath;
                [rowView setBackgroundColor:self.rowNotVisibleNotComplete];
                [rowView setDelegate:self];
                [rows addObject:rowView];
                [sectionView.rowsView addSubview:rowView];
            } else {
                //excluded view is an empty object that acts as a filler, so that we can search for object in section arrays with an indexPath, using objectAtIndex (missing objects would break this).  Getting an object in this way is much faster than doing a predicate search each time for an indexpath
                TNExcludedView *excludedView = [[TNExcludedView alloc] init];
                [rows addObject:excludedView];
            }
        }
        
        //run autolayout to evenly fit those rows into our section view
        [self doAutolayoutToEvenlyLayoutViews:rows inParentView:sectionView.rowsView withEdgeBuffer:self.edgeBuffer betweenBuffer:self.gapInbetweenRows];
        [self.rowViews addObjectsFromArray:rows];
        sectionView.allRows = rows;
    }
    
    //run autolayout to fit all those section views evenly into the parent view
    [self doAutolayoutToEvenlyLayoutViews:self.sectionViews inParentView:self withEdgeBuffer:self.edgeBuffer betweenBuffer:0];
}

- (void) doAutolayoutToEvenlyLayoutViews:(NSArray*)views inParentView:(UIView*)parentView withEdgeBuffer:(CGFloat)edgeBuffer betweenBuffer:(CGFloat)betweenBuffer
{
    //create all the constraints we need to fit all those views evenly into the parent view
    NSMutableArray *constraints = [NSMutableArray array];
    UIView *previousView;
    NSString *horizontalConstraint, *verticalConstraint;
    for (UIView *view in views)
    {
        if (![view isKindOfClass:[TNExcludedView class]])
        {
            [view setTranslatesAutoresizingMaskIntoConstraints:NO];
            if (!previousView)
            {
                //no previous view so this is the first view - sticks to left hand side
                verticalConstraint = [NSString stringWithFormat:@"V:|-%li-[view]-%li-|", (long)edgeBuffer, (long)edgeBuffer];
                horizontalConstraint = [NSString stringWithFormat:@"H:|-%li-[view]", (long)edgeBuffer];
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
            } else {
                //middle or end view so glue to previous view right side0
                verticalConstraint = [NSString stringWithFormat:@"V:|-%li-[view]-%li-|", (long)edgeBuffer, (long)edgeBuffer];
                horizontalConstraint = [NSString stringWithFormat:@"H:[previousView]-%li-[view(==previousView)]", (long)betweenBuffer];
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)]];
                [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(previousView, view)]];
            }
            previousView = view;
        }
    }
    
    //glue the last view to the right hand side of the superview
    if (previousView)
    {
        horizontalConstraint = [NSString stringWithFormat:@"H:[previousView]-%li-|", (long)edgeBuffer];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraint options:0 metrics:nil views:NSDictionaryOfVariableBindings(previousView)]];
        
        //add all the views to the superview.  Only happens if previousView exists - this also ensures that view were passed in to begin with.
        [self addConstraints:constraints];
    }
}

- (void) highlightFromIndexPath:(NSIndexPath*)startIndexPath toIndexPath:(NSIndexPath*)endIndexPath
{
    //set the highlight property on all rows between the given indexPaths (this automatically colours them too)
    for (TNRowView *row in self.rowViews)
    {
        if (![row isKindOfClass:[TNExcludedView class]])
        {
            //check if the given row is inbetween the startIndexPath and endIndexPath
            if ((([row.indexPath compare:startIndexPath] == NSOrderedDescending) || ([row.indexPath compare:startIndexPath] == NSOrderedSame))
                && (([row.indexPath compare:endIndexPath] == NSOrderedAscending) || ([row.indexPath compare:endIndexPath] == NSOrderedSame)))
            {
                if (row.visible != YES)
                {
                    [row setVisible:YES];
                }
            } else {
                if (row.visible != NO)
                {
                    [row setVisible:NO];
                }
            }

        }
    }
    
    //also set the highlight property on the section objects - this also automatically changes the colour
    for (TNSectionView *section in self.sectionViews)
    {
        if ((section.sectionNo >= startIndexPath.section) && (section.sectionNo <= endIndexPath.section))
        {
            if (section.highlighted == NO)
            {
                [section setHighlighted:YES];
            }
        } else {
            if (section.highlighted == YES)
            {
                [section setHighlighted:NO];
            }
        }
    }
}

- (void) setRowAtIndexPath:(NSIndexPath*)indexPath asComplete:(BOOL)complete
{
    //find the row for the given indexPath and set the complete property - this automatically colours the row
    if (self.sectionViews)
    {
        if (indexPath.section < self.sectionViews.count)
        {
            TNSectionView *section = [self.sectionViews objectAtIndex:indexPath.section];
            if (indexPath.row < section.allRows.count)
            {
                id rowItem = [section.allRows objectAtIndex:indexPath.row];
                if ([rowItem isKindOfClass:[TNRowView class]])
                {
                    rowItem = (TNRowView*)rowItem;
                    [rowItem setComplete:complete];
                    //[section.sectionHeadingLabel setTextColor:[self colourForSectionText:section]];
                }
                return;
            } else {
                //NSLog(@"Navigator : Row doesnt exist in given section");
            }
        } else {
            //NSLog(@"Navigator : Section doesnt exist in sectionViews");
        }
    } else {
        //NSLog(@"Navigator : No sections currently exist");
    }
}

- (void) refreshSectionTextColours
{
    for (TNSectionView *section in self.sectionViews)
    {
        [section.sectionHeadingLabel setTextColor:[self colourForSectionText:section]];
    }
}

- (void) visibleCellsChanged
{
    //this allows us to see which rows are currently visible in the tableview depending on scroll position.  They can then be highlighted.
    //this is normally called from the tableview's own 'scrollViewDidScroll' method
    UITableViewCell *firstObject = (UITableViewCell*)self.tableview.visibleCells.firstObject;
    UITableViewCell *lastObject = (UITableViewCell*)self.tableview.visibleCells.lastObject;
    [self highlightFromIndexPath:[self.tableview indexPathForCell:firstObject] toIndexPath:[self.tableview indexPathForCell:lastObject]];
}

#pragma mark TNRowViewDelegate

- (UIColor*) colourForRowObject:(id)sender
{
    //returns the UIColor thats appropriate depending on the status of visible and complete properties
    TNRowView *rowView = (TNRowView*)sender;
    if (rowView.visible)
    {
        if (rowView.complete)
        {
            return self.rowVisibleComplete;
        } else {
            return self.rowVisibleNotComplete;
        }
    } else {
        if (rowView.complete)
        {
            return self.rowNotVisibleComplete;
        } else {
            return self.rowNotVisibleNotComplete;
        }
    }
}

- (void) rowTouched:(id)sender
{
    //calls to scroll the tableview to the corresponding actual row to the one that has been touched
    TNRowView *rowView = (TNRowView*)sender;
    [self.tableview scrollToRowAtIndexPath:rowView.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark TNSectionViewDelegate

- (UIColor*) colourForSectionBackground:(id)sender
{
    //returns the correct colour for section depending on status of the highlighted property
    TNSectionView *sectionView = (TNSectionView*)sender;
    if (sectionView.highlighted)
    {
        return self.sectionHighlighted;
    } else {
        return self.sectionNotHighlighted;
    }
}

- (UIColor*) colourForSectionText:(id)sender
{
    //returns the correct colour for section text depending on status of the highlighted property
    TNSectionView *sectionView = (TNSectionView*)sender;
    BOOL complete = YES;
    for (id item in sectionView.allRows)
    {
        if ([item isKindOfClass:[TNRowView class]])
        {
            TNRowView *row = (TNRowView*)item;
            if (!row.complete)
            {
                complete = NO;
                break;
            }
        }
    }
    
    if (complete)
    {
        //all rows in the section are complete
        if (sectionView.highlighted)
        {
            return self.headingTextColorVisibleComplete;
        } else {
            return self.headingTextColorNotVisibleComplete;
        }

    } else {
        //at least one row in the section is not complete
        if (sectionView.highlighted)
        {
            return self.headingTextColorVisibleNotComplete;
        } else {
            return self.headingTextColorNotVisibleNotComplete;
        }
    }
}

- (void) sectionTouched:(id)sender
{
    //calls to scroll the tableview to the corresponding section that has been touched
    TNSectionView *sectionView = (TNSectionView*)sender;
    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionView.sectionNo] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

@end
