function OnScoreUpdated(event: ScoreUpdatedEvent) {
  ($.GetContextPanel()!.FindChild("Team" + event.team)!.FindChild("Label" + event.team) as LabelPanel).text = event.newScore.toString()
}

GameEvents.Subscribe("score_updated", OnScoreUpdated)