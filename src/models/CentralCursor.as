class CentralCursor {
    string optionTitle = Icons::Crosshairs + " Cursor";
    string settingsTitle = Icons::Cog + " Cursor settings";
    string type = "dot";

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
        if (isInitializedWindow == false) return;

        UI::End();
    }
}

CentralCursor @centralCursor = CentralCursor();
