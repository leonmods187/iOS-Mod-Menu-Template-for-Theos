#import <substrate.h>
#import <mach-o/dyld.h>
#import <string.h>
#import "Macros.h"

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
        // UnityFramework noch nicht geladen: in 3 Sekunden nochmal versuchen
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

  [menu setFrameworkName:"UnityFramework"];

  installSpeedHook();
}
