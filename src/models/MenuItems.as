class MenuItems {
    string title = "\\$3f0Obstacle \\$fffHelper";
    bool mustBeVisible = false;

    void drawMenus() {
        bool isMenuInitialized = UI::BeginMenu(menuItems.title, true);
        if (isMenuInitialized == false) return;

        centralCursor.drawCursorSubMenu();
        centralCursor.drawSettingsSubMenu();

        UI::EndMenu();
    }
}

MenuItems @menuItems = MenuItems();
