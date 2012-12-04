
#import "CalendarViewController.h"
#import "CalendarLogic.h"
#import "CalendarMonth.h"

@interface CalendarViewController()
{
    NSArray *inputTimeArray;
    NSDictionary *weekDic;
    NSMutableDictionary *reportDic;
    UIActionSheet *as;
    UIPickerView *startTimePicker, *endTimePicker;
    int start, end;
    NSDate *currentDate;
    UITextView *tv;
    UILabel *interval;
}
- (NSString *)calcInterval:(int)start:(int)end;
- (void)setSelectedDate:(NSDate *)aDate;
@end

@implementation CalendarViewController

//ネットで拾てきたソース、そのまんまのとこがあるから多少ぐっちゃぐちゃ

@synthesize calendarViewControllerDelegate, calendarLogic, calendarView;
@synthesize calendarViewNew, selectedDate, leftButton, rightButton;

#pragma mark - View Lifecycle

- (void)dealloc
{
    [tv release];
    [inputTimeArray release];
    [weekDic release];
    [reportDic release];
    [startTimePicker release];
    [endTimePicker release];
    [as release];
	self.calendarViewControllerDelegate = nil;
	self.calendarLogic.calendarLogicDelegate = nil;
	self.calendarLogic = nil;
	self.calendarView = nil;
	self.calendarViewNew = nil;
	self.selectedDate = nil;
	self.leftButton = nil;
	self.rightButton = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    //メモリ上に読み込まれたときに呼ばれる

    [super viewDidLoad];	

    //この辺はネットから拾ってきたまんま
	self.title = NSLocalizedString(@"Calendar", @"");
	self.view.bounds = CGRectMake(0, 0, 320, 324);
	self.view.clearsContextBeforeDrawing = NO;
	self.view.opaque = YES;
	self.view.clipsToBounds = NO;

    //日付の計算とかやね
	NSDate *aDate = selectedDate;
	if (aDate == nil)
		aDate = [CalendarLogic dateForToday];
	CalendarLogic *aCalendarLogic = [[CalendarLogic alloc] initWithDelegate:self referenceDate:aDate];
	self.calendarLogic = aCalendarLogic;
	[aCalendarLogic release];

    //カレンダーの表示部分、ボタンとか
	UIBarButtonItem *aClearButton = [[UIBarButtonItem alloc] 
									 initWithTitle:NSLocalizedString(@"Clear", @"") style:UIBarButtonItemStylePlain
									 target:self action:@selector(actionClearDate:)];
	self.navigationItem.rightBarButtonItem = aClearButton;
	[aClearButton release];
	CalendarMonth *aCalendarView = [[CalendarMonth alloc] initWithFrame:CGRectMake(0, 0, 320, 324) logic:calendarLogic];
	[aCalendarView selectButtonForDate:selectedDate];
	[self.view addSubview:aCalendarView];
	self.calendarView = aCalendarView;
	[aCalendarView release];
	UIButton *aLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	aLeftButton.frame = CGRectMake(0, 0, 60, 60);
	aLeftButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 20);
	[aLeftButton setImage:[UIImage imageNamed:@"CalendarArrowLeft.png"] forState:UIControlStateNormal];
	[aLeftButton addTarget:calendarLogic 
					action:@selector(selectPreviousMonth) 
		  forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:aLeftButton];
	self.leftButton = aLeftButton;
	UIButton *aRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	aRightButton.frame = CGRectMake(260, 0, 60, 60);
	aRightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 20, 0);
	[aRightButton setImage:[UIImage imageNamed:@"CalendarArrowRight.png"] forState:UIControlStateNormal];
	[aRightButton addTarget:calendarLogic 
					 action:@selector(selectNextMonth) 
		   forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:aRightButton];
	self.rightButton = aRightButton;

    //入力結果を表示させるテキストビューを追加、カレンダーの下の部分ね
    tv = [[UITextView alloc] initWithFrame:CGRectMake(0, 324, 220, 480-20-324)];
    tv.font = [UIFont systemFontOfSize:14];
    tv.contentSize = CGSizeMake(320, 480);
    tv.editable = FALSE;
    [self.view addSubview:tv];

    //時間と曜日用の配列と連想配列、ピッカーのデータとして使う、曜日は 英語表記➡日本語表記 変換用
    inputTimeArray = [[NSArray alloc] initWithObjects:@"00:00", @"00:15", @"00:30", @"00:45", @"01:00", @"01:15", @"01:30", @"01:45", @"02:00", @"02:15", @"02:30", @"02:45", @"03:00", @"03:15", @"03:30", @"03:45", @"04:00", @"04:15", @"04:30", @"04:45", @"05:00", @"05:15", @"05:30", @"05:45", @"06:00", @"06:15", @"06:30", @"06:45", @"07:00", @"07:15", @"07:30", @"07:45", @"08:00", @"08:15", @"08:30", @"08:45", @"09:00", @"09:15", @"09:30", @"09:45", @"10:00", @"10:15", @"10:30", @"10:45", @"11:00", @"11:15", @"11:30", @"11:45", @"12:00", @"12:15", @"12:30", @"12:45", @"13:00", @"13:15", @"13:30", @"13:45", @"14:00", @"14:15", @"14:30", @"14:45", @"15:00", @"15:15", @"15:30", @"15:45", @"16:00", @"16:15", @"16:30", @"16:45", @"17:00", @"17:15", @"17:30", @"17:45", @"18:00", @"18:15", @"18:30", @"18:45", @"19:00", @"19:15", @"19:30", @"19:45", @"20:00", @"20:15", @"20:30", @"20:45", @"21:00", @"21:15", @"21:30", @"21:45", @"22:00", @"22:15", @"22:30", @"22:45", @"23:00", @"23:15", @"23:30", @"23:45", nil];
    weekDic = [[NSDictionary alloc] initWithObjectsAndKeys:@"日", @"Sun", @"月", @"Mon", @"火", @"Tue",
               @"水",@"Wed", @"木", @"Thu", @"金", @"Fri", @"土", @"Sat", nil];
    reportDic = [[NSMutableDictionary alloc] init];

    //開始時間と終了時間を選択するピッカー、アクションシートに貼る
    startTimePicker = [[UIPickerView alloc] init];
    startTimePicker.tag = 1;
    startTimePicker.frame = CGRectMake(35, 55, 120, 200);
    startTimePicker.delegate = self;
    startTimePicker.dataSource = self;
    startTimePicker.showsSelectionIndicator = TRUE;
    [startTimePicker selectRow:36 inComponent:0 animated:FALSE];
    start = 36;
    endTimePicker = [[UIPickerView alloc] init];
    endTimePicker.tag = 2;
    endTimePicker.frame = CGRectMake(165, 55, 120, 200);
    endTimePicker.delegate = self;
    endTimePicker.dataSource = self;
    endTimePicker.showsSelectionIndicator = TRUE;
    [endTimePicker selectRow:72 inComponent:0 animated:FALSE];
    end = 72;

    //日付を選択したときに表示させるアクションシート
    as = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel"
                       destructiveButtonTitle:nil otherButtonTitles:@"Done", nil];

    //アクションシートにラベルとかピッカーとか貼り付ける
    [as addSubview:startTimePicker];
    [as addSubview:endTimePicker];
    UILabel *label;
    label= [[UILabel alloc] init];
    label.frame = CGRectMake(35, 38, 120, 16);
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"start";
    [as addSubview:label];
    [label release];
    label = [[UILabel alloc] init];
    label.frame = CGRectMake(165, 38, 120, 16);
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"end";
    [as addSubview:label];
    [label release];
    interval = [[UILabel alloc] init];
    interval.frame = CGRectMake(100, 240, 120, 16);
    interval.textAlignment = UITextAlignmentCenter;
    interval.backgroundColor = [UIColor clearColor];
    interval.textColor = [UIColor whiteColor];
    interval.text = @"09:00";
    [as addSubview:interval];

    //戻るボタンとか
    UIButton *settingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    settingBtn.frame = CGRectMake(220, 335, 90, 30);
    [settingBtn setTitle:@"SETTING" forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingMail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendBtn.frame = CGRectMake(220, 378, 90, 30);
    [sendBtn setTitle:@"SEND" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMail:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendBtn];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(220, 420, 90, 30);
    [backBtn setTitle:@"BACK" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    currentDate = nil;
}

- (void)viewDidUnload
{
    [tv release];tv = nil;
    [inputTimeArray release];inputTimeArray = nil;
    [weekDic release];weekDic = nil;
    [reportDic release];reportDic = nil;
    [startTimePicker release];startTimePicker = nil;
    [endTimePicker release];endTimePicker = nil;
    [as release];as = nil;
	self.calendarLogic.calendarLogicDelegate = nil;
	self.calendarLogic = nil;
	self.calendarView = nil;
	self.calendarViewNew = nil;
	self.selectedDate = nil;
	self.leftButton = nil;
	self.rightButton = nil;
}

- (CGSize)contentSizeForViewInPopoverView
{
	return CGSizeMake(320, 324);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - UI events

- (void)actionClearDate:(id)sender
{
	self.selectedDate = nil;
	[calendarView selectButtonForDate:nil];
}

- (void)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
}

- (void)settingMail:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
    [calendarViewControllerDelegate settingMail:sender];
}

