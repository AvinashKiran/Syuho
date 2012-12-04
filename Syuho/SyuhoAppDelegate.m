
#import "SyuhoAppDelegate.h"
#import "RootViewController.h"

@implementation SyuhoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //アプリ起動後に呼ばれる

    //表示部分の基礎となるwindow.rootViewControllerに「RootViewController」ってクラスを使うよ宣言

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[RootViewController alloc] init] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    //このクラスが破棄されるときに呼ばれる、このクラス内で作ったインスタンスはここで破棄する
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

//他にもUIApplicationDelegateには色々ある（リモート通知を受けたときの処理とか、バックグラウンドに遷移したときの処理とか）けど、
//特に何もしないんで省略、「UIApplicationDelegate」のメソッドの種類を見たいひとはコマンドキーを押しながらクリックするといいよ

@end
