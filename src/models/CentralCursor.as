class CentralCursor {
    string optionTitle = Icons::Crosshairs + " Cursor";
    string settingsTitle = Icons::Cog + " Cursor settings";
    string type = "dot";

    bool isCursorShow = false;
    bool settingsShow = false;

    void drawMenus() {
        bool isInitialized = UI::MenuItem(optionTitle, "", isCursorShow, true);
        if (isInitialized) {
            isCursorShow = !isCursorShow;
        }
    }
}

CentralCursor @centralCursor = CentralCursor();