- (void)sendMail:(id)sender
{
    [self dismissModalViewControllerAnimated:TRUE];
    [calendarViewControllerDelegate performSelector:@selector(sendMail:) withObject:sender afterDelay:0.5f];
}

#pragma mark - CalendarLogic delegate

- (void)calendarLogic:(CalendarLogic *)aLogic dateSelected:(NSDate *)aDate
{
	[selectedDate autorelease];
	selectedDate = [aDate retain];
	
	if ([calendarLogic distanceOfDateFromCurrentMonth:selectedDate] == 0) {
		[calendarView selectButtonForDate:selectedDate];
	}

    //カレンダーの日付が選択されたらアクションシートを表示させる
    [currentDate release];
    currentDate = [aDate retain];
    NSDateFormatter *fmt1 = [[[NSDateFormatter alloc] init] autorelease];
    fmt1.dateFormat = @"yyyy/MM/dd";
    NSDateFormatter *fmt2 = [[[NSDateFormatter alloc] init] autorelease];
    fmt2.dateFormat = @"EEE";

    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"locale : %@",locale);
    
    as.title = [NSString stringWithFormat:@"%@(%@)\n\n\n\n\n\n\n\n\n\n\n\n\n",[fmt1 stringFromDate:aDate],
        ([locale isEqualToString:@"ja_JP"])?[fmt2 stringFromDate:aDate]:[weekDic objectForKey:[fmt2 stringFromDate:aDate]]];
    [as showInView:self.view];
}

