
#import "SyuhoAppDelegate.h"

int main(int argc, char *argv[])
{
    //C、C++、Objective-Cのプログラムは基本、main関数から始まる

    @autoreleasepool
    {
        //アプリの処理は「SyuhoAppDelegate」ってクラスでやりますよって宣言（第１、２、３引き数は定例）
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([SyuhoAppDelegate class]));
    }
}
