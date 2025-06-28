class CentralCursor {
    string optionTitle = Icons::Crosshairs + " Cursor";
    string settingsTitle = Icons::Cog + " Cursor settings";
    string type = "DOT";
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

            UI::Separator();

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
            if (UI::RadioButton("Arrow", type == "ARROW")) {
                type = "ARROW";
            }
            UI::Separator();

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
}

CentralCursor @centralCursor = CentralCursor();
