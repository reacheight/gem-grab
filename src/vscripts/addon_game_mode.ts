import "./lib/timers";
import { GemGrab } from "./GameMode";

// Connect GameMode.Activate and GameMode.Precache to the dota engine
Object.assign(getfenv(), {
    Activate: GemGrab.Activate,
    Precache: GemGrab.Precache,
});

if (GameRules.GemGrab) {
    // This code is only run after script_reload, not at startup
    GameRules.GemGrab.Reload();
}
