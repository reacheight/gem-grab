function OnCountdownUpdated(event) {
  $.GetContextPanel().FindChild("CountdownLabel").text = event.countdown === 0 ? "" : event.countdown
}

function run() {
  GameEvents.Subscribe("countdown_updated", OnCountdownUpdated)
}

run()