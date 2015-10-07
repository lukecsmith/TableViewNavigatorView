# TableViewNavigatorView
Allows quick navigation around a tableview, shows you where you are in the table, and shows completion status of rows and sections.

`TableviewNavigatorView' is a subclass of `UIView' and is intended to both show a complete visual representation of the contents of a tableview, and to allow quick navigation around it.  Both the sections and rows of a UITableview are all represented by visual objects that have 3 purposes - represent each row with an item, allow the clicking on the row icon to scroll the tableview to that row, and also to represent a completion status for the row if that is required.  The rows are also highlighted to show whether they are currently visible in the main tableview.  Integration and use is designed to be as simple as possible with an existing tableview.  Row objects are contained within section objects, which can also represent the completion status of that section if required.

  - To use, first copy all the files from this library into your app.
  - Create a view somewhere in your storyboard or nib, in a suitable place next to the UITableView that you will be navigating, and set the class type of the view to TableviewNavigatorView
  - Then create a property of type TableviewNavigatorView within your UITableView class - or at least in a place where your UITableView can access it.  Obviously if using storyboard or nib, drag the new object across to its class to create the property.
  - Have a method you call to refresh the UITableView (ie calling reloadData on the tableview).  Within that same method, also build the navigator view, something like this : 
  
  [self.tableviewNavigatorView buildNavigatorWithTableview:(my tableview) headingsShown:(Yes or No)];
  
  - Add the following method to the tableview class to get the navigator to show items that are on / off screen while scrolling :
  
   - (void) scrollViewDidScroll:(UIScrollView *)scrollView
 {
    [self.tableviewNavigatorView visibleCellsChanged];
 }
 
  - You can change the colour scheme on rows depending on a 'complete' status, and the row is updated using the following call : - (void) setRowAtIndexPath:(NSIndexPath*)indexPath asComplete:(BOOL)complete;
  
  - You can also refresh the colours of the section text objects with the following call :
  
  - (void) refreshSectionTextColours;
  
   - Dont forget to set the colour properties in the TableviewNavigatorView header file.
   
   
 