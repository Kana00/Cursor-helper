CTrackMania @app = cast<CTrackMania>(GetApp());

// Main entry point. Yieldable.
void Main() {
    // clean the console
    // printSpaceToConsole();
    while (app is null)
    {
        if (app !is null)
        {
            @app = cast<CTrackMania>(GetApp());
            break;
        }
        yield();
    }

    if(centralCursor !is null) {
        centralCursor.deserializeAndReadSettings();
    }
}

// Render function called every frame intended only for menu items in the main menu of the UI.
void RenderMenuMain() {
    bool appIsNotReadyToRenderMenu = app is null
     || app.CurrentPlayground is null
     || app.CurrentPlayground.GameTerminals.Length == 0
     || app.CurrentPlayground.GameTerminals[0].GUIPlayer is null
     || app.LoadedManiaTitle is null;

    if (appIsNotReadyToRenderMenu) return;

    if (menuItems !is null) {
        menuItems.drawMenus();
    }
}

// Render function called every frame intended for UI.
void RenderInterface() {
    // only for windows
    if(centralCursor !is null) {
        centralCursor.drawWindowSettings();
    }
}

// array<float> velocityHistory;
// int maximumVelocityHistorySize = 10000;
// Called every frame. delta is the delta time (milliseconds since last frame).
auto@ sample = Audio::LoadSample("src/assets/sounds/Sweep_Tone.ogg", false);
auto@ voice = Audio::Start(sample);
void Update(float delta) {
    bool appIsNotReadyToRenderMenu = app is null
     || app.CurrentPlayground is null
     || app.CurrentPlayground.GameTerminals.Length == 0
     || app.CurrentPlayground.GameTerminals[0].GUIPlayer is null
     || app.LoadedManiaTitle is null;

    if (appIsNotReadyToRenderMenu) return;

    centralCursor.drawCursor(delta);
}

void OnDisabled() {
    // prevent leak memory
    voice.Play();
    voice.SetPosition(voice.GetLength());
}

void OnDestroyed() {
    // prevent leak memory
    voice.Play();
    voice.SetPosition(voice.GetLength());
}
