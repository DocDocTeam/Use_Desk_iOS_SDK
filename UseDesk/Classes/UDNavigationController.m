

#import "UDNavigationController.h"
#import "Settings.h"

@implementation UDNavigationController

@synthesize barTintColor;
@synthesize tintColor;
@synthesize titleTextAttributes;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationBar.translucent = NO;
    
    self.tintColor = (self.tintColor != nil) ? self.tintColor : navBarTextColor;
    
    self.titleTextAttributes = (self.titleTextAttributes != nil) ? self.titleTextAttributes : navBarTextColor;

    self.barTintColor = (self.barTintColor != nil) ? self.barTintColor : navBarBackgroundColor;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return UIStatusBarStyleLightContent;
}

-(void)setTintColor:(UIColor *)__tintColor{
    tintColor = __tintColor;
    self.navigationBar.tintColor = tintColor;
}

-(void)setBarTintColor:(UIColor *)__barTintColor{
    barTintColor = __barTintColor;
    if (@available(iOS 13, *)) {
        UINavigationBarAppearance *appearance = self.navigationBar.standardAppearance.copy;
        appearance.backgroundColor = barTintColor;
        self.navigationBar.standardAppearance = appearance;
    } else {
        self.navigationBar.barTintColor = barTintColor;
    }
}

-(void)setTitleTextAttributes:(UIColor *)__titleTextAttributes{
    titleTextAttributes = __titleTextAttributes;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:titleTextAttributes};
}

@end
