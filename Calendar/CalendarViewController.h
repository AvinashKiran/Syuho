
#import "CalendarLogicDelegate.h"
#import "CalendarViewControllerDelegate.h"

@class CalendarLogic;
@class CalendarMonth;

@interface CalendarViewController : UIViewController
<CalendarLogicDelegate, UIActionSheetDelegate,
UIPickerViewDelegate, UIPickerViewDataSource>
{
	id calendarViewControllerDelegate;	
	CalendarLogic *calendarLogic;
	CalendarMonth *calendarView;
	CalendarMonth *calendarViewNew;
	NSDate *selectedDate;
	UIButton *leftButton;
	UIButton *rightButton;
}

@property (nonatomic, assign) id calendarViewControllerDelegate;
@property (nonatomic, retain) CalendarLogic *calendarLogic;
@property (nonatomic, retain) CalendarMonth *calendarView;
@property (nonatomic, retain) CalendarMonth *calendarViewNew;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) UIButton *leftButton;
@property (nonatomic, retain) UIButton *rightButton;

- (void)animationMonthSlideComplete;

@end

