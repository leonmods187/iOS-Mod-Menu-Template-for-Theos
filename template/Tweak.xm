#import "Macros.h"

// ================== SPEEDHACK HOOK ==================
static void (*orig_SetCurrentSpeed)(void* self, float speed, void* mech);

static void hook_SetCurrentSpeed(void* self, float speed, void* mech) {
    // Live den Slider-Wert abfragen
    float mult = [[switches getValueFromSwitch:NSSENCRYPT("Mech Speed Multiplikator")] floatValue];
    if (mult > 1.0f) {
        speed *= mult;
    }
    orig_SetCurrentSpeed(self, speed, mech);
}

/***********************************************************
   INSIDE THE FUNCTION BELOW YOU'LL HAVE TO ADD YOUR SWITCHES!
***********************************************************/
void setup() {

  // --- No Reload / Unendlich Munition ---
  [switches addOffsetSwitch:NSSENCRYPT("Kein Nachladen")
    description:NSSENCRYPT("Blockiert das Nachladen der Waffe")
    offsets: {
      ENCRYPTOFFSET("0x4ADCA10"),   // TryStartReload
      ENCRYPTOFFSET("0x4ADE150")    // TryForceReload
    }
    bytes: {
      ENCRYPTHEX("C0035FD6"),
      ENCRYPTHEX("C0035FD6")
    }
  ];

  // --- Slider für Speedhack (mit Hook unten verknüpft!) ---
  [switches addSliderSwitch:NSSENCRYPT("Mech Speed Multiplikator")
    description:NSSENCRYPT("Erhöht die Bewegungsgeschwindigkeit des Mechs (VORSICHT in PvP!)")
    minimumValue:1.0
    maximumValue:3.0
    sliderColor:UIColorFromHex(0xBD0000)
  ];
}

void setupMenu() {

  // ⬇⬇⬇ DER WICHTIGSTE FIX: Framework setzen! ⬇⬇⬇
  [menu setFrameworkName:"UnityFramework"];

  // Speedhook installieren (Base von UnityFramework + Offset)
  uintptr_t speedAddr = (uintptr_t)KittyMemory::getBaseAddress("UnityFramework") + 0x4B15B1C;
  MSHookFunction((void*)speedAddr, (void*)hook_SetCurrentSpeed, (void**)&orig_SetCurrentSpeed);

  menu = [[Menu alloc]  
            initWithTitle:NSSENCRYPT("Mech Arena - Mod Menu")
            titleColor:[UIColor whiteColor]
            titleFont:NSSENCRYPT("Copperplate-Bold")
            credits:NSSENCRYPT("Mod Menu eingerichtet für Mech Arena.\n\nViel Spaß!")
            headerColor:UIColorFromHex(0xBD0000)
            switchOffColor:[UIColor darkGrayColor]
            switchOnColor:UIColorFromHex(0x00ADF2)
            switchTitleFont:NSSENCRYPT("Copperplate-Bold")
            switchTitleColor:[UIColor whiteColor]
            infoButtonColor:UIColorFromHex(0xBD0000)
            maxVisibleSwitches:4
            menuWidth:250
            menuIcon:/* HIER die ORIGINAL-Base64 aus dem Template einsetzen oder @"..." weglassen wenn das Menü das erlaubt */
  ];
}
tcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNS42LWMxNDAgNzkuMTYwNDUxLCAyMDE3LzA1LzA2LTAxOjA4OjIxICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpzdj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+IDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiLz48L3JkZjpJERj48L3g6eG1wbWV0YT48P3hwYWNrZXQgZW5kPSJyIj8+23fSKAAKl10lEQVR4nOz9V6xte5lead3H331v4zXnzj3T5lC5utItk0JCCBBlg6ZtuwSKG6RNEqZt06ZhWbKsB9iQAcGCLNmOATaKjA1211Wn3Lq7Vb3b3W5vO7O2dmf4+Z/hMeece05W5X9V10L1gQYV+973nPOd893f+QzL8oovt+J/V/X7V1V1VVXVVff83sN7l0uSJB95nvXF/33f1bNky5LJ4/JzVpW8f58+d9Ld8f7t9Puvv86J2v79/W///P1yP/j88D7bM//2Y8a//Nff9v/0e/+/lQ9XfL6PqO+3088PfK666iXk91V1fL/+n9/x/P++4p97P+H44uX/f3V8//3/45/7v4//48//Bv8Xf/L+a3X8/4v+u/s3f8f1+32vv//8/1v8v0Xq0jU//8fef1d6t8L3K2Kuv4t05u//u/5F+Pnvv67qXz33+/705v1e93V65/Vuvz33398+/1+7/Pq7vH67q//h7tf79+r7b+L19L3+f2K97n+vv6H38f1+7/Pvv1v87u+uPvev3/fvD68n+8P+p/n8f7uf79//+79fP/H1+v7v337vv//vv0f3/Pq//f38f1+33f7//f3/n2f3Xz9+337//7v+fvvv7r8t+L/+v137v+33f1/7r/f/n+X3P78v+v7v7v6L378/b+7vv+uP//b/b+/+7vfv7f1n+f//u/+vv8v7v7vvv7X/f3/n2f37v7v7v9ff379u//9v7v9//3/7vv7/+t/v7/v37v/9//7v7vv7/+v37/v37v/7v7vv7/+r/v7v7/v7v7vv7/+r/v7v7/v7v7vv7/+r/v7v7/v7v7vv7/+v37v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v";"];
}
