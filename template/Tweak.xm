#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <string.h>
#import <stdio.h>
#import "Macros.h"

extern UIButton *menuButton;

static uintptr_t getImageBase(const char *name) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *n = _dyld_get_image_name(i);
        if (n && strstr(n, name)) {
            return (uintptr_t)_dyld_get_image_header(i);
        }
    }
    return 0;
}

static void showStatus(NSString *text) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        UILabel *l = (UILabel *)[w viewWithTag:9191];
        if (!l) {
            l = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, w.bounds.size.width - 20, 130)];
            l.tag = 9191;
            l.numberOfLines = 0;
            l.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            l.textColor = [UIColor greenColor];
            l.font = [UIFont boldSystemFontOfSize:13];
            l.userInteractionEnabled = NO;
            [w addSubview:l];
        }
        l.text = text;
        [w bringSubviewToFront:l];
    });
}

static NSString *bytesAt(uintptr_t base, uint64_t off) {
    uint8_t *p = (uint8_t *)(base + off);
    return [NSString stringWithFormat:@"%02X%02X%02X%02X %02X%02X%02X%02X",
            p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]];
}

static void runReadTest() {
    uintptr_t base = getImageBase("UnityFramework");
    if (!base) {
        showStatus(@"Tweak v4: UnityFramework nicht gefunden");
        return;
    }
    showStatus([NSString stringWithFormat:
        @"Tweak v4 (nur lesen)\n4AE5760: %@\n4ADD410: %@\n4AE1494: %@\nGepatcht = 00E4002F C0035FD6",
        bytesAt(base, 0x4AE5760), bytesAt(base, 0x4ADD410), bytesAt(base, 0x4AE1494)]);
}

void setupMenu() {
  menu = [[Menu alloc]
            initWithTitle:NSSENCRYPT("Mech Arena - Mod Menu")
            titleColor:[UIColor whiteColor]
            titleFont:NSSENCRYPT("Copperplate-Bold")
            credits:NSSENCRYPT("Test")
            headerColor:UIColorFromHex(0xBD0000)
            switchOffColor:[UIColor darkGrayColor]
            switchOnColor:UIColorFromHex(0x00ADF2)
            switchTitleFont:NSSENCRYPT("Copperplate-Bold")
            switchTitleColor:[UIColor whiteColor]
            infoButtonColor:UIColorFromHex(0xBD0000)
            maxVisibleSwitches:4
            menuWidth:250
            menuIcon:@""
            menuButton:@""];

  [menu setFrameworkName:"UnityFramework"];

  if (menuButton) {
    menuButton.backgroundColor = UIColorFromHex(0xBD0000);
    menuButton.layer.cornerRadius = 25;
    menuButton.layer.borderWidth = 2;
    menuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    menuButton.clipsToBounds = YES;
    [menuButton setTitle:@"M" forState:UIControlStateNormal];
    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{
      runReadTest();
  });
}

void setup() {
}

static bool menuStarted = false;

static void tryStartMenu(int attempt) {
    if (menuStarted) return;

    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    if (w == nil && attempt < 30) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            tryStartMenu(attempt + 1);
        });
        return;
    }

    menuStarted = true;
    setupMenu();
    setup();
}

__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        tryStartMenu(0);
    });
}
