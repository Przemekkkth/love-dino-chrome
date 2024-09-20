Sprite = Object:extend()

function Sprite:new(pixmap, width, height)
    self.pixmap = pixmap
    self.x = 0
    self.y = 0
    self.w = width
    self.h = height
end

function Sprite:update(dt)

end

function Sprite:draw()
    love.graphics.draw(SPRITESHEET_IMG, self.pixmap, self.x, self.y)
end

function Sprite:setPosition(x, y)
    self.x = x
    self.y = y
end

function Sprite:position()
    return self.x, self.y
end

function Sprite:height()
    return self.h
end

function Sprite:width()
    return self.w
end 

function Sprite:setPixmap(pixmap, width, height) 
    self.pixmap = pixmap
    self.w = width
    self.h = height
end

function Sprite:move(_x, _y)
    self.x = self.x + _x
    self.y = self.y + _y
end