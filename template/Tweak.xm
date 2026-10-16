#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <string.h>
#import "Macros.h"

// Auf 0 setzen, falls das Spiel nach dem Start abstuerzt (schaltet den Speedhack aus)
#define ENABLE_SPEED_HOOK 1

// Globale Variable aus Menu.mm (der schwebende Menue-Button)
extern UIButton *menuButton;

// ---------- Basisadresse eines geladenen Images ----------
static uintptr_t getImageBase(const char *name) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *n = _dyld_get_image_name(i);
        if (n && strstr(n, name)) {
            return (uintptr_t)_dyld_get_image_header(i);
        }
    }
    return 0;
}

// ================== SPEEDHACK HOOK ==================
static void (*orig_SetCurrentSpeed)(void *self, float speed, void *mech);

static void hook_SetCurrentSpeed(void *self, float speed, void *mech) {
    float mult = [[switches getValueFromSwitch:NSSENCRYPT("Mech Speed Multiplikator")] floatValue];
    if (mult > 1.0f) {
        speed *= mult;
    }
    orig_SetCurrentSpeed(self, speed, mech);
}

static void installSpeedHook() {
    uintptr_t base = getImageBase("UnityFramework");
    if (base) {
        MSHookFunction((void *)(base + 0x4B15B1C),
                       (void *)hook_SetCurrentSpeed,
                       (void **)&orig_SetCurrentSpeed);
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            installSpeedHook();
        });
    }
}

/***********************************************************
   INSIDE THE FUNCTION BELOW YOU'LL HAVE TO ADD YOUR SWITCHES!
***********************************************************/
void setup() {

  [switches addOffsetSwitch:NSSENCRYPT("Kein Nachladen")
    description:NSSENCRYPT("Blockiert das Nachladen der Waffe")
    offsets: {
      ENCRYPTOFFSET("0x4ADCA10"),
      ENCRYPTOFFSET("0x4ADE150")
    }
    bytes: {
      ENCRYPTHEX("C0035FD6"),
      ENCRYPTHEX("C0035FD6")
    }
  ];

  [switches addSliderSwitch:NSSENCRYPT("Mech Speed Multiplikator")
    description:NSSENCRYPT("Erhoeht die Bewegungsgeschwindigkeit des Mechs")
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

  // Muss VOR setup() gesetzt werden, weil die Patches es dort brauchen
  [menu setFrameworkName:"UnityFramework"];

  // Sichtbarer Menue-Button ohne Base64-Bild
  if (menuButton) {
    menuButton.backgroundColor = UIColorFromHex(0xBD0000);
    menuButton.layer.cornerRadius = 25;
    menuButton.layer.borderWidth = 2;
    menuButton.layer.borderColor = [UIColor whiteColor].CGColor;
    menuButton.clipsToBounds = YES;
    [menuButton setTitle:@"M" forState:UIControlStateNormal];
    [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }

#if ENABLE_SPEED_HOOK
  installSpeedHook();
#endif
}

// ================== START DES MENUES ==================
static bool menuStarted = false;

static void tryStartMenu(int attempt) {
    if (menuStarted) return;

    // Warten, bis das Spiel ein Fenster hat (max. ca. 30 Sekunden)
    UIWindow *w = [UIApplication sharedApplication].keyWindow;
    if (w == nil && attempt < 30) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC),
                       dispatch_get_main_queue(), ^{
            tryStartMenu(attempt + 1);
        });
        return;
    }

    menuStarted = true;
    setupMenu();   // erst das Menue erzeugen
    setup();       // dann die Schalter hinzufuegen
}

__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{
        tryStartMenu(0);
    });
}