- (void)calendarLogic:(CalendarLogic *)aLogic monthChangeDirection:(NSInteger)aDirection
{
	BOOL animate = self.isViewLoaded;
	
	CGFloat distance = 320;
	if (aDirection < 0) {
		distance = -distance;
	}
	
	leftButton.userInteractionEnabled = NO;
	rightButton.userInteractionEnabled = NO;
	
	CalendarMonth *aCalendarView = [[CalendarMonth alloc] initWithFrame:CGRectMake(distance, 0, 320, 308) logic:aLogic];
	aCalendarView.userInteractionEnabled = NO;
	if ([calendarLogic distanceOfDateFromCurrentMonth:selectedDate] == 0) {
		[aCalendarView selectButtonForDate:selectedDate];
	}
	[self.view insertSubview:aCalendarView belowSubview:calendarView];
	
	self.calendarViewNew = aCalendarView;
	[aCalendarView release];
	
	if (animate) {
		[UIView beginAnimations:NULL context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationMonthSlideComplete)];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}
	
	calendarView.frame = CGRectOffset(calendarView.frame, -distance, 0);
	aCalendarView.frame = CGRectOffset(aCalendarView.frame, -distance, 0);
	
	if (animate) {
		[UIView commitAnimations];
		
	} else {
		[self animationMonthSlideComplete];
	}
}

- (void)animationMonthSlideComplete
{
	[calendarView removeFromSuperview];
	self.calendarView = calendarViewNew;
	self.calendarViewNew = nil;
	leftButton.userInteractionEnabled = YES;
	rightButton.userInteractionEnabled = YES;
	calendarView.userInteractionEnabled = YES;
}

#pragma mark - ActionSheet Delegate

