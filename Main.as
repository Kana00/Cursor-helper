CTrackMania @app = cast<CTrackMania>(GetApp());

void Main() {
    while (app is null)
    {
        if (app !is null)
        {
            @app = cast<CTrackMania>(GetApp());
            break;
        }
        yield();
    }

    print("Obstacle analysis loaded successfully!");

    // auto audioPort = app.AudioPort;
    // for (uint i = 0; i < audioPort.Sources.Length; i++) {
    //     auto source = audioPort.Sources[i];

    //     // Get the sound that the source can play
    //     auto sound = source.PlugSound;

    //     // Check if its file is an .ogg file
    //     if (cast<CPlugFileOggVorbis>(sound.PlugFile) is null) {
    //         // Skip if it's not an ogg file
    //         continue;
    //     }

    //     source.Pitch = 0.3f;
    // }
}

void RenderInterface() {
    if (app is null || app.LoadedManiaTitle.TitleId != "obstacle@smokegun") return;
    CSmPlayer@ sm_player = cast<CSmPlayer>(app.CurrentPlayground.GameTerminals[0].GUIPlayer);
    CSmScriptPlayer@ sm_script = sm_player.ScriptAPI;
    float hspeed = Math::Sqrt(sm_script.Velocity.x*sm_script.Velocity.x + sm_script.Velocity.z*sm_script.Velocity.z);
    float horizontalVelocity = Math::Floor(hspeed * 36) / 10;
    print(horizontalVelocity);
    // record the horizontal velocity in history with a maximum of entries (cache)
    velocityHistory.InsertLast(horizontalVelocity);
    if (velocityHistory.Length > 100) {
        velocityHistory.RemoveAt(0);
    }
    velocityDropDetection(velocityHistory);


    if (Time::Now - lastCollisionTime < 5000.0f && deltaCollision != "") {
        nvg::BeginPath();
        nvg::FontSize(40.0f);
        nvg::FillColor(vec4(1.0f, 1.0f, 1.0f, 1.0f));
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        string message = velocityBeforeLastCollisionMsg + " - " + deltaCollision + " = " + velocityAfterLastCollisionMsg;
        nvg::Text(vec2(Draw::GetWidth()/2, Draw::GetHeight()/2 + 50) + 100, message);
    }

    nvg::BeginPath();
    nvg::Circle(vec2(Draw::GetWidth()/2, Draw::GetHeight()/2), 25.0f);
    nvg::FillColor(GetColorFromVelocity(horizontalVelocity));
    nvg::Fill();
    nvg::ClosePath();
}

array<float> velocityHistory;

float velocityDropDetection(const array<float>& velocityHistory, float dropThreshold = -5.0f, uint windowSize = 5) {
    if (velocityHistory.Length < windowSize + 1) return 0.0f; // Not enough data to analyze

    for (uint i = 1; i <= windowSize; ++i) {
        float velocityAfterDrop = velocityHistory[velocityHistory.Length - i];
        float velocityBeforeDrop = velocityHistory[velocityHistory.Length - i - 1];
        float delta = velocityAfterDrop - velocityBeforeDrop;
        bool isInRespawning = velocityBeforeDrop == delta;
        if (delta < dropThreshold && isInRespawning == false) {
            deltaCollision = Text::Format("%.2f", Math::Abs(delta));
            velocityBeforeLastCollisionMsg = Text::Format("%.2f", velocityBeforeDrop);
            velocityAfterLastCollisionMsg = Text::Format("%.2f", velocityAfterDrop);
            lastCollisionTime = Time::Now;
            // draw rectangle around the player
            nvg::BeginPath();
            nvg::Rect(vec2(Draw::GetWidth()/2 - 50, Draw::GetHeight()/2 - 50), vec2(100, 100));
            nvg::FillColor(vec4(1.0f, 0.0f, 0.0f, 1.0f));
            nvg::Fill();
            nvg::ClosePath();


            return delta; // Return the velocity before the drop and the drop value
        }
    }

    return 0.0f; // No significant drop detected
}

vec4 GetColorFromVelocity(float velocity) {
    vec3 red    = vec3(1.0f, 0.0f, 0.0f);
    vec3 orange = vec3(1.0f, 0.65f, 0.0f);
    vec3 green  = vec3(0.0f, 1.0f, 0.0f);

    if (velocity <= 40.0f) {
        return vec4(red, 1.0f);
    } else if (velocity >= 68.0f) {
        return vec4(green, 1.0f);
    } else if (velocity <= 64.0f) {
        // Interpolation rouge → orange (60 à 64)
        float t = Math::Clamp((velocity - 60.0f) / 4.0f, 0.0f, 1.0f);
        vec3 color = Math::Lerp(red, orange, t);
        return vec4(color, 1.0f);
    } else {
        // Interpolation orange → vert (64 à 68)
        float t = Math::Clamp((velocity - 64.0f) / 4.0f, 0.0f, 1.0f);
        vec3 color = Math::Lerp(orange, green, t);
        return vec4(color, 1.0f);
    }
}

string velocityBeforeLastCollisionMsg = "";
string deltaCollision = "";
string velocityAfterLastCollisionMsg = "";
float lastCollisionTime = -10.0f;
