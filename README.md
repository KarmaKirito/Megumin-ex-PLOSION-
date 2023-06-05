THIS CODE IS TRANSFORMED FROM PYTHON INTO LUA, THERE MAY BE QUITE MANY ISSUES.
main code in python:
import pygame
import sys
import random

RES = (1280, 740)
pygame.init()
screen = pygame.display.set_mode(RES)
clock = pygame.time.Clock()
FPS = 60
pygame.display.set_caption(ex~PLOSION!)
explosion_imgs = pygame.image.load('explosion_3_40_128.png').convert_alpha()


class Megumin:
    def __init__(self, sprite_sheet, animation_steps):
        self.image = pygame.transform.scale(pygame.image.load("megumin2.png").convert_alpha(), (300, 270))
        self.rect = self.image.get_rect(center=(100, 450))
        self.aim_rect = pygame.Rect(self.rect.centerx, self.rect.centery, 20, 20)
        self.vel_y = 0
        self.vel_x = 0
        self.health = 1000
        self.mana = 100000
        self.size = 128
        self.alive = True
        self.image_scale = 4
        self.attack_type = 0
        self.jumped = False
        self.frame_index = 0
        self.explosion_stage = 0
        self.explosion_animation_list = self.load_images(sprite_sheet, animation_steps)
        self.explosion_image = self.explosion_animation_list[self.explosion_stage][self.frame_index]
        self.explosion_frame_count = 0
        self.explosion_animation_speed = 5
        self.attacking = False
        self.aiming = False
        self.moving = False

    def regenerate(self):
        if self.alive:
            if not self.attacking and not self.moving:
                if self.health < 1000:
                    self.health += 0.2
                if self.mana < 100000:
                    self.mana += 100

    def move(self, boss):
        if self.health < 0:
            self.alive = False
        if self.alive:
            aim_dx = 0
            speed = 6
            dx = 0
            dy = 0
            gravity = 0.5
            self.vel_y += gravity
            dy += self.vel_y
            keys = pygame.key.get_pressed()
            if not self.attacking:
                if keys[pygame.K_a] or keys[pygame.K_d] or keys[pygame.K_w] or keys[pygame.K_s]:
                    self.moving = True
                    if keys[pygame.K_a]:
                        dx -= speed
                    if keys[pygame.K_d]:
                        dx += speed
                    if keys[pygame.K_w] and not self.jumped:
                        self.vel_y = -18
                        dy += self.vel_y
                        self.jumped = True
                    if keys[pygame.K_s]:
                        self.vel_y = 10
                        dy += self.vel_y
                else:
                    self.moving = False
            if keys[pygame.K_r] or keys[pygame.K_t] or keys[pygame.K_SPACE]:
                self.aiming = True
                aim_speed = 2
                locked = False
                if keys[pygame.K_SPACE]:
                    aim_dx = 0
                    locked = True
                if not locked:
                    if keys[pygame.K_r]:
                        aim_dx -= aim_speed
                    if keys[pygame.K_t]:
                        aim_dx += aim_speed
                self.aim_rect.x += aim_dx
            else:
                self.aiming = False
            if keys[pygame.K_j]:
                self.attack_type = 1
                self.explosion(boss)
                self.attacking = True
            else:
                self.attack_type = 0
                self.attacking = False
                self.explosion_stage = 0
                self.frame_index = 0
            self.rect.y += gravity
            if self.rect.left + dx < 0:
                dx = -self.rect.left
            if self.rect.right + dx > RES[0]:
                dx = RES[0] - self.rect.right
            if self.rect.bottom >= RES[1] - int(340 / 3):  # Check if touching or below the ground
                self.rect.bottom = RES[1] - int(340 / 3)  # Set the player's position exactly on the ground
                self.vel_y = 0  # Reset the vertical velocity
                self.jumped = False
            self.regenerate()
            dx += self.vel_x
            self.rect.x += dx
            self.rect.y += dy

    def explosion(self, boss):
        attack_rect = pygame.Rect(self.aim_rect.centerx, self.aim_rect.centery, 10, 50)
        if self.attack_type == 1:
            self.mana -= 100
            pygame.draw.rect(screen, (0, 0, 0), attack_rect)
            self.animate_explosion()
            if attack_rect.colliderect(boss.rect):
                boss.health -= 10000
        else:
            self.attack_type = 0

    def animate_explosion(self):
        self.explosion_frame_count += 1
        if self.explosion_frame_count >= self.explosion_animation_speed:
            self.frame_index += 1
            self.explosion_frame_count = 0
            if self.frame_index >= len(self.explosion_animation_list[self.explosion_stage]):
                self.frame_index = 0
                self.explosion_stage += 1
                if self.explosion_stage >= len(self.explosion_animation_list):
                    self.explosion_stage = 0

        self.explosion_image = self.explosion_animation_list[self.explosion_stage][self.frame_index]
        screen.blit(self.explosion_image, (self.aim_rect.centerx - 65*self.image_scale,
                                           self.aim_rect.centery - 60*self.image_scale))

    def load_images(self, sprite_sheet, animation_steps):
        animation_list = []
        for y, animation in enumerate(animation_steps):
            temp_img_list = []
            for x in range(animation):
                temp_img = sprite_sheet.subsurface(x * self.size, y * self.size, self.size, self.size)
                temp_img_list.append(pygame.transform.scale(temp_img, (self.size * self.image_scale,
                                                                       self.size * self.image_scale)))
            animation_list.append(temp_img_list)
        return animation_list

    def draw(self):
        screen.blit(self.image, self.rect)
        if self.aiming:
            pygame.draw.rect(screen, (255, 255, 255), self.aim_rect)


class Boss:
    def __init__(self):
        self.health = 10000000
        self.alive = True
        self.image = pygame.transform.scale(pygame.image.load('frog_img.png').convert_alpha(), (500, 300))
        self.rect = self.image.get_rect(center=(900, 500))
        self.mana = 10000
        self.attack_cooldown = 1000
        self.left = True
        self.vel_x = 0
        self.vel_y = 0

    def move(self, multiplayer):
        if self.health < 0:
            self.alive = False
        if self.alive:
            dx = 0
            dy = 0
            gravity = 0.2
            self.vel_y += gravity
            dy += self.vel_y
            if not multiplayer:
                if self.left:
                    self.vel_x = -1
                else:
                    self.vel_x = 1
                if self.rect.left + dx < 0:
                    dx = -self.rect.left
                if self.rect.left == 0:
                    self.left = False
                if self.rect.right == RES[0]:
                    self.left = True
                if self.rect.left + dx > RES[0]:
                    dx = RES[0] - self.rect.left
            if self.rect.bottom >= RES[1] - int(340 / 3):  # Check if touching or below the ground
                self.rect.bottom = RES[1] - int(340 / 3)  # Set the player's position exactly on the ground
                self.vel_y = 0  # Reset the vertical velocity
            dx += self.vel_x
            self.rect.x += dx
            self.rect.y += dy

    def attack(self, player):
        attack_rect = pygame.Rect(self.rect.centerx, self.rect.centery, 100, self.rect.width)
        if attack_rect.colliderect(player.rect):
            if player.health > 0:
                player.health -= 5

    def draw(self):
        screen.blit(self.image, self.rect)


explosion_animation_steps = [8, 8, 8, 8, 7]
megumin = Megumin(explosion_imgs, explosion_animation_steps)
boss = Boss()


def get_font(size):
    return pygame.font.Font('font.ttf', size)


def draw(health, total_health, mana, total_mana, x, y):
    ratio1 = health/total_health
    ratio2 = mana /total_mana
    white = pygame.Rect(x-2, y-2, 200, 30)
    white1 = pygame.Rect(x-2, y + 30, 104, 20)
    purple = pygame.Rect(x, y+32, 100*ratio2, 16)
    red = pygame.Rect(x, y, 196*ratio1, 26)
    pygame.draw.rect(screen, (255, 255, 255), white1)
    pygame.draw.rect(screen, (146, 13, 148), purple)
    pygame.draw.rect(screen, (255, 255, 255), white)
    pygame.draw.rect(screen, (235, 41, 7), red)


def game():
    bg = pygame.transform.scale(pygame.image.load('megumin.bg.png').convert_alpha(), (1280, 740))
    base = pygame.image.load('parralax/ground.png').convert_alpha()
    while True:
        screen.blit(bg, (0, 0))
        for i in range(2):
            screen.blit(base, (i*base.get_width(), RES[1] - base.get_height()))
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()
        draw(megumin.health, 1000, megumin.mana, 100000, 30, 30)
        draw(boss.health, 10000000, boss.mana, 10000, 900, 30)
        boss.draw()
        megumin.draw()
        megumin.move(boss)
        boss.move(False)
        boss.attack(megumin)
        if not boss.alive or not megumin.alive:
            game_over = True
        else:
            game_over = False
        if game_over:
            if not boss.alive:
                end_text = get_font(45).render("FROGS SLAYED", True, (200, 50, 50))
                screen.blit(end_text, (RES[0]/2 - end_text.get_width()/2, RES[1]/2))
            if not megumin.alive:
                end_text = get_font(45).render("GET EATEN BY FROGS", True, (200, 50, 50))
                screen.fill((50, 200, 50))
                screen.blit(pygame.transform.scale(pygame.image.load('slimy_bg.png').convert_alpha(), (1280, 740)), (0, 0))
                eaten_by_frog = pygame.transform.scale(pygame.image.load('megumin_eaten_by_frog.png').convert_alpha(),
                                                       (500, 740))
                screen.blit(eaten_by_frog, (RES[0]/2 - eaten_by_frog.get_width()/2, 0))
                screen.blit(end_text, (RES[0]/2 - end_text.get_width()/2, RES[1]/2))

        pygame.display.flip()
        pygame.display.update()


game()

