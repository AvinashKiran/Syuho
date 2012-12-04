
#import "RootViewController.h"
#import "CalendarViewController.h"

@interface RootViewController()
{
    CalendarViewController *cal;
    NSArray *msgArray, *defArray;
}
@end

@implementation RootViewController

- (void)viewDidLoad
{
    //メモリに読み込まれたときに呼ばれる

    [super viewDidLoad];
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];

    //カレンダー表示クラスを作って、クラス変数として保持
    cal = [[CalendarViewController alloc] init];
    cal.view.backgroundColor = [UIColor whiteColor];
    [cal setCalendarViewControllerDelegate:self];

    //ボタン作って画面に貼る、押されたら「btnTapped:」が呼ばれる
    //ボタン一つだけのしょぼい画面、、、週報以外に管理営業とか全社員とか宛て先を変えた機能でも追加すればぁ？
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.center = CGPointMake(160, 240);
    [btn setTitle:@"週　報" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    //設定できる内容と、何も設定してないときの初期値
    msgArray = [[NSArray alloc] initWithObjects:@"To", @"Cc", @"Bcc", @"Name", @"Mail", @"Work Place", @"Project Name", nil];
    defArray = [[NSArray alloc] initWithObjects:@"xxx@yyy.jp", @"", @"", @"XX XX", @"xxx@yyy.jp", @"", @"", nil];
}

- (void)viewDidUnload
{
    //viewDidLoadと名前が似てるけど、対ってわけではない（対っていえそうなのはdealloc）
    //viewDidUnloadはメモリワーニング発生後に呼ばれる可能性のあるメソッド
    
    [msgArray release];msgArray = nil;
    [defArray release];defArray = nil;
    [cal release];cal = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    //viewDidUnloadと大体同じこと書く
    //あっちではreleaseの後でnilの代入が必要
    
    [msgArray release];
    [defArray release];
    [cal release];
    [super dealloc];
}

#pragma mark - CalendarView Delegate

- (void)calendarViewController:(CalendarViewController *)aCalendarViewController dateDidChange:(NSDate *)aDate
{
}

- (void)sendMail:(id)sender
{
    //SENDボタンが押されたらしいのでメール画面をモーダル表示

    //本文つくる
    //テンプレートは面倒なので固定値にしたった
    NSString *template = @"お疲れ様です。%@です。\n\n%@ 〜 %@の週報を送付いたします。\n\n****************************************\n\n□ 氏　　名：%@ %@\n\n□ 作業場所：%@\n\n□ ＰＪ概要：%@\n\n■ 勤務時間\n%@\n■ 作業実績\n\n■ 業務上の課題/解決案\n\n■ 次週の予定\n\n■ その他報告事項\n";
    NSString *bodyStr = [NSString stringWithFormat:template,
                         [STD_DEFAULTS objectForKey:@"Name"],
                         [STD_DEFAULTS objectForKey:@"FirstDay"],
                         [STD_DEFAULTS objectForKey:@"LastDay"],
                         [STD_DEFAULTS objectForKey:@"Name"],[STD_DEFAULTS objectForKey:@"Mail"],
                         [STD_DEFAULTS objectForKey:@"Work Place"],
                         [STD_DEFAULTS objectForKey:@"Project Name"],
                         [STD_DEFAULTS objectForKey:@"WorkingTime"]];

    //いでよ、モーダル
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    mailCompose.mailComposeDelegate = self;
    [mailCompose setToRecipients :[NSArray arrayWithObjects:[STD_DEFAULTS objectForKey:@"To"], nil]];
    [mailCompose setCcRecipients :[NSArray arrayWithObjects:[STD_DEFAULTS objectForKey:@"Cc"], nil]];
    [mailCompose setBccRecipients:[NSArray arrayWithObjects:[STD_DEFAULTS objectForKey:@"Bcc"], nil]];
    [mailCompose setSubject:[STD_DEFAULTS objectForKey:@"Subject"]];
    [mailCompose setMessageBody:bodyStr isHTML:FALSE];
    [self presentModalViewController:mailCompose animated:TRUE];
    [mailCompose release];
}

//アラートを繰り返しだすので、出した回数をカウント
int repeatCount = 0;

- (void)settingMail:(id)sender
{
    //SETTINGが押されたらしいので、アラートを繰り返しだすことでメールの設定ができるシステム
    //決してviewControllerを作るのが面倒だったわけではない

    if (repeatCount >= [msgArray count])
    {
        repeatCount = 0;
        return;
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setting"
            message:[msgArray objectAtIndex:repeatCount]
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    NSString *str = ([[STD_DEFAULTS objectForKey:[msgArray objectAtIndex:repeatCount]] length] != 0)?
       [STD_DEFAULTS objectForKey:[msgArray objectAtIndex:repeatCount]]:[defArray objectAtIndex:repeatCount];
    [alert textFieldAtIndex:0].text = str;
    [alert show];
    [alert release];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //アラートで何かしらのボタンが押された

    if (buttonIndex != 0)
    {
        //OKが押されたら内容をUserDefaultsに保存、そして次のアラートを表示
        NSString *input = [alertView textFieldAtIndex:0].text;
        [STD_DEFAULTS setObject:input forKey:[msgArray objectAtIndex:repeatCount++]];
        [self settingMail:nil];
    }
    else
    {
        //キャンセルが押されたら繰り返しカウンタをリセット
        repeatCount = 0;
    }
}

#pragma mark - User Interaction

- (void)btnTapped:(id)sender
{
    //「cal」って名前のviewControllerを自分の前面にモーダル表示

    [self presentModalViewController:cal animated:TRUE];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //メール処理完了したのでモーダルを消す

    [self dismissModalViewControllerAnimated:TRUE];
}

@end
