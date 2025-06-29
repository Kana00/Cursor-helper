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
    bool mustShowYawText = true;
    bool mustLiveResetYawAngleByWall = true;
    uint16 yawLines = 4;
    int yamLengthLine = 150;
    float normalScale = 2.4f;
    float strokeWidth = 3.0f;
    float speedInfluenceFactor = 1.0f;
    vec4[] colorSteps = {
        vec4(1.0f, 0.0f, 0.0f, 1.0f), // Red
        vec4(1.0f, 1.0f, 0.0f, 1.0f), // Yellow
        vec4(0.0f, 1.0f, 0.0f, 1.0f), // Green
        vec4(0.0f, 0.0f, 1.0f, 1.0f) // Blue
    };
    uint[] speedSteps = { 50, 60, 70, 80 };
    bool[] drawSteps = { true, true, true, true };

    void drawCursorSubMenu() {
        bool isInitialized = UI::MenuItem(optionTitle, "", isCursorShow, true);
        if (isInitialized) {
            isCursorShow = !isCursorShow;
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
    }

    void drawCursor() {
        if (isCursorShow == false) {
            return;
        }

        CSmPlayer@ sm_player = cast<CSmPlayer>(GetApp().CurrentPlayground.GameTerminals[0].GUIPlayer);
        CSmScriptPlayer@ sm_script = sm_player.ScriptAPI;

        float horizontalVelocity = ConvertMeterPerSecondToKilometerPerHour(Math::Abs(sm_script.Velocity.x + sm_script.Velocity.z));

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
    }

    void drawSpeedNumber(vec2 position, float speed, float scale) {
        string speedText = tostring(Math::Round(speed));

        // Draw the speed text
        // nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
        nvg::FontSize(12.0f * scale);
        nvg::FillColor(vec4(1.0f, 1.0f, 1.0f, 1.0f));
        nvg::TextLetterSpacing(0.8f * scale);
        vec2 textSize = nvg::TextBounds(speedText);
        nvg::Text(position.x - (textSize.x/2), position.y + (textSize.y/2.7), speedText);
        // float radius = 10.0f * scale;
        // nvg::TextBox(position.x - radius, position.y + yOffset, radius * 2, speedText);
    }

    void drawCircle(vec2 position, float speed, float scale, float radius) {
        if (mustBeInfluencedBySpeed) {
            radius = radius * scale + (speed * speedInfluenceFactor);
        }
        vec4 color = getColorForSpeed(speed);

        if (mustBeHollowed == false) {
            nvg::BeginPath();
            nvg::Circle(position, radius);
            nvg::FillColor(getColorForSpeed(speed));
            nvg::Fill();
            nvg::ClosePath();
        } else {
            nvg::BeginPath();
            nvg::Circle(position, radius);
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
            nvg::FontSize(12.0f * scale);
            nvg::FillColor(vec4(1.0f, 1.0f, 1.0f, 1.0f));
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
            if (drawSteps[i] && speed <= speedSteps[i]) {
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
}

CentralCursor@ centralCursor = CentralCursor();
