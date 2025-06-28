void ClearConsole() {
    string cleanConsoleMessage;
    for (uint i = 0; i < 30; i++) {
        cleanConsoleMessage += "\n";
    }
    print(cleanConsoleMessage);
}

float ConvertMeterPerSecondToKilometerPerHour(float speed) {
    // Convert m/s to km/h
    return (speed * 3.6f * 10.0f) / 10.0f; // Round to one decimal place
}
