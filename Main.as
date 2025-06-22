auto @app = cast<CTrackMania>(GetApp());

void Main() {
    while (app is null)
    {
        if (app !is null)
        {
            @app = cast<CTrackMania>(GetApp());
            break;
        }
    }

    print("Obstacle analysis loaded successfully!");
}

array<UILabel> labels;

void Render() {
    if (app is null || app.LoadedManiaTitle.TitleId != "obstacle@smokegun") return;

    CSmScriptPlayer@ sm_script = sm_player.ScriptAPI;
}
