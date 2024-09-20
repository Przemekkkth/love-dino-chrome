require "spritesheet"
Object = require "libraries.classic"
require "Sprite"
Input = require 'libraries/boipushy/Input'

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720
APP_TITLE = "LÖVE Dino Chrome"
DEBUG = false

function love.load()
    love.filesystem.setIdentity("love-dino-chrome")
    love.window.setTitle(APP_TITLE)
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)

    initInput()
    initSFX()

    m_groundSprite = Sprite(love.graphics.newQuad(2, 104, 2440, 26, SPRITESHEET_IMG), 2240, 26)
    m_groundSprite:setPosition(0, 520)
    m_groundBackSprite = Sprite(love.graphics.newQuad(2, 104, 2440, 26, SPRITESHEET_IMG), 2240, 26)
    m_groundBackSprite:setPosition(0, 520)
    
    m_dino = Sprite(love.graphics.newQuad(1678, 2, 88, 94, SPRITESHEET_IMG), 88, 94)
    local xGroundPos, yGroundPos = m_groundSprite:position()
    m_dino:setPosition(150, yGroundPos - (m_dino:height() - gap))

    m_frameGround = 0.0
    m_frameDino = 0.0
    m_velocity = 0.0
    m_jump = -20.0
    m_frameDown = 0.0
    m_crouch = false
    m_isCrouching = false

    m_gravity = yGroundPos - (m_dino:height() - gap)

    m_objs = {
        { x = 260, y = 14, width = 92, height = 68 },
        { x = 446, y = 2, width = 68, height = 70 },
        { x = 752, y = 2, width = 50, height = 96 },
        { x = 652, y = 2, width = 98, height = 96 },
        { x = 848, y = 2, width = 104, height = 98 }
    }

    m_count = 0
    m_frameBird = 0.0

    m_hiSprite = Sprite(love.graphics.newQuad(1494, 2, 38, 21, SPRITESHEET_IMG), 38, 21)
    m_hiSprite:setPosition(955, 25)
    m_hiStartX = 1020
    m_numHi = 0
    m_spacing = 20.0
    m_total = 5

    m_digits = {}
    m_digits['0'] = love.graphics.newQuad(1294, 2, 18, 21, SPRITESHEET_IMG)
    m_digits['1'] = love.graphics.newQuad(1316, 2, 18, 21, SPRITESHEET_IMG)
    m_digits['2'] = love.graphics.newQuad(1334, 2, 18, 21, SPRITESHEET_IMG) 
    m_digits['3'] = love.graphics.newQuad(1354, 2, 18, 21, SPRITESHEET_IMG)
    m_digits['4'] = love.graphics.newQuad(1374, 2, 18, 21, SPRITESHEET_IMG)
    m_digits['5'] = love.graphics.newQuad(1394, 2, 18, 21, SPRITESHEET_IMG)
    m_digits['6'] = love.graphics.newQuad(1414, 2, 18, 21, SPRITESHEET_IMG)
    m_digits['7'] = love.graphics.newQuad(1434, 2, 18, 21, SPRITESHEET_IMG) 
    m_digits['8'] = love.graphics.newQuad(1454, 2, 18, 21, SPRITESHEET_IMG) 
    m_digits['9'] = love.graphics.newQuad(1474, 2, 18, 21, SPRITESHEET_IMG) 

    m_start_x = 1140
    local hiSpriteX, hiSpriteY = m_hiSprite:position()
    m_start_y = hiSpriteY

    m_dinoRect = {x = 0, y = 0, width = 40, height = 70}

    m_rectObjs = {}
    m_gameover = false

    m_spriteGameover = Sprite(love.graphics.newQuad(1295, 29, 380, 21, SPRITESHEET_IMG), 380, 21)
    m_spriteGameover:setPosition(SCREEN_WIDTH / 2 - m_spriteGameover:width() / 2, SCREEN_HEIGHT / 2 - m_spriteGameover:height() / 2)

    m_iconRestart = Sprite(love.graphics.newQuad(506, 130, 72, 64, SPRITESHEET_IMG), 72, 64)
    m_iconRestart:setPosition(SCREEN_WIDTH / 2 - m_iconRestart:width() / 2, SCREEN_HEIGHT / 2 - m_iconRestart:height() / 2 + 70)

    m_color = 255
    m_day = true
    m_changeDay = false

    m_sun = Sprite(love.graphics.newQuad(1074, 2, 80, 80, SPRITESHEET_IMG), 80, 80)
    m_sun:setPosition(SCREEN_WIDTH / 2 - m_sun:width() / 2, SCREEN_HEIGHT / 2 - m_sun:height() / 2 - 150)

    m_clouds = {}

    for i = 1, 6 do
        local cloud = Sprite(love.graphics.newQuad(166, 2, 92, 27, SPRITESHEET_IMG), 92, 27)
        table.insert(m_clouds, cloud)
    end

    m_clouds[1]:setPosition(100.0, 100.0);
    m_clouds[2]:setPosition(300.0, 300.0);
    m_clouds[3]:setPosition(1280.0, 200.0);
    m_clouds[4]:setPosition(650.0, 60.0);
    m_clouds[5]:setPosition(830.0, 150.0);
    m_clouds[6]:setPosition(1000.0, 400.0);

    m_star1 = Sprite(love.graphics.newQuad(1274, 39, 18, 17, SPRITESHEET_IMG), 18, 17)
    m_star1:setPosition(200.0, 200.0)
    m_star2 = Sprite(love.graphics.newQuad(1274, 39, 18, 17, SPRITESHEET_IMG), 18, 17)
    m_star2:setPosition(800.0, 300.0)

    m_speed = 200.0

    m_sprites = {} 
    m_rectObjs = {}
    m_dinoRect = {}
end

function love.update(dt) 
    handlePlayerinput()
    runGame(dt)
    if m_gameover then 
        if m_count > m_numHi then
            m_numHi = m_count
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor( m_color / 255, m_color / 255, m_color / 255, 1 )
    m_sun:draw()
    for i = 1, #m_clouds do
        m_clouds[i]:draw()
    end 

    m_star1:draw()
    m_star2:draw()
    m_groundSprite:draw()
    m_groundBackSprite:draw()

    for i = 1, #m_sprites do
        if DEBUG then 
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle('fill', m_rectObjs[i].x, m_rectObjs[i].y, m_rectObjs[i].width, m_rectObjs[i].height)
            love.graphics.setColor(1, 1, 1)
        end
        m_sprites[i]:draw()
    end

    if DEBUG then
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle('fill', m_dinoRect.x, m_dinoRect.y, m_dinoRect.width, m_dinoRect.height)
        love.graphics.setColor(1, 1, 1)
    end

    m_dino:draw()

    drawCount()
    m_hiSprite:draw()
    drawHighestResult()

    if m_gameover then
        m_spriteGameover:draw()
        m_iconRestart:draw()
        m_dino:setPixmap(love.graphics.newQuad(2122, 6, 80, 86, SPRITESHEET_IMG), 80, 86)
        local xGroundPos, yGroundPos = m_groundSprite:position()
    end
end

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/60
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

function checkCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.width and
           rect1.x + rect1.width > rect2.x and
           rect1.y < rect2.y + rect2.height and
           rect1.y + rect1.height > rect2.y
end

function drawCount()
    local count_str = string.format("%0" .. tostring(m_total) .. "d", m_count)

    local x = m_start_x

    for i = 1, #count_str do
        local digit = count_str:sub(i, i)
        local quad = m_digits[digit]

        if quad then
            love.graphics.draw(SPRITESHEET_IMG, quad, x, m_start_y)
        end

        x = x + m_spacing
    end
end

function drawHighestResult()
    local count_str = string.format("%0" .. tostring(m_total) .. "d", m_numHi)

    local x = m_hiStartX

    for i = 1, #count_str do
        local digit = count_str:sub(i, i)
        local quad = m_digits[digit]

        if quad then
            love.graphics.draw(SPRITESHEET_IMG, quad, x, m_start_y)
        end

        x = x + m_spacing
    end
end

function handlePlayerinput() 
    if input:pressed('jump') then
        local xGroundPos, yGroundPos = m_groundSprite:position()
        local isDinoCollidedWithGround = (m_gravity == yGroundPos - (m_dino:height() - gap));
        if isDinoCollidedWithGround then 
            m_velocity = m_jump
            m_jumpSFX:play()
        end
    end

    if input:pressed('crouch') then 
        local xGroundPos, yGroundPos = m_groundSprite:position()
        local isDinoCollidedWithGround = (m_gravity == yGroundPos - (m_dino:height() - gap));
        if isDinoCollidedWithGround then 
            m_crouch = true
            m_isCrouching = true
        end
    end

    if input:released('crouch') then
        m_crouch = false
        m_isCrouching = false
    end

    if input:released('escape') then 
        love.event.quit()
    end

    if input:released('restart') then 
        if m_gameover then
            m_count = 0
            m_speed = 200.0
            m_rectObjs = {}
            m_sprites = {}
            local xGroundPos, yGroundPos = m_groundSprite:position()
            m_gravity = yGroundPos - (m_dino:height() - gap)
            m_velocity = 0.0
            m_day = true
            m_color = 255
            m_changeDay = false
            m_gameover = false
            m_dino:setPosition(150, yGroundPos - (m_dino:height() - gap))
        end
    end

    if input:released('screenshot') then
        --love.graphics.captureScreenshot(os.time() .. ".png")
    end
end

function runGame(dt)
    if not m_gameover then
        local fixedSpeed = m_speed * dt
        local random_distance = math.random(1, 2)
        if m_count % ((50 - math.floor(fixedSpeed))* random_distance) == 0 then
            local rand_obj = (love.math.random(1, 100) % #m_objs) + 1
            local sprite = Sprite(love.graphics.newQuad(m_objs[rand_obj].x, m_objs[rand_obj].y, m_objs[rand_obj].width, m_objs[rand_obj].height, SPRITESHEET_IMG), m_objs[rand_obj].width, m_objs[rand_obj].height)
            if m_objs[rand_obj].height == 68 then
                sprite:setPosition(SCREEN_WIDTH, 410)
            else
                sprite:setPosition(SCREEN_WIDTH, 520 - sprite:height() + gap)
            end

            local rect_obj = {}
            local spriteX, spriteY = sprite:position()
            rect_obj.x = spriteX
            rect_obj.y = spriteY
            rect_obj.width = sprite:width()
            rect_obj.height = sprite:height()

            table.insert(m_sprites, sprite)
            table.insert(m_rectObjs, rect_obj)
        end

        if not m_crouch then
            m_velocity = m_velocity + 1.0
            if m_velocity < m_jump then
                m_velocity = m_jump
            end
        end

        m_gravity = m_gravity + m_velocity

        local xGroundPos, yGroundPos = m_groundSprite:position()
        if m_gravity > yGroundPos - (m_dino:height() - gap) then 
            m_gravity = yGroundPos - (m_dino:height() - gap)
            m_velocity = 0.0
        end

        m_frameDino = m_frameDino + 0.2
        if m_frameDino > 4.0 then 
            m_frameDino = m_frameDino - 4.0
        end

        m_frameDown = m_frameDown + 0.1
        if m_frameDown > 1.5 then
            m_frameDown = m_frameDown - 1.5
        end

        m_frameGround = m_frameGround - 8.0
        if m_frameGround < -m_groundSprite:width() then 
            m_frameGround = 0.0
        end

        m_groundSprite:setPosition(m_frameGround - fixedSpeed, yGroundPos)
        m_groundBackSprite:setPosition(m_frameGround - fixedSpeed + (m_groundSprite:width() - 40), yGroundPos);

        local xDino, yDino = m_dino:position()
        if m_crouch then 
            m_dino:setPixmap(love.graphics.newQuad(2206 + 118 * math.floor(m_frameDown), 36, 118, 60, SPRITESHEET_IMG), 118, 60)
            m_dino:setPosition(xDino, m_gravity + 30)
            m_dinoRect.width = 100
            m_dinoRect.height = 40
            m_dinoRect.x = xDino + 20
            m_dinoRect.y = m_gravity + 40
        else
            m_dino:setPixmap(love.graphics.newQuad(1678 + 88 * math.floor(m_frameDino), 2, 88, 94, SPRITESHEET_IMG), 88, 94)
            m_dino:setPosition(xDino, m_gravity)
            m_dinoRect.width = 40
            m_dinoRect.height = 70
            m_dinoRect.x = xDino + 20
            m_dinoRect.y = m_gravity + 10
        end

        for i = #m_sprites, 1, -1 do 
            if m_sprites[i]:height() == 68 then
                m_frameBird = m_frameBird + 0.08
                if m_frameBird > 1.5 then
                    m_frameBird = m_frameBird - 1.5
                end
                m_sprites[i]:setPixmap(love.graphics.newQuad(260 + 92 * math.floor(m_frameBird), 14, 92, 68, SPRITESHEET_IMG), 92, 68)
            end

            m_sprites[i]:move(-10.0 - fixedSpeed, 0.0)
            local xSprite, ySprite = m_sprites[i]:position()
            m_rectObjs[i].x = xSprite
            m_rectObjs[i].y = ySprite

            if checkCollision(m_dinoRect, m_rectObjs[i]) then 
                m_gameover = true
                m_dieSFX:play()
            end

            if xSprite < -m_sprites[i]:width() then 
                table.remove(m_sprites, i)
                table.remove(m_rectObjs, i)
            end
        end

        for i = 1, #m_clouds do
            m_clouds[i]:move(-0.2, 0.0)
            local xCloud, yCloud = m_clouds[i]:position()
            if xCloud < -m_clouds[i]:width() then
                m_clouds[i]:setPosition(1280, yCloud)
            end
        end

        if not m_day then 
            m_sun:setPixmap(love.graphics.newQuad(1034, 2, 40, 80, SPRITESHEET_IMG), 40, 80)
        else
            m_sun:setPixmap(love.graphics.newQuad(1074, 2, 40, 80, SPRITESHEET_IMG), 40, 80)
        end

        m_count = m_count + 1
        if m_count >= 99999 then
            m_count = 99999
        end
    end

    if (m_count % 250) == 0 then
       m_speed = m_speed + 40.0 
       m_pointSFX:play()
    end

    if (m_count % 1000) == 0 and m_count > 1 then
        m_changeDay = true
    end

    if m_changeDay then
        if m_day then 
            m_color = m_color - 3
            if m_color <= 30 then
                m_color = 30
                m_day = false
                m_changeDay = false
            end
        else
            m_color = m_color + 3
            if m_color >= 255 then
                m_color = 255
                m_day = true
                m_changeDay = false
            end
        end
    end
end

function initInput()
    input = Input()
    input:bind('down', 'crouch')
    input:bind('s', 'crouch')
    input:bind('up', 'jump')
    input:bind('escape', 'escape')
    input:bind('r', 'restart')
    input:bind('space', 'jump')
    input:bind('p', 'screenshot')
end

function initSFX()
    m_dieSFX = love.audio.newSource('assets/die-101soundboards.wav', 'static')
    m_dieSFX:setVolume(0.5)
    m_jumpSFX = love.audio.newSource('assets/jump-101soundboards.wav', 'static')
    m_jumpSFX:setVolume(0.5)
    m_pointSFX = love.audio.newSource('assets/point-101soundboards.wav', 'static')
    m_pointSFX:setVolume(0.5)
end