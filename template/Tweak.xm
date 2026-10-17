#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <string.h>
#import <stdio.h>
#import "Macros.h"

#define ENABLE_SPEED_HOOK 0

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

// ===== Statusanzeige oben am Bildschirm (ohne Popup-Fenster) =====
static void showStatus(NSString *text) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *w = [UIApplication sharedApplication].keyWindow;
        if (!w) return;
        UILabel *l = (UILabel *)[w viewWithTag:9191];
        if (!l) {
            l = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, w.bounds.size.width - 20, 110)];
            l.tag = 9191;
            l.numberOfLines = 0;
            l.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
            l.textColor = [UIColor greenColor];
            l.font = [UIFont boldSystemFontOfSize:14];
            l.userInteractionEnabled = NO;
            [w addSubview:l];
        }
        l.text = text;
        [w bringSubviewToFront:l];
    });
}

// ===== Speed: MechView.get_RunSpeed (RVA 0x4A6E6A0) =====
static float (*orig_get_RunSpeed)(void *self);

static float hook_get_RunSpeed(void *self) {
    float v = orig_get_RunSpeed(self);
    float mult = [[switches getValueFromSwitch:NSSENCRYPT("Mech Speed Multiplikator")] floatValue];
    if (mult > 1.0f) {
        v *= mult;
    }
    return v;
}

static void installSpeedHook() {
    uintptr_t base = getImageBase("UnityFramework");
    if (base) {
        MSHookFunction((void *)(base + 0x4A6E6A0),
                       (void *)hook_get_RunSpeed,
                       (void **)&orig_get_RunSpeed);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            installSpeedHook();
        });
    }
}

// ===== Patch-Test: schreibt die vorhandenen Bytes zurueck (aendert nichts) =====
static void runPatchTest() {
    uintptr_t base = getImageBase("UnityFramework");
    if (!base) {
        showStatus(@"Patch-Test: UnityFramework nicht gefunden (Base = 0)");
        return;
    }
    uint8_t *p = (uint8_t *)(base + 0x4ADCA10);   // TryStartReload
    char hex[9];
    snprintf(hex, sizeof(hex), "%02X%02X%02X%02X", p[0], p[1], p[2], p[3]);

    MemoryPatch patch = MemoryPatch::createWithHex("UnityFramework", 0x4ADCA10, std::string(hex));
    bool valid = patch.isValid();
    bool ok = valid ? patch.Modify() : false;

    showStatus([NSString stringWithFormat:@"Tweak v3\nBase: 0x%lx\nBytes: %s\nvalid: %d  Modify: %d",
                (unsigned long)base, hex, valid, ok]);
}

void setup() {

  [switches addOffsetSwitch:NSSENCRYPT("Reload blockieren")
    description:NSSENCRYPT("Blockiert TryStartReload und TryForceReload")
    offsets: {
      ENCRYPTOFFSET("0x4ADCA10"),
      ENCRYPTOFFSET("0x4ADE150")
    }
    bytes: {
      ENCRYPTHEX("C0035FD6"),
      ENCRYPTHEX("C0035FD6")
    }
  ];

  [switches addOffsetSwitch:NSSENCRYPT("Sofort nachladen")
    description:NSSENCRYPT("Setzt die Nachladezeiten auf 0")
    offsets: {
      ENCRYPTOFFSET("0x4AE5760"),
      ENCRYPTOFFSET("0x4ADD410"),
      ENCRYPTOFFSET("0x4AE1494")
    }
    bytes: {
      ENCRYPTHEX("00E4002FC0035FD6"),
      ENCRYPTHEX("00E4002FC0035FD6"),
      ENCRYPTHEX("00E4002FC0035FD6")
    }
  ];

  [switches addOffsetSwitch:NSSENCRYPT("Grosses Magazin")
    description:NSSENCRYPT("Magazingroesse 9999")
    offsets: {
      ENCRYPTOFFSET("0x4ADD0B4")
    }
    bytes: {
      ENCRYPTHEX("E0E18452C0035FD6")
    }
  ];

  [switches addSliderSwitch:NSSENCRYPT("Mech Speed Multiplikator")
    description:NSSENCRYPT("Multipliziert RunSpeed (Wirkung ungetestet)")
    minimumValue:1.0
    maximumValue:3.0
    sliderColor:UIColorFromHex(0xBD0000)
  ];
}

void setupMenu() {

  menu = [[Menu alloc]
            initWithTitle:NSSENCRYPT("Mech Arena - Mod Menu")
            titleColor:[UIColor whiteColor]
            titleFont:NSSENCRYPT("Copperplate-Bold")
            credits:NSSENCRYPT("Mod Menu eingerichtet fuer Mech Arena.\n\nViel Spass!")
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

  // Sofort anzeigen: beweist, dass diese Version laeuft
  showStatus(@"Tweak v3 geladen");

  // Patch-Test nach 6 Sekunden
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 6 * NSEC_PER_SEC),
                 dispatch_get_main_queue(), ^{
      runPatchTest();
  });

#if ENABLE_SPEED_HOOK
  installSpeedHook();
#endif
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
