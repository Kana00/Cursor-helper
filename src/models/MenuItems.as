class MenuItems {
    string title = "\\$3f0Custom \\$fffCursor";
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
