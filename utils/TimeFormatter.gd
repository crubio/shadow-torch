# res://utils/TimeFormatter.gd

class_name TimeFormatter

static func format_time(seconds: float, default_units: String) -> String:
  var time_text = ""
  match default_units:
    "Minutes":
      var secs = int(seconds)
      var mm = int(secs / 60)
      var ss = secs % 60
      time_text = "%02d:%02d" % [mm, ss]
    "Turns":
      var turns = float(seconds) / 600.0  # 600 seconds = 10 minutes = 1 turn
      time_text = "%.1f turns" % turns
    "Hours":
      var hours = float(seconds) / 3600.0  # 3600 seconds = 1 hour
      time_text = "%.2f hrs" % hours
    _:
      # Fallback to minutes
      var secs = int(seconds)
      var mm = int(secs / 60)
      var ss = secs % 60
      time_text = "%02d:%02d" % [mm, ss]
  return time_text