//年は別で保存してみる
int year = INT_MAX;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //アクションシートのボタンが押されたときに呼ばれる
    //「OK」が押されてたらテキストビューの内容を更新、内容をUserDefaultsに保存する

    switch (buttonIndex)
    {
        case 0:
            [reportDic setObject:[NSString stringWithFormat:@"%@ ~ %@ [%@]\n",
                  [inputTimeArray objectAtIndex:start], [inputTimeArray objectAtIndex:end], [self calcInterval:start :end]]
                     forKey:[[as.title substringWithRange:NSMakeRange(5, [as.title length]-5)] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
            if (year > [[as.title substringWithRange:NSMakeRange(0, 4)] intValue])
                year = [[as.title substringWithRange:NSMakeRange(0, 4)] intValue];
            break;
        case 1:
            [reportDic removeObjectForKey:[[as.title substringWithRange:NSMakeRange(5, [as.title length]-5)] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        default:
            break;
    }

    NSString *reportString = @"";
    int sumHour = 0, sumMin = 0, firstDay = 0;
    NSArray *array = [[reportDic allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (id key in array)
    {
        if (firstDay == 0)
        {
            [STD_DEFAULTS setObject:[NSString stringWithFormat:@"%04d%02d%02d %@",year,
                 [[key substringWithRange:NSMakeRange(0, 2)] intValue],
                 [[key substringWithRange:NSMakeRange(3, 2)] intValue],
                 [STD_DEFAULTS objectForKey:@"Name"]] forKey:@"Subject"];
            [STD_DEFAULTS setObject:[key substringWithRange:NSMakeRange(0, 5)] forKey:@"FirstDay"];
        }
        firstDay++;
        if (firstDay == [array count])
        {
            [STD_DEFAULTS setObject:[key substringWithRange:NSMakeRange(0, 5)] forKey:@"LastDay"];
        }
        reportString = [reportString stringByAppendingString:
                        [NSString stringWithFormat:@"%@ %@",key ,[reportDic objectForKey:key]]];
        sumHour += [[[reportDic objectForKey:key] substringWithRange:NSMakeRange(15, 2)] intValue];
        sumMin  += [[[reportDic objectForKey:key] substringWithRange:NSMakeRange(18, 2)] intValue];
    }
    if (sumMin > 59)
    {
        sumHour += sumMin  / 60;
        sumMin  -= (sumMin  / 60) * 60;
    }
    if ([reportString length] > 0)
        reportString = [reportString stringByAppendingString:
                    [NSString stringWithFormat:@"合　計：[%02d:%02d]\n",sumHour,sumMin]];
    tv.text = reportString;
    [STD_DEFAULTS setObject:reportString forKey:@"WorkingTime"];
}

#pragma mark - PickerView DataSource, Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //ピッカーに表示する列数

    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //ピッカーに表示する行数
    
    return [inputTimeArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //ピッカーに表示する内容

    return [inputTimeArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //ピッカーの値が変更された時に呼ばれる
    //値を保持（選択してる要素番号）して、間の時間を更新する

    switch (pickerView.tag)
    {
        case 1:start = row;break;
        case 2:end   = row;break;
        default:break;
    }
    interval.text = [self calcInterval:start :end];
}

#pragma mark - Private Method

- (void)setSelectedDate:(NSDate *)aDate
{
	[selectedDate autorelease];
	selectedDate = [aDate retain];
	[calendarLogic setReferenceDate:aDate];
	[calendarView selectButtonForDate:aDate];
}

- (NSString *)calcInterval:(int)si:(int)ei
{
    //「xx:xx」から「yy:yy」までの時間を「zz:zz」の形で返す汎用性の無いメソッド、雑な計算
    //引数si、eiでinputTimeArrayの要素番号を指定

    int hour, min;

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    formatter.dateFormat = @"HH:mm";
    NSDate *sd = [formatter dateFromString:[inputTimeArray objectAtIndex:si]];
    NSDate *ed = [formatter dateFromString:[inputTimeArray objectAtIndex:ei]];
    if ((int)[ed timeIntervalSinceDate:sd] != 0)
    {
        int x = [ed timeIntervalSinceDate:sd];
        hour = (x!=0)?x / 3600:0;
        min  = (x - hour * 3600) / 60;
    }
    else
    {
        return @"00:00";
    }
    if (hour < 0 || min < 0)
    {
        ed = [ed dateByAddingTimeInterval:24*60*60];
        int x = [ed timeIntervalSinceDate:sd];
        hour = (x!=0)?x / 3600:0;
        min  = (x - hour * 3600) / 60;
    }
    return [NSString stringWithFormat:@"%02d:%02d",hour,min];
}

@end
