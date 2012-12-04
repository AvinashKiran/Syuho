
#import <MessageUI/MessageUI.h>
#import "CalendarViewControllerDelegate.h"

@interface RootViewController : UIViewController
<CalendarViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@end
