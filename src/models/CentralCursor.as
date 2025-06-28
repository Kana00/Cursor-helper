class CentralCursor {
    string optionTitle = Icons::Crosshairs + " Cursor";
    string settingsTitle = Icons::Cog + " Cursor settings";
    string type = "DOT";
    bool mustBeHollowed = false;
    float normalScale = 1.0f;
    float strokeWidth = 1.0f;
    vec4[] colorSteps = {
        vec4(0.0f, 0.0f, 0.0f, 1.0f), // Black
        vec4(1.0f, 0.0f, 0.0f, 1.0f), // Red
        vec4(1.0f, 1.0f, 0.0f, 1.0f), // Yellow
        vec4(0.0f, 1.0f, 0.0f, 1.0f), // Green
        vec4(0.0f, 0.0f, 1.0f, 1.0f) // Blue
    };
    uint[] speedSteps = { 40, 50, 60, 70, 80 };
    bool[] drawSteps = { true, true, true, true, true };
    bool isCursorShow = false;
    bool settingsMustBeShow = false;

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
            UI::Text("Cursor Type");
            if (UI::RadioButton("Dot", type == "DOT")) {
                type = "DOT";
            }
            UI::SameLine();
            if (UI::RadioButton("Cross", type == "CROSS")) {
                type = "CROSS";
            }
            UI::SameLine();
            if (UI::RadioButton("Square", type == "SQUARE")) {
                type = "SQUARE";
            }

            // hollowed cursor option checkbox
            mustBeHollowed = UI::Checkbox("Hollowed Cursor", mustBeHollowed);

            // Draw cursor scale
            UI::Text("Cursor Scale");
            normalScale = UI::SliderFloat("Scale", normalScale, 0.1f, 5.0f, "%.1f", UI::SliderFlags::AlwaysClamp);
            UI::Text("Current Scale: " + normalScale);

            // Draw stroke width
            UI::Text("Stroke Width");
            strokeWidth = UI::SliderFloat("Width", strokeWidth, 0.1f, 10.0f, "%.1f", UI::SliderFlags::AlwaysClamp);

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

            if (UI::BeginMenu("Implement color steps (" + speedSteps.Length + ")")) {
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
        float rotation = 0.0f;

        // Draw the cursor based on the selected type
        if (type == "DOT") {
            drawCircleDot(cursorPosition, horizontalVelocity, scale, rotation);
        } else if (type == "CROSS") {
            // UI::DrawLine(cursorCenter - vec2(10.0f * normalScale, 0), cursorCenter + vec2(10.0f * normalScale, 0), colorSteps[0]);
            // UI::DrawLine(cursorCenter - vec2(0, 10.0f * normalScale), cursorCenter + vec2(0, 10.0f * normalScale), colorSteps[0]);
        } else if (type == "SQUARE") {
            // Draw an SQUARE shape
            // vec2 SQUARETip = cursorCenter;
            // vec2 SQUAREBaseLeft = cursorCenter - vec2(10.0f * normalScale, 5.0f * normalScale);
            // vec2 SQUAREBaseRight = cursorCenter - vec2(10.0f * normalScale, -5.0f * normalScale);
            // UI::DrawTriangle(SQUARETip, SQUAREBaseLeft, SQUAREBaseRight, colorSteps[0]);
        }
    }

    void drawCircleDot(vec2 position, float speed, float scale, float rotation) {
        float radius = 10.0f * scale; // Adjust the radius as needed
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

    vec4 getColorForSpeed(float speed) {
        for (uint i = 0; i < speedSteps.Length; i++) {
            if (speed >= speedSteps[i] && drawSteps[i]) {
                return colorSteps[i];
            }
        }
        return vec4(1.0f, 1.0f, 1.0f, 1.0f); // Default to white if no match found
    }
}

CentralCursor@ centralCursor = CentralCursor();
