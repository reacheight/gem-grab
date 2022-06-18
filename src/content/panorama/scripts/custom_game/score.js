function OnScoreUpdated(event) {
  $.GetContextPanel().FindChild("Team" + event.teamNum).FindChild("Label" + event.teamNum).text = event.newScore
}

function run() {
  GameEvents.Subscribe("score_updated", OnScoreUpdated)
}

run();