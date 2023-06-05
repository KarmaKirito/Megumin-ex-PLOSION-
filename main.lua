local pygame = require("pygame")
local random = require("random")

RES = {1280, 740}
pygame.init()
screen = pygame.display.set_mode(RES)
clock = pygame.time.Clock()
FPS = 60
pygame.display.set_caption("ex~~PLOSION")
explosion_imgs = pygame.image.load("explosion_3_40_128.png"):convert_alpha()

Megumin = {}
Megumin.__index = Megumin

function Megumin.new(sprite_sheet, animation_steps)
    local self = setmetatable({}, Megumin)
    self.image = pygame.transform.scale(pygame.image.load("megumin2.png"):convert_alpha(), {300, 270})
    self.rect = self.image.get_rect(center={100, 450})
    self.aim_rect = pygame.Rect(self.rect.centerx, self.rect.centery, 20, 20)
    self.vel_y = 0
    self.vel_x = 0
    self.health = 1000
    self.mana = 100000
    self.size = 128
    self.alive = true
    self.image_scale = 4
    self.attack_type = 0
    self.jumped = false
    self.frame_index = 0
    self.explosion_stage = 0
    self.explosion_animation_list = self:load_images(sprite_sheet, animation_steps)
    self.explosion_image = self.explosion_animation_list[self.explosion_stage][self.frame_index]
    self.explosion_frame_count = 0
    self.explosion_animation_speed = 5
    self.attacking = false
    self.aiming = false
    self.moving = false
    return self
end

function Megumin:regenerate()
    if self.alive then
        if not self.attacking and not self.moving then
            if self.health < 1000 then
                self.health = self.health + 0.2
            end
            if self.mana < 100000 then
                self.mana = self.mana + 100
            end
        end
    end
end

function Megumin:move(boss)
    if self.health < 0 then
        self.alive = false
    end
    if self.alive then
        local aim_dx = 0
        local speed = 6
        local dx = 0
        local dy = 0
        local gravity = 0.5
        self.vel_y = self.vel_y + gravity
        dy = dy + self.vel_y
        local keys = pygame.key.get_pressed()
        if not self.attacking then
            if keys[pygame.K_a] or keys[pygame.K_d] or keys[pygame.K_w] or keys[pygame.K_s] then
                self.moving = true
                if keys[pygame.K_a] then
                    dx = dx - speed
                end
                if keys[pygame.K_d] then
                    dx = dx + speed
                end
                if keys[pygame.K_w] and not self.jumped then
                    self.vel_y = -18
                    dy = dy + self.vel_y
                    self.jumped = true
                end
                if keys[pygame.K_s] then
                    self.vel_y = 10
                    dy = dy + self.vel_y
                end
            else
                self.moving = false
            end
        end
        if keys[pygame.K_r] or keys[pygame.K_t] or keys[pygame.K_SPACE] then
            self.aiming = true
            local aim_speed = 2
            local locked = false
            if keys[pygame.K_r] then
                aim_dx = aim_dx - aim_speed
            end
            if keys[pygame.K_t] then
                aim_dx = aim_dx + aim_speed
            end
            if keys[pygame.K_SPACE] then
                self.attacking = true
                if self.attack_type == 0 then
                    -- Perform attack type 0
                    boss.health = boss.health - 10
                elseif self.attack_type == 1 then
                    -- Perform attack type 1
                    boss.health = boss.health - 20
                elseif self.attack_type == 2 then
                    -- Perform attack type 2
                    boss.health = boss.health - 30
                end
            end
        else
            self.aiming = false
            self.attacking = false
        end
        
        -- Update position
        self.rect.x = self.rect.x + dx
        self.rect.y = self.rect.y + dy
        
        -- Handle collisions with boss
        if self.rect.colliderect(boss.rect) then
            self.rect.y = boss.rect.y - self.rect.height
            self.vel_y = 0
            self.jumped = false
        end
        
        -- Update aim position
        self.aim_rect.centerx = self.rect.centerx + aim_dx
        self.aim_rect.centery = self.rect.centery
        
        -- Update explosion animation
        if self.attacking then
            self.explosion_frame_count = self.explosion_frame_count + 1
            if self.explosion_frame_count >= self.explosion_animation_speed then
                self.frame_index = self.frame_index + 1
                if self.frame_index >= #self.explosion_animation_list[self.explosion_stage] then
                    self.frame_index = 0
                    self.explosion_stage = (self.explosion_stage + 1) % #self.explosion_animation_list
                end
                self.explosion_frame_count = 0
            end
            self.explosion_image = self.explosion_animation_list[self.explosion_stage][self.frame_index]
        end
        
        -- Draw player
        screen.blit(self.image, self.rect)
        
        -- Draw aim indicator
        pygame.draw.rect(screen, (255, 0, 0), self.aim_rect)
    end
end

Boss = {}
Boss.__index = Boss

function Boss.new()
    local self = setmetatable({}, Boss)
    self.image = pygame.image.load("boss.png"):convert_alpha()
    self.rect = self.image.get_rect(center={600, 400})
    self.health = 1000
    return self
end

function Boss:update()
    -- Update boss logic here
end

-- Create player and boss instances
player = Megumin.new("explosion_3_40_128.png", 6)
boss = Boss.new()

-- Game loop
running = true
while running do
    -- Event handling
    for event in pygame.event.get() do
        if event.type == pygame.QUIT then
            running = false
        end
    end
    
    -- Update player and boss
    player:move(boss)
    boss:update()
    
    -- Render screen
    screen.fill((0, 0, 0))
    screen.blit(boss.image, boss.rect)
    screen.blit(player.explosion_image, player.rect)
    pygame.display.flip()
    
    -- Set FPS
    clock.tick(FPS)
    
    -- Player regeneration
    player:regenerate()
end

-- Quit pygame
pygame.quit()
