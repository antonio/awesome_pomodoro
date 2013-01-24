-- Its own wibox
-- Visible/hidden
-- Add notifications
-- Make it configurable?

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local timer = timer
local string = string

local Pomodoro = {
  iteration = 1,
  widget = wibox.widget.textbox(),
  timer = timer({ timeout = 1 }),
  time_left = 0
}

function Pomodoro:reset_timer()
  if self.iteration % 8 == 0 then
    self.time_left = 900
  elseif self.iteration % 2 == 0 then
    self.time_left = 300
  else
    self.time_left = 1500
  end
  return self.time_left
end

function Pomodoro:decrease_timer()
  if self.time_left == 0 then
    self.iteration = self.iteration + 1
    self.time_left = self:reset_timer()
    self:notify()
  else
    self.time_left = self.time_left - 1
  end
  self.widget:set_text(self:widget_text())
end

function Pomodoro:notify()
  naughty.notify({title="Pomodoro!",text=self:status()})
  -- play sound?
end

function Pomodoro:status()
  if self.iteration % 2 == 0 then
    return "Rest"
  else
    return "Work"
  end
end

function Pomodoro:widget_text()
  local minutes = self.time_left / 60
  local seconds = self.time_left % 60
  local current_status = self:status()
  return string.format(" %s %02d:%02d ", current_status, minutes, seconds)
end

function Pomodoro:toggle()
  if self.timer.started then
    self.timer:stop()
  else
    self.timer:start()
  end
end

function Pomodoro:reset()
  self.time_left = 0
  self.iteration = 1
  self:reset_timer()
  self.widget:set_text(self:widget_text())
end

pomodoro = Pomodoro

pomodoro:reset_timer()
pomodoro.widget:set_text(pomodoro:widget_text())
pomodoro.timer:connect_signal("timeout", function() pomodoro:decrease_timer() end)

pomodoro.widget:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () pomodoro:toggle() end),
                           awful.button({ }, 3, function () pomodoro:reset() end)))

return pomodoro

