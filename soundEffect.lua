SoundEffect = Object:extend()

function SoundEffect:new()
    self.swing = love.audio.newSource("assets/swing.mp3", "static")
    self.hole = love.audio.newSource("assets/hole.mp3", "static")
    self.putt = love.audio.newSource("assets/putt.mp3", "static")
    self.splash = love.audio.newSource("assets/splash.mp3", "static")
    self.dice = love.audio.newSource("assets/dice.mp3", "static")
    self.dice:setLooping(true)
end

function SoundEffect:startRolling()
    self.dice:play()
end

function SoundEffect:stopRolling()
    self.dice:stop()
end

function SoundEffect:playSwing()
    self.swing:play()
end

function SoundEffect:playPutt()
    self.putt:play()
end

function SoundEffect:playHole()
    self.hole:play()
end

function SoundEffect:playSplash()
    self.splash:play()
end