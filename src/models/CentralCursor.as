class CentralCursor {
    string optionTitle = Icons::Crosshairs + " Cursor";
    string settingsTitle = Icons::Cog + " Cursor settings";
    string type = "DOT";
    bool isCursorShow = true;
    bool settingsMustBeShow = false;
    bool mustBeHollowed = true;
    bool mustDisplaySpeed = true;
    bool mustBeInfluencedBySpeed = true;
    bool mustShowYaw = true;
    bool mustShowYawText = false;
    bool mustLiveResetYawAngleByWall = true;
    bool mustPlaySpeedSound = true;
    float volume = 0.05f;
    uint16 yawLines = 4;
    int yamLengthLine = 150;
    float normalScale = 2.4f;
    float strokeWidth = 3.0f;
    float speedInfluenceFactor = 1.0f;
    float updateDisplaySpeedByHz = 7.0f;

    // Variables for speed display frequency control
    float lastDisplayedSpeed = 0.0f;
    float maxSpeedSinceLastUpdate = 0.0f;
    float timeSinceLastUpdate = 0.0f;

    vec4[] colorSteps = {
        vec4(1.0f, 0.0f, 0.0f, 1.0f), // Default Red
        vec4(1.0f, 1.0f, 0.0f, 1.0f), // Default Yellow
        vec4(0.0f, 1.0f, 0.0f, 1.0f), // Default Green
        vec4(0.0f, 0.0f, 1.0f, 1.0f) // Default Blue
    };
    uint[] speedSteps = { 50, 60, 70, 80 };
    bool[] drawSteps = { true, true, true, true };

    void drawCursorSubMenu() {
        bool isInitialized = UI::MenuItem(optionTitle, "", isCursorShow, true);
        if (isInitialized) {
            isCursorShow = !isCursorShow;
            saveAndSerializeSettings();
        }
    }

    void drawSettingsSubMenu() {
        bool isInitialized = UI::MenuItem(settingsTitle, "", settingsMustBeShow, true);
        if (isInitialized) {
            settingsMustBeShow = !settingsMustBeShow;
        }
    }

    void drawWindowSettings() {
        if (settingsMustBeShow == false) {
            return;
        }

        bool isInitializedWindow = UI::Begin(settingsTitle, settingsMustBeShow, UI::WindowFlags::AlwaysAutoResize);

        if (isInitializedWindow == true) {
            // Description
            UI::Text("Central cursor settings allow you to customize the appearance and behavior");
            UI::Text("of the central cursor in the game. You can choose the cursor type, add or");
            UI::Text("remove speed steps, and set colors for each speed step.");

            // Draw cursor visibility toggle
            isCursorShow = UI::Checkbox(optionTitle, isCursorShow);

            UI::Separator(); // --------------------------------------------------------------------

            // Draw cursor type selection
            UI::Text("Cursor global shape");
            if (UI::RadioButton("Dot", type == "DOT")) {
                type = "DOT";
            }
            UI::SameLine();
            if (UI::RadioButton("None", type == "NONE")) {
                type = "NONE";
            }

            // hollowed cursor option checkbox
            mustBeHollowed = UI::Checkbox("Hollowed Cursor", mustBeHollowed);
            mustDisplaySpeed = UI::Checkbox("Display Speed", mustDisplaySpeed);

            if (mustDisplaySpeed) {
                updateDisplaySpeedByHz = UI::SliderFloat("Speed Update Hz", updateDisplaySpeedByHz, 1.0f, 60.0f, "%.1f Hz", UI::SliderFlags::AlwaysClamp);
                UI::Text("Speed display updates " + updateDisplaySpeedByHz + " times per second (every " + tostring(Math::Round(1000.0f / updateDisplaySpeedByHz)) + "ms)");
            }

            mustBeInfluencedBySpeed = UI::Checkbox("Influenced by Speed", mustBeInfluencedBySpeed);
            if (mustBeInfluencedBySpeed) {
                speedInfluenceFactor = UI::SliderFloat("Speed Influence Factor", speedInfluenceFactor, 0.1f, 3.0f, "%.1f", UI::SliderFlags::AlwaysClamp);
                UI::Text("Current Speed Influence Factor: " + speedInfluenceFactor);
            }

            // Draw cursor scale
            UI::Text("Cursor Scale");
            normalScale = UI::SliderFloat("Scale", normalScale, 0.1f, 5.0f, "%.1f", UI::SliderFlags::AlwaysClamp);
            UI::Text("Current Scale: " + normalScale);

            // Draw stroke width
            UI::Text("Stroke Width");
            strokeWidth = UI::SliderFloat("Width", strokeWidth, 0.1f, 10.0f, "%.1f", UI::SliderFlags::AlwaysClamp);

            UI::Separator(); // --------------------------------------------------------------------

            // sound cursor
            mustPlaySpeedSound = UI::Checkbox("Play Speed Sound", mustPlaySpeedSound);
            if (mustPlaySpeedSound) {
                volume = UI::SliderFloat("Sound Volume", volume, 0.0f, 1.0f, "%.2f", UI::SliderFlags::AlwaysClamp);
                UI::Text("Current Sound Volume: " + tostring(Math::Round(volume * 100)) + "%");
            }

            UI::Separator(); // --------------------------------------------------------------------

            mustShowYaw = UI::Checkbox("Show Yaw", mustShowYaw);
            if (mustShowYaw) {
                // yawLines = UI::SliderInt("Yaw Lines", yawLines, 1, 15);
                UI::RadioButton("4 lines", yawLines == 4) ? yawLines = 4 : yawLines;
                UI::SameLine();
                UI::RadioButton("8 lines", yawLines == 8) ? yawLines = 8 : yawLines;
                yamLengthLine = UI::SliderInt("Yaw Line Length", yamLengthLine, 50, 400);
                mustShowYawText = UI::Checkbox("Show Yaw Text", mustShowYawText);
                mustLiveResetYawAngleByWall = UI::Checkbox("Show angle by wall", mustLiveResetYawAngleByWall);
            }

            UI::Separator(); // --------------------------------------------------------------------

            // + and - buttons to add or remove speed steps
            if (UI::Button(Icons::Plus + " Add Speed Step")) {
                speedSteps.InsertLast(100);
                colorSteps.InsertLast(vec4(1.0f, 1.0f, 1.0f, 1.0f)); // Default to white
                drawSteps.InsertLast(true);
            }
            UI::SameLine();
            if (UI::Button(Icons::Minus + " Remove Speed Step")) {
                if (speedSteps.Length > 0) {
                    speedSteps.RemoveLast();
                    colorSteps.RemoveLast();
                    drawSteps.RemoveLast();
                }
            }

            if (UI::BeginMenu("Implemented color steps (" + speedSteps.Length + ")")) {
                for (uint i = 0; i < speedSteps.Length; i++) {
                    bool drawStep = drawSteps[i];
                    drawStep = UI::Checkbox("Draw " + speedSteps[i] + " km/h", drawStep);
                    drawSteps[i] = drawStep;

                    UI::SameLine();
                    if (UI::Button(Icons::Trash + "##" + i)) {
                        drawSteps[i] = false;
                        speedSteps.RemoveAt(i);
                        colorSteps.RemoveAt(i);
                        i--; // Decrement i to account for the removed item
                        continue; // Skip the rest of the loop for this iteration
                    }

                    string menuLabel = Icons::Tachometer + " Speed";
                    UI::Text(menuLabel);

                    int speedStep = int(speedSteps[i]);
                    speedStep = UI::SliderInt("km/h##" + i, speedStep, 0, 200);
                    speedSteps[i] = uint(speedStep);

                    UI::Text(Icons::Eyedropper + " Color");
                    vec4 colorStep = colorSteps[i];
                    colorStep = UI::InputColor4("Color##" + i, colorStep);
                    colorSteps[i] = colorStep;

                    UI::Separator();
                }
                UI::EndMenu();
            }
        }
        UI::End();

        saveAndSerializeSettings();
    }

    void drawCursor(float delta) {
        if (isCursorShow == false) {
            return;
        }

        CSmPlayer@ sm_player = cast<CSmPlayer>(GetApp().CurrentPlayground.GameTerminals[0].GUIPlayer);
        CSmScriptPlayer@ sm_script = sm_player.ScriptAPI;

        float horizontalVelocity = convertMeterPerSecondToKilometerPerHour(Math::Abs(sm_script.Velocity.x + sm_script.Velocity.z));

        // Update speed display with frequency control (approximating 60 FPS)
        updateSpeedDisplay(horizontalVelocity, delta);

        vec2 cursorPosition = vec2(Draw::GetWidth() / 2, Draw::GetHeight() / 2);
        float scale = normalScale * UI::GetScale();
        float radianRotation = sm_script.AimYaw;
        float normalRadius = 10.0f;

        // Draw the cursor based on the selected type
        if (type == "DOT") {
            drawCircle(cursorPosition, horizontalVelocity, scale, normalRadius);
        } else if (type == "NONE") {
            // Do nothing
        }

        if (mustDisplaySpeed) {
            // Draw the speed number at the cursor position
            drawSpeedNumber(cursorPosition, horizontalVelocity, scale);
        }

        if (mustShowYaw) {
            // Draw the yaw cross at the cursor position
            drawYawCross(cursorPosition, scale, radianRotation, horizontalVelocity, normalRadius);
        }

        if (mustPlaySpeedSound) {
            // Clamp speed to maximum of 160 km/h
            float clampedSpeed = Math::Min(horizontalVelocity, 160.0f);

            if (clampedSpeed <= 0.0f) {
                // Pause sound when speed is 0 or negative
                if (!voice.IsPaused()) {
                    voice.Pause();
                }
            } else {
                // Resume sound if paused
                if (voice.IsPaused()) {
                    voice.Play();
                    voice.SetGain(volume);
                }

                // Calculate target position based on speed (0-160 km/h maps to 0-100% of sound length)
                auto soundLength = voice.GetLength();
                float targetPosition = (clampedSpeed / 160.0f) * soundLength;

                // Get current position to avoid brutal cuts
                float currentPosition = voice.GetPosition();

                // Only update position if the difference is significant (more than 50ms)
                // and ensure we don't make too abrupt changes
                float positionDiff = Math::Abs(targetPosition - currentPosition);
                if (positionDiff > 0.05f) { // 50ms threshold
                    // Smooth transition: move gradually towards target position
                    float maxJump = 0.1f; // Maximum 100ms jump per frame
                    if (positionDiff > maxJump) {
                        if (targetPosition > currentPosition) {
                            voice.SetPosition(currentPosition + maxJump);
                        } else {
                            voice.SetPosition(currentPosition - maxJump);
                        }
                    } else {
                        voice.SetPosition(targetPosition);
                    }
                }
            }
        } else {
            // Stop sound if sound is disabled
            if (!voice.IsPaused()) {
                voice.Pause();
            }
        }
    }

    void updateSpeedDisplay(float currentSpeed, float deltaTime) {
        // Update the timer (deltaTime is in milliseconds)
        timeSinceLastUpdate += deltaTime;

        // Track the maximum speed since last update
        if (currentSpeed > maxSpeedSinceLastUpdate) {
            maxSpeedSinceLastUpdate = currentSpeed;
        }

        // Calculate update interval from Hz: if updateDisplaySpeedByHz = 10, we want updates every 100ms
        // 1 second = 1000ms, so interval = 1000ms / Hz
        float updateIntervalMs = 1000.0f / updateDisplaySpeedByHz;

        // Update displayed speed if enough time has passed
        if (timeSinceLastUpdate >= updateIntervalMs) {
            lastDisplayedSpeed = maxSpeedSinceLastUpdate;
            maxSpeedSinceLastUpdate = 0.0f; // Reset for next interval
            timeSinceLastUpdate = 0.0f; // Reset timer
        }
    }

    void drawSpeedNumber(vec2 position, float speed, float scale) {
        // Use the last displayed speed (updated by updateSpeedDisplay)
        string speedText = tostring(Math::Round(lastDisplayedSpeed));

        // Draw the speed text
        // nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        setFontSettings(scale);
        vec2 textSize = nvg::TextBounds(speedText);
        nvg::Text(position.x - (textSize.x/2), position.y + (textSize.y/2.7), speedText);
        // float radius = 10.0f * scale;
        // nvg::TextBox(position.x - radius, position.y + yOffset, radius * 2, speedText);
    }

    void drawCircle(vec2 position, float speed, float scale, float radius) {
        float effectiveRadius = radius * scale;
        if (mustBeInfluencedBySpeed) {
            effectiveRadius += (speed * speedInfluenceFactor);
        }
        vec4 color = getColorForSpeed(speed);

        if (mustBeHollowed == false) {
            nvg::BeginPath();
            nvg::Circle(position, effectiveRadius);
            nvg::FillColor(getColorForSpeed(speed));
            nvg::Fill();
            nvg::ClosePath();
        } else {
            nvg::BeginPath();
            nvg::Circle(position, effectiveRadius);
            nvg::StrokeWidth(strokeWidth * UI::GetScale());
            nvg::StrokeColor(color);
            nvg::Stroke();
            nvg::ClosePath();
        }
    }

    void drawYawCross(vec2 position, float scale, float rotation, float speed, float radius) {
        nvg::Translate(position);
        nvg::Rotate(rotation);

        // Displays the difference between the current angle and the nearest wall angle (0 or 45)
        float yawDeg = Math::Abs(Math::ToDeg(rotation));
        float nearestWall = Math::Round(yawDeg / 45.0f) * 45.0f;
        float diff = yawDeg - nearestWall;

        float effectiveRadius = radius * scale;
        if (mustBeInfluencedBySpeed) {
            effectiveRadius += (speed * speedInfluenceFactor);
        }

        for (uint i = 0; i < yawLines; i++) {
            float angle = ( (2.0f * Math::PI * float(i)) / float(yawLines) ) + (Math::PI / 2.0f);

            // Point de départ : sur le bord du cercle
            float innerXOffset = Math::Cos(angle) * effectiveRadius;
            float innerYOffset = Math::Sin(angle) * effectiveRadius;

            // Point d'arrivée : à l'extérieur du cercle
            float outerXOffset = Math::Cos(angle) * (effectiveRadius + yamLengthLine);
            float outerYOffset = Math::Sin(angle) * (effectiveRadius + yamLengthLine);

            nvg::BeginPath();
            nvg::MoveTo(vec2(innerXOffset, innerYOffset));
            nvg::LineTo(vec2(outerXOffset, outerYOffset));
            nvg::StrokeWidth(strokeWidth * UI::GetScale());
            nvg::StrokeColor(getColorForSpeed(speed));
            nvg::Stroke();
            nvg::ClosePath();
        }

        nvg::ResetTransform();

        if (mustShowYawText) {
            float yOffset = position.y - effectiveRadius - 20;
            setFontSettings(scale);
            if(mustLiveResetYawAngleByWall) {
                string yawText = tostring(int(Math::Abs(diff)));
                vec2 textSize = nvg::TextBounds(yawText);
                nvg::Text(position.x - (textSize.x/2), yOffset, yawText);
            } else {
                string yawText = tostring(Math::Abs(Math::Round(Math::ToDeg(rotation))));
                vec2 textSize = nvg::TextBounds(yawText);
                nvg::Text(position.x - (textSize.x/2), yOffset, yawText);
            }
        }
    }

    void setFontSettings(float scale) {
        nvg::FontSize(12.0f * scale);
        nvg::FillColor(vec4(1.0f, 1.0f, 1.0f, 1.0f));
        nvg::TextLetterSpacing(0.8f * scale);
    }

    void sortStepsArrayBySpeed() {
        // Sort the speedSteps, colorSteps, and drawSteps arrays based on speedSteps
        for (uint i = 0; i < speedSteps.Length - 1; i++) {
            for (uint j = i + 1; j < speedSteps.Length; j++) {
                if (speedSteps[i] > speedSteps[j]) {
                    // Swap speedSteps
                    uint tempSpeed = speedSteps[i];
                    speedSteps[i] = speedSteps[j];
                    speedSteps[j] = tempSpeed;

                    // Swap colorSteps
                    vec4 tempColor = colorSteps[i];
                    colorSteps[i] = colorSteps[j];
                    colorSteps[j] = tempColor;

                    // Swap drawSteps
                    bool tempDraw = drawSteps[i];
                    drawSteps[i] = drawSteps[j];
                    drawSteps[j] = tempDraw;
                }
            }
        }
    }

    vec4 getColorForSpeed(float speed) {
        sortStepsArrayBySpeed();

        // Find the appropriate color for the given speed
        for (uint i = 0; i < speedSteps.Length; i++) {
            if (drawSteps[i] && speed <= float(speedSteps[i])) {
                return colorSteps[i];
            }
        }

        // If no speed step matches, return the last color
        if (speedSteps.Length > 0) {
            return colorSteps[colorSteps.Length - 1];
        }

        // Default color if no steps are defined
        return vec4(1.0f, 1.0f, 1.0f, 1.0f); // White
    }

    void saveAndSerializeSettings() {
        // Save the current settings by building JSON manually
        // This function can be called when the user clicks a "Save" button in the UI

        try {
            string jsonSettings = "{\n";
            jsonSettings += "    \"optionTitle\": \"" + optionTitle + "\",\n";
            jsonSettings += "    \"settingsTitle\": \"" + settingsTitle + "\",\n";
            jsonSettings += "    \"type\": \"" + type + "\",\n";
            jsonSettings += "    \"isCursorShow\": " + (isCursorShow ? "true" : "false") + ",\n";
            jsonSettings += "    \"settingsMustBeShow\": " + (settingsMustBeShow ? "true" : "false") + ",\n";
            jsonSettings += "    \"mustBeHollowed\": " + (mustBeHollowed ? "true" : "false") + ",\n";
            jsonSettings += "    \"mustDisplaySpeed\": " + (mustDisplaySpeed ? "true" : "false") + ",\n";
            jsonSettings += "    \"mustBeInfluencedBySpeed\": " + (mustBeInfluencedBySpeed ? "true" : "false") + ",\n";
            jsonSettings += "    \"mustShowYaw\": " + (mustShowYaw ? "true" : "false") + ",\n";
            jsonSettings += "    \"mustShowYawText\": " + (mustShowYawText ? "true" : "false") + ",\n";
            jsonSettings += "    \"mustLiveResetYawAngleByWall\": " + (mustLiveResetYawAngleByWall ? "true" : "false") + ",\n";
            jsonSettings += "    \"yawLines\": " + yawLines + ",\n";
            jsonSettings += "    \"yamLengthLine\": " + yamLengthLine + ",\n";
            jsonSettings += "    \"normalScale\": " + normalScale + ",\n";
            jsonSettings += "    \"strokeWidth\": " + strokeWidth + ",\n";
            jsonSettings += "    \"speedInfluenceFactor\": " + speedInfluenceFactor + ",\n";
            jsonSettings += "    \"updateDisplaySpeedByHz\": " + updateDisplaySpeedByHz + ",\n";

            // Build colorSteps array
            jsonSettings += "    \"colorSteps\": [\n";
            for (uint i = 0; i < colorSteps.Length; i++) {
                vec4 c = colorSteps[i];
                jsonSettings += "        [" + c.x + ", " + c.y + ", " + c.z + ", " + c.w + "]";
                if (i < colorSteps.Length - 1) jsonSettings += ",";
                jsonSettings += "\n";
            }
            jsonSettings += "    ],\n";

            // Build speedSteps array
            jsonSettings += "    \"speedSteps\": [";
            for (uint i = 0; i < speedSteps.Length; i++) {
                jsonSettings += "" + speedSteps[i];
                if (i < speedSteps.Length - 1) jsonSettings += ", ";
            }
            jsonSettings += "],\n";

            // Build drawSteps array
            jsonSettings += "    \"drawSteps\": [";
            for (uint i = 0; i < drawSteps.Length; i++) {
                jsonSettings += (drawSteps[i] ? "true" : "false");
                if (i < drawSteps.Length - 1) jsonSettings += ", ";
            }
            jsonSettings += "],\n";

            // Add sound cursor settings (no trailing comma after last property!)
            jsonSettings += "    \"mustPlaySpeedSound\": " + (mustPlaySpeedSound ? "true" : "false") + ",\n";
            jsonSettings += "    \"volume\": " + volume + "\n";
            jsonSettings += "}";

            Setting_Cursor = jsonSettings;
        } catch {
            print("Error saving settings on cursor");
        }
    }

    void deserializeAndReadSettings() {
        try
        {
            Json::Value root = Json::Parse(Setting_Cursor);

            // Read basic properties directly from root (following your example pattern)
            optionTitle = root["optionTitle"];
            settingsTitle = root["settingsTitle"];
            type = root["type"];
            isCursorShow = root["isCursorShow"];
            settingsMustBeShow = root["settingsMustBeShow"];
            mustBeHollowed = root["mustBeHollowed"];
            mustDisplaySpeed = root["mustDisplaySpeed"];
            mustBeInfluencedBySpeed = root["mustBeInfluencedBySpeed"];
            mustShowYaw = root["mustShowYaw"];
            mustShowYawText = root["mustShowYawText"];
            mustLiveResetYawAngleByWall = root["mustLiveResetYawAngleByWall"];
            yawLines = uint16(root["yawLines"]);
            yamLengthLine = root["yamLengthLine"];
            normalScale = root["normalScale"];
            strokeWidth = root["strokeWidth"];
            speedInfluenceFactor = root["speedInfluenceFactor"];
            updateDisplaySpeedByHz = root["updateDisplaySpeedByHz"];

            // Read colorSteps array
            Json::Value colorStepsArray = root["colorSteps"];
            colorSteps = {};
            for (uint i = 0; i < colorStepsArray.Length; ++i)
            {
                Json::Value colorArray = colorStepsArray[i];

                vec4 color = vec4(colorArray[0], colorArray[1], colorArray[2], colorArray[3]);

                colorSteps.InsertLast(color);
            }

            // Read speedSteps array
            Json::Value speedStepsArray = root["speedSteps"];
            speedSteps = {};
            for (uint i = 0; i < speedStepsArray.Length; ++i)
            {
                speedSteps.InsertLast(uint(speedStepsArray[i]));
            }

            // Read drawSteps array
            Json::Value drawStepsArray = root["drawSteps"];
            drawSteps = {};
            for (uint i = 0; i < drawStepsArray.Length; ++i)
            {
                drawSteps.InsertLast(drawStepsArray[i]);
            }

            // Read sound cursor settings
            mustPlaySpeedSound = root["mustPlaySpeedSound"];
            volume = root["volume"];
        }
        catch {
            print("The cursor settings JSON string seems corrupted. Please try to fix it or reset to default settings.");
        }
    }
}

CentralCursor@ centralCursor = CentralCursor();
