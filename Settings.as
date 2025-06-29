[Setting name="Options as JSON for Cursor" multiline description="\\$f44DON'T\\$fff edit this settings manually. Use the window in the main menu to edit it visually. You can also copy this JSON to share your settings with others."]
string Setting_Cursor = """
{
    "optionTitle": "Cursor",
    "settingsTitle": "Cursor settings",
    "type": "DOT",
    "isCursorShow": true,
    "settingsMustBeShow": false,
    "mustBeHollowed": true,
    "mustDisplaySpeed": true,
    "mustBeInfluencedBySpeed": true,
    "mustShowYaw": true,
    "mustShowYawText": false,
    "mustLiveResetYawAngleByWall": true,
    "yawLines": 4,
    "yamLengthLine": 150,
    "normalScale": 2.4,
    "strokeWidth": 3.0,
    "speedInfluenceFactor": 1.0,
    "updateDisplaySpeedByHz": 7.0,
    "colorSteps": [
        [1.0, 0.0, 0.0, 1.0],
        [1.0, 1.0, 0.0, 1.0],
        [0.0, 1.0, 0.0, 1.0],
        [0.0, 0.0, 1.0, 1.0]
    ],
    "speedSteps": [50, 60, 70, 80],
    "drawSteps": [true, true, true, true],
    "mustPlaySpeedSound": false,
    "volume": 0.5
}
""";
