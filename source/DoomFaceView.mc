using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.UserProfile;
using Toybox.Activity;

class DoomFaceView extends WatchUi.DataField {
    
    // HR zone timers (in seconds)
    private var zoneTimers = [0, 0, 0, 0, 0, 0];
    private var currentZone = 0;
    private var lastUpdateTime;
    private var hrZones;
    
    // Doom face bitmaps
    private var doomFacesSmall;
    private var doomFacesMedium;
    private var doomFacesLarge;
    
    // Zone threshold (30 seconds)
    private const ZONE_THRESHOLD = 5;
    
    function initialize() {
        DataField.initialize();
        lastUpdateTime = System.getTimer();
        
        // Get user's HR zones
        var profile = UserProfile.getProfile();
        if (profile != null) {
            hrZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_BIKING);
        }
        
        // If no zones defined, use default values
        if (hrZones == null) {
            hrZones = [100, 120, 140, 160, 180, 200];
        }
        hrZones = [100 - 20, 120 - 20, 140 - 20, 160 - 20, 180 - 20, 200 - 20];        
    }
    
    function onLayout(dc) {
        // Load doom face images
        doomFacesSmall = new [6];
        doomFacesSmall[0] = WatchUi.loadResource(Rez.Drawables.DoomFace_1_1); // Normal
        doomFacesSmall[1] = WatchUi.loadResource(Rez.Drawables.DoomFace_1_2); // Slightly stressed
        doomFacesSmall[2] = WatchUi.loadResource(Rez.Drawables.DoomFace_1_3); // Stressed
        doomFacesSmall[3] = WatchUi.loadResource(Rez.Drawables.DoomFace_1_4); // Very stressed
        doomFacesSmall[4] = WatchUi.loadResource(Rez.Drawables.DoomFace_1_5); // Damaged
        doomFacesSmall[5] = WatchUi.loadResource(Rez.Drawables.DoomFace_1_6); // Bloody

        doomFacesMedium = new [6];
        doomFacesMedium[0] = WatchUi.loadResource(Rez.Drawables.DoomFace_2_1); // Normal
        doomFacesMedium[1] = WatchUi.loadResource(Rez.Drawables.DoomFace_2_2); // Slightly stressed
        doomFacesMedium[2] = WatchUi.loadResource(Rez.Drawables.DoomFace_2_3); // Stressed
        doomFacesMedium[3] = WatchUi.loadResource(Rez.Drawables.DoomFace_2_4); // Very stressed
        doomFacesMedium[4] = WatchUi.loadResource(Rez.Drawables.DoomFace_2_5); // Damaged
        doomFacesMedium[5] = WatchUi.loadResource(Rez.Drawables.DoomFace_2_6); // Bloody

        doomFacesLarge = new [6];
        doomFacesLarge[0] = WatchUi.loadResource(Rez.Drawables.DoomFace_3_1); // Normal
        doomFacesLarge[1] = WatchUi.loadResource(Rez.Drawables.DoomFace_3_2); // Slightly stressed
        doomFacesLarge[2] = WatchUi.loadResource(Rez.Drawables.DoomFace_3_3); // Stressed
        doomFacesLarge[3] = WatchUi.loadResource(Rez.Drawables.DoomFace_3_4); // Very stressed
        doomFacesLarge[4] = WatchUi.loadResource(Rez.Drawables.DoomFace_3_5); // Damaged
        doomFacesLarge[5] = WatchUi.loadResource(Rez.Drawables.DoomFace_3_6); // Bloody
    }
    
    function compute(info) {
        if (info has :currentHeartRate && info.currentHeartRate != null) {
            var hr = info.currentHeartRate;
            var newZone = calculateHRZone(hr);
            
            // Update timers
            var currentTime = System.getTimer();
            var deltaTime = (currentTime - lastUpdateTime) / 1000.0; // Convert to seconds
            lastUpdateTime = currentTime;
            
            // Reset other zone timers and update current zone timer
            for (var i = 0; i < 6; i++) {
                if (i == newZone) {
                    zoneTimers[i] += deltaTime;
                } else {
                    zoneTimers[i] = 0;
                }
            }
            
            // Update current zone if threshold met
            if (zoneTimers[newZone] >= ZONE_THRESHOLD) {
                currentZone = newZone;
            }
        }
    }
    
    function calculateHRZone(hr) {
        // Zone 0: Below zone 1
        if (hr < hrZones[0]) {
            return 0;
        }
        // Zones 1-5
        for (var i = 0; i < 5; i++) {
            if (hr < hrZones[i + 1]) {
                return i + 1;
            }
        }
        // Zone 5: Above zone 5 threshold
        return 5;
    }
    
    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.clear();
        
        // Calculate position to center the image
        var width = dc.getWidth();
        var height = dc.getHeight();

        /*         
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height - 20, Graphics.FONT_XTINY, 
                   "W: " + width + " H: " + height, 
                   Graphics.TEXT_JUSTIFY_CENTER);        
        */

        // Draw the appropriate doom face
        if (doomFacesSmall != null && doomFacesSmall[currentZone] != null) {
            var bitmap = null;

            if (height >= 626) {
                bitmap = doomFacesLarge[currentZone];
            }
            else if (height >= 314) {
                bitmap = doomFacesMedium[currentZone];
            } else {
                bitmap = doomFacesSmall[currentZone];
            }

            var bitmapWidth = bitmap.getWidth();
            var bitmapHeight = bitmap.getHeight();
            
            var xPos = (width - bitmapWidth) / 2;
            var yPos = (height - bitmapHeight) / 2;
            
            dc.drawBitmap(xPos, yPos, bitmap);
        }

        // Optional: Draw current HR and zone info (small text at bottom)
        var info = Activity.getActivityInfo();
        if (height >= 626 && info != null && info.currentHeartRate != null) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height - 20, Graphics.FONT_XTINY, 
                       "HR: " + info.currentHeartRate + " Z" + (currentZone + 1), 
                       Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}