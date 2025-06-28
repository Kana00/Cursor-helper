class MenuItems {
    string title = "\\$3f0Obstacle \\$fffHelper";
    bool mustBeVisible = false;

    void drawMainMenu() {
        if (mustBeVisible == false) {
            return;
        }

        bool isInitializedWindow = UI::Begin(title, mustBeVisible, UI::WindowFlags::AlwaysAutoResize);

        if (isInitializedWindow == false) {
            print("Window closed unexpectedly");
            sleep(4000);
            return;
        }

        UI::End();
    }

    void subMenus() {
        centralCursor.drawMenus();
    }
}

MenuItems @menuItems = MenuItems();
