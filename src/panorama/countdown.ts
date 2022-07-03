function OnCountdownUpdated(event: CountdownUpdatedEvent) {
  ($.GetContextPanel().FindChild("CountdownLabel") as LabelPanel).text = event.countdown
}

GameEvents.Subscribe("countdown_updated", OnCountdownUpdated)