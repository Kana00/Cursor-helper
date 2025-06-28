CTrackMania @app = cast<CTrackMania>(GetApp());

// Main entry point. Yieldable
void Main() {
    // clean the console
    ClearConsole();
    while (app is null)
    {
        if (app !is null)
        {
            @app = cast<CTrackMania>(GetApp());
            break;
        }
        yield();
    }
}

// Render function called every frame intended only for menu items in the main menu of the UI
void RenderMenuMain() {
    bool appIsNotReadyToRenderMenu = app is null
     || app.CurrentPlayground is null
     || app.CurrentPlayground.GameTerminals.Length == 0
     || app.CurrentPlayground.GameTerminals[0].GUIPlayer is null
     || app.LoadedManiaTitle is null
     || app.LoadedManiaTitle.TitleId != "obstacle@smokegun";

    if (appIsNotReadyToRenderMenu) return;

    if (menuItems !is null) {
        menuItems.drawMenus();
    }
}

// Render function called every frame intended for UI
void RenderInterface() {
    // only for windows
    if(centralCursor !is null) {
        centralCursor.drawWindowSettings();
    }
}

// array<float> velocityHistory;
// int maximumVelocityHistorySize = 10000;
// Called every frame. delta is the delta time (milliseconds since last frame).
void Update(float delta) {
    bool appIsNotReadyToRenderMenu = app is null
     || app.CurrentPlayground is null
     || app.CurrentPlayground.GameTerminals.Length == 0
     || app.CurrentPlayground.GameTerminals[0].GUIPlayer is null
     || app.LoadedManiaTitle is null
     || app.LoadedManiaTitle.TitleId != "obstacle@smokegun";

    if (appIsNotReadyToRenderMenu) return;

    // record the player's position
    // CSmPlayer@ sm_player = cast<CSmPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer);
    // CSmScriptPlayer@ sm_script = sm_player.ScriptAPI;

    // float horizontalVelocity = ConvertMeterPerSecondToKilometerPerHour(Math::Abs(sm_script.Velocity.x + sm_script.Velocity.z));
    // if (velocityHistory.Length >= maximumVelocityHistorySize) {
    //     velocityHistory.RemoveAt(0); // Remove the oldest entry
    // }
    // velocityHistory.InsertLast(velocity);

    centralCursor.drawCursor();
}
