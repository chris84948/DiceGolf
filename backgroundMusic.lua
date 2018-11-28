BackgroundMusic = Object:extend()

local _playNextTrack

function BackgroundMusic:new()
    self.timeCount = 0
    self.trackIndex = math.random(1, 10)
    _playNextTrack(self)

    self.music:setVolume(0.5)
end

function BackgroundMusic:update(dt)
    -- Force to only check every 1 second
    self.timeCount = self.timeCount + dt
    if self.timeCount < 1 then
        return
    end

    if self.music:isPlaying() then
        return
    end

    self.trackIndex = (self.trackIndex % 10) + 1
    _playNextTrack(self)
end

_playNextTrack = function(self)
    self.music = love.audio.newSource("music/" .. self.trackIndex .. ".mp3", "stream")
    self.music:play()
end