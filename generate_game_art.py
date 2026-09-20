"""
Gera os sprites e tiles para o mini-jogo estilo Zelda de Kurions — Saga Origens (5 Fases e Monstros)
"""
import os
import math
from PIL import Image, ImageDraw

def generate_game_assets():
    os.makedirs('images/game', exist_ok=True)
    size = 80

    # 1. Tile Chão (Floor)
    floor = Image.new('RGBA', (size, size), color=(18, 24, 42, 255))
    df = ImageDraw.Draw(floor)
    df.rectangle([1, 1, size-2, size-2], fill=(22, 30, 52, 255), outline=(30, 42, 70, 255), width=1)
    df.line([(10, 20), (30, 20)], fill=(40, 55, 90, 180), width=1)
    df.line([(50, 60), (70, 60)], fill=(40, 55, 90, 180), width=1)
    df.rectangle([38, 38, 42, 42], fill=(56, 189, 248, 40))
    floor.save('images/game/tile_floor.png', 'PNG')

    # 2. Tile Parede de Pedra Ancestral (Wall)
    wall = Image.new('RGBA', (size, size), color=(10, 14, 24, 255))
    dw = ImageDraw.Draw(wall)
    dw.rectangle([2, 2, size-3, size-3], fill=(30, 41, 59, 255), outline=(51, 65, 85, 255), width=2)
    dw.line([(2, 26), (size-3, 26)], fill=(15, 23, 42, 255), width=2)
    dw.line([(2, 54), (size-3, 54)], fill=(15, 23, 42, 255), width=2)
    dw.line([(38, 2), (38, 26)], fill=(15, 23, 42, 255), width=2)
    dw.line([(20, 26), (20, 54)], fill=(15, 23, 42, 255), width=2)
    dw.line([(60, 26), (60, 54)], fill=(15, 23, 42, 255), width=2)
    dw.line([(40, 54), (40, size-3)], fill=(15, 23, 42, 255), width=2)
    dw.line([(42, 8), (48, 16), (44, 22)], fill=(56, 189, 248, 220), width=2)
    wall.save('images/game/tile_wall.png', 'PNG')

    # 3. Koli (Player Token)
    koli = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dk = ImageDraw.Draw(koli)
    dk.ellipse([16, 56, 64, 76], fill=(0, 0, 0, 100))
    dk.polygon([(26, 36), (54, 36), (62, 66), (18, 66)], fill=(30, 58, 138, 255), outline=(56, 189, 248, 255), width=2)
    dk.line([(22, 52), (58, 52)], fill=(251, 191, 36, 255), width=3)
    dk.ellipse([25, 12, 55, 42], fill=(120, 53, 15, 255))
    dk.ellipse([28, 18, 52, 40], fill=(254, 215, 170, 255))
    dk.rectangle([25, 12, 55, 24], fill=(120, 53, 15, 255))
    dk.ellipse([33, 26, 37, 30], fill=(30, 41, 59, 255))
    dk.ellipse([43, 26, 47, 30], fill=(30, 41, 59, 255))
    dk.ellipse([37, 42, 43, 48], fill=(56, 189, 248, 255), outline=(251, 191, 36, 255), width=1)
    koli.save('images/game/koli_player.png', 'PNG')

    # 4. Pagonix (Companion Token)
    pago = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dp = ImageDraw.Draw(pago)
    dp.ellipse([20, 54, 60, 72], fill=(0, 0, 0, 90))
    dp.ellipse([22, 28, 58, 58], fill=(16, 185, 129, 255), outline=(34, 197, 94, 255), width=2)
    dp.polygon([(40, 32), (48, 42), (40, 50), (32, 42)], fill=(56, 189, 248, 240), outline=(255, 255, 255, 255), width=1)
    dp.ellipse([18, 48, 28, 58], fill=(5, 150, 105, 255))
    dp.ellipse([52, 48, 62, 58], fill=(5, 150, 105, 255))
    dp.ellipse([34, 14, 46, 32], fill=(52, 211, 153, 255), outline=(16, 185, 129, 255), width=2)
    dp.ellipse([37, 20, 39, 22], fill=(6, 78, 59, 255))
    dp.ellipse([41, 20, 43, 22], fill=(6, 78, 59, 255))
    pago.save('images/game/pagonix_player.png', 'PNG')

    # 5. Baú Fechado e Aberto
    chest = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dc = ImageDraw.Draw(chest)
    dc.ellipse([14, 56, 66, 74], fill=(0, 0, 0, 100))
    dc.rounded_rectangle([16, 26, 64, 62], radius=6, fill=(180, 83, 9, 255), outline=(251, 191, 36, 255), width=2)
    dc.line([(16, 42), (64, 42)], fill=(251, 191, 36, 255), width=3)
    dc.rectangle([36, 39, 44, 48], fill=(251, 191, 36, 255), outline=(120, 53, 15, 255), width=1)
    dc.ellipse([39, 42, 41, 44], fill=(15, 23, 42, 255))
    chest.save('images/game/tile_chest.png', 'PNG')

    chest_o = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dco = ImageDraw.Draw(chest_o)
    dco.ellipse([14, 56, 66, 74], fill=(0, 0, 0, 100))
    dco.rectangle([16, 36, 64, 62], fill=(146, 64, 14, 255), outline=(251, 191, 36, 255), width=2)
    dco.polygon([(16, 36), (64, 36), (58, 16), (22, 16)], fill=(180, 83, 9, 255), outline=(251, 191, 36, 255), width=2)
    dco.polygon([(30, 36), (40, 20), (50, 36)], fill=(56, 189, 248, 220))
    chest_o.save('images/game/tile_chest_open.png', 'PNG')

    # 6. Cristal de Aether
    crys = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dcr = ImageDraw.Draw(crys)
    dcr.ellipse([20, 56, 60, 72], fill=(56, 189, 248, 60))
    dcr.polygon([(40, 12), (56, 36), (40, 64), (24, 36)], fill=(14, 165, 233, 230), outline=(255, 255, 255, 255), width=2)
    dcr.line([(40, 12), (40, 64)], fill=(255, 255, 255, 240), width=2)
    crys.save('images/game/tile_crystal.png', 'PNG')

    # 7. Altar Inativo e Ativo
    altar = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    da = ImageDraw.Draw(altar)
    da.rounded_rectangle([12, 40, 68, 68], radius=4, fill=(51, 65, 85, 255), outline=(100, 116, 139, 255), width=2)
    da.rounded_rectangle([20, 24, 60, 44], radius=4, fill=(71, 85, 105, 255), outline=(148, 163, 184, 255), width=2)
    da.ellipse([32, 16, 48, 28], fill=(30, 41, 59, 255), outline=(100, 116, 139, 255), width=2)
    altar.save('images/game/tile_altar.png', 'PNG')

    altar_act = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    daa = ImageDraw.Draw(altar_act)
    daa.rounded_rectangle([12, 40, 68, 68], radius=4, fill=(30, 58, 138, 255), outline=(56, 189, 248, 255), width=2)
    daa.rounded_rectangle([20, 24, 60, 44], radius=4, fill=(14, 165, 233, 255), outline=(255, 255, 255, 255), width=2)
    daa.polygon([(30, 24), (50, 24), (56, 4), (24, 4)], fill=(56, 189, 248, 180))
    daa.polygon([(40, 6), (48, 20), (40, 30), (32, 20)], fill=(255, 255, 255, 255), outline=(251, 191, 36, 255), width=1)
    altar_act.save('images/game/tile_altar_act.png', 'PNG')

    # 8. Barreira Sombria
    barr = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dbar = ImageDraw.Draw(barr)
    dbar.rectangle([8, 8, size-9, size-9], fill=(59, 7, 100, 220), outline=(147, 51, 234, 255), width=2)
    for i in range(12, 68, 12):
        dbar.line([(i, 10), (size-10, size-i)], fill=(192, 132, 252, 150), width=2)
        dbar.line([(10, i), (size-i, size-10)], fill=(192, 132, 252, 150), width=2)
    dbar.ellipse([26, 26, 54, 54], fill=(88, 28, 135, 240), outline=(239, 68, 68, 255), width=2)
    dbar.polygon([(40, 30), (48, 46), (32, 46)], fill=(239, 68, 68, 255))
    barr.save('images/game/tile_barrier.png', 'PNG')

    # 9. Portal
    door = Image.new('RGBA', (size, size), color=(10, 14, 24, 255))
    dd = ImageDraw.Draw(door)
    dd.rounded_rectangle([10, 8, size-11, size-4], radius=24, fill=(15, 23, 42, 255), outline=(56, 189, 248, 255), width=3)
    for r in range(24, 0, -4):
        dd.ellipse([40-r, 45-r, 40+r, 45+r], fill=(56, 189, 248, int(80 * (1 - r/24))))
    door.save('images/game/tile_door.png', 'PNG')

    # ==========================================
    # NOVOS MONSTROS E MECÂNICAS (5 FASES)
    # ==========================================

    # 10. Monstro: Espectro das Sombras (Shadow Wisp)
    wisp = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dwi = ImageDraw.Draw(wisp)
    dwi.ellipse([16, 58, 64, 74], fill=(0, 0, 0, 110))
    # Corpo fantasmagórico roxo/sombra
    dwi.ellipse([20, 14, 60, 58], fill=(76, 29, 149, 240), outline=(192, 132, 252, 255), width=2)
    dwi.polygon([(22, 50), (32, 68), (40, 54), (48, 68), (58, 50)], fill=(76, 29, 149, 240), outline=(192, 132, 252, 255))
    # Olhos vermelhos malévolos da Dark Team
    dwi.ellipse([28, 28, 36, 36], fill=(239, 68, 68, 255))
    dwi.ellipse([44, 28, 52, 36], fill=(239, 68, 68, 255))
    dwi.ellipse([31, 30, 34, 33], fill=(255, 255, 255, 255))
    dwi.ellipse([47, 30, 50, 33], fill=(255, 255, 255, 255))
    wisp.save('images/game/monster_shadow.png', 'PNG')

    # 11. Monstro: Soldado da Dark Team (Dark Team Grunt)
    grunt = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dg = ImageDraw.Draw(grunt)
    dg.ellipse([16, 56, 64, 76], fill=(0, 0, 0, 120))
    # Armadura preta e ombreiras roxas
    dg.polygon([(24, 34), (56, 34), (64, 68), (16, 68)], fill=(15, 23, 42, 255), outline=(147, 51, 234, 255), width=2)
    # Capuz sombrio
    dg.ellipse([24, 10, 56, 42], fill=(30, 27, 75, 255), outline=(88, 28, 135, 255), width=2)
    dg.ellipse([28, 18, 52, 40], fill=(15, 23, 42, 255))
    # Visor vermelho ameaçador
    dg.line([(30, 28), (50, 28)], fill=(239, 68, 68, 255), width=3)
    grunt.save('images/game/monster_grunt.png', 'PNG')

    # 12. Monstro: Golem Sombrio (Golem de Pedra Corrompido)
    golem = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dgo = ImageDraw.Draw(golem)
    dgo.ellipse([14, 56, 66, 76], fill=(0, 0, 0, 140))
    # Corpo maciço de pedra escura
    dgo.rounded_rectangle([18, 24, 62, 68], radius=8, fill=(30, 41, 59, 255), outline=(100, 116, 139, 255), width=3)
    # Braços pesados de pedra
    dgo.rectangle([10, 32, 18, 58], fill=(51, 65, 85, 255), outline=(100, 116, 139, 255), width=1)
    dgo.rectangle([62, 32, 70, 58], fill=(51, 65, 85, 255), outline=(100, 116, 139, 255), width=1)
    # Cabeça esculpida
    dgo.rounded_rectangle([26, 10, 54, 30], radius=4, fill=(51, 65, 85, 255), outline=(147, 51, 234, 255), width=2)
    # Cristal sombrio pulsando no peito
    dgo.polygon([(40, 36), (48, 48), (40, 60), (32, 48)], fill=(168, 85, 247, 240), outline=(239, 68, 68, 255), width=1)
    dgo.ellipse([32, 18, 36, 22], fill=(239, 68, 68, 255))
    dgo.ellipse([44, 18, 48, 22], fill=(239, 68, 68, 255))
    golem.save('images/game/monster_golem.png', 'PNG')

    # 13. Chefe Final: A Entidade do Vórtice Sombrio (Dark Vortex Boss)
    boss = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    db = ImageDraw.Draw(boss)
    db.ellipse([10, 54, 70, 76], fill=(0, 0, 0, 160))
    for r in range(36, 0, -6):
        db.ellipse([40-r, 38-r, 40+r, 38+r], fill=(59, 7, 100, int(180 * (1 - r/36))), outline=(239, 68, 68, 200), width=1)
    # Garras/Tentáculos de névoa
    db.polygon([(40, 4), (54, 24), (40, 20)], fill=(126, 34, 206, 255))
    db.polygon([(14, 28), (28, 36), (22, 46)], fill=(126, 34, 206, 255))
    db.polygon([(66, 28), (52, 36), (58, 46)], fill=(126, 34, 206, 255))
    # Olho central ancestral corrompido
    db.ellipse([26, 26, 54, 50], fill=(239, 68, 68, 255), outline=(254, 240, 138, 255), width=2)
    db.ellipse([34, 30, 46, 46], fill=(15, 23, 42, 255))
    db.ellipse([38, 34, 42, 38], fill=(255, 255, 255, 255))
    boss.save('images/game/monster_boss.png', 'PNG')

    # 14. Tile Espinhos / Chão Perigoso (Spikes)
    spikes = Image.new('RGBA', (size, size), color=(18, 24, 42, 255))
    dsp = ImageDraw.Draw(spikes)
    dsp.rectangle([1, 1, size-2, size-2], fill=(22, 30, 52, 255), outline=(30, 42, 70, 255), width=1)
    # Espinhos metálicos da Dark Team
    for sx, sy in [(20, 30), (40, 20), (60, 30), (30, 50), (50, 50)]:
        dsp.polygon([(sx, sy-14), (sx+8, sy+10), (sx-8, sy+10)], fill=(148, 163, 184, 255), outline=(239, 68, 68, 255), width=1)
        dsp.line([(sx, sy-14), (sx, sy+10)], fill=(255, 255, 255, 200))
    spikes.save('images/game/tile_spike.png', 'PNG')

    # 15. Tile Gaiola com Kurion Aprisionado (Cage)
    cage = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dcg = ImageDraw.Draw(cage)
    dcg.ellipse([14, 56, 66, 76], fill=(0, 0, 0, 100))
    # Kurion bebê dentro
    dcg.ellipse([30, 34, 50, 54], fill=(52, 211, 153, 240), outline=(16, 185, 129, 255), width=2)
    dcg.ellipse([35, 38, 38, 42], fill=(15, 23, 42, 255))
    dcg.ellipse([42, 38, 45, 42], fill=(15, 23, 42, 255))
    # Barras de ferro da gaiola
    dcg.rectangle([18, 20, 62, 64], fill=(0, 0, 0, 0), outline=(100, 116, 139, 255), width=3)
    for bx in [28, 38, 48]:
        dcg.line([(bx, 20), (bx, 64)], fill=(148, 163, 184, 255), width=3)
    # Fechadura sombria
    dcg.rectangle([36, 42, 44, 52], fill=(239, 68, 68, 255), outline=(251, 191, 36, 255), width=1)
    cage.save('images/game/tile_cage.png', 'PNG')

    cage_o = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dcgo = ImageDraw.Draw(cage_o)
    dcgo.ellipse([14, 56, 66, 76], fill=(0, 0, 0, 100))
    # Gaiola arrombada vazia
    dcgo.rectangle([18, 20, 62, 64], fill=(0, 0, 0, 0), outline=(71, 85, 105, 200), width=2)
    dcgo.line([(28, 20), (24, 64)], fill=(71, 85, 105, 200), width=2)
    dcgo.line([(48, 20), (52, 64)], fill=(71, 85, 105, 200), width=2)
    # Brilho de liberdade
    dcgo.ellipse([34, 34, 46, 46], fill=(34, 197, 94, 220))
    cage_o.save('images/game/tile_cage_open.png', 'PNG')

    # 16. Tile Interruptor / Botão de Piso (Switch Off / On)
    sw = Image.new('RGBA', (size, size), color=(18, 24, 42, 255))
    dsw = ImageDraw.Draw(sw)
    dsw.rectangle([1, 1, size-2, size-2], fill=(22, 30, 52, 255), outline=(30, 42, 70, 255), width=1)
    dsw.rounded_rectangle([22, 22, 58, 58], radius=8, fill=(51, 65, 85, 255), outline=(100, 116, 139, 255), width=2)
    dsw.ellipse([32, 32, 48, 48], fill=(239, 68, 68, 255), outline=(185, 28, 28, 255), width=2)
    sw.save('images/game/tile_switch.png', 'PNG')

    sw_on = Image.new('RGBA', (size, size), color=(18, 24, 42, 255))
    dswo = ImageDraw.Draw(sw_on)
    dswo.rectangle([1, 1, size-2, size-2], fill=(22, 30, 52, 255), outline=(30, 42, 70, 255), width=1)
    dswo.rounded_rectangle([22, 22, 58, 58], radius=8, fill=(30, 58, 138, 255), outline=(56, 189, 248, 255), width=2)
    dswo.ellipse([32, 32, 48, 48], fill=(34, 197, 94, 255), outline=(255, 255, 255, 255), width=2)
    sw_on.save('images/game/tile_switch_on.png', 'PNG')

    # 17. Tile Motor de Cristal do Dirigível (Motor Off / On)
    mot = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dm = ImageDraw.Draw(mot)
    dm.rounded_rectangle([14, 20, 66, 68], radius=6, fill=(51, 65, 85, 255), outline=(100, 116, 139, 255), width=2)
    dm.ellipse([26, 28, 54, 56], fill=(30, 41, 59, 255), outline=(71, 85, 105, 255), width=2)
    dm.ellipse([34, 36, 46, 48], fill=(148, 163, 184, 200))
    mot.save('images/game/tile_motor.png', 'PNG')

    mot_on = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dmo = ImageDraw.Draw(mot_on)
    dmo.rounded_rectangle([14, 20, 66, 68], radius=6, fill=(30, 58, 138, 255), outline=(56, 189, 248, 255), width=2)
    dmo.ellipse([26, 28, 54, 56], fill=(14, 165, 233, 255), outline=(255, 255, 255, 255), width=2)
    dmo.ellipse([34, 36, 46, 48], fill=(255, 255, 255, 255))
    for ang in [0, 45, 90, 135, 180, 225, 270, 315]:
        rad = math.radians(ang)
        x1 = 40 + int(18 * math.cos(rad))
        y1 = 42 + int(18 * math.sin(rad))
        x2 = 40 + int(28 * math.cos(rad))
        y2 = 42 + int(28 * math.sin(rad))
        dmo.line([(x1, y1), (x2, y2)], fill=(251, 191, 36, 255), width=2)
    mot_on.save('images/game/tile_motor_on.png', 'PNG')

    # 18. Raio / Feixe de Luz de Cristal (Light Beam)
    beam = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dbm = ImageDraw.Draw(beam)
    for r in range(28, 0, -4):
        dbm.ellipse([40-r, 40-r, 40+r, 40+r], fill=(56, 189, 248, int(150 * (1 - r/28))))
    dbm.polygon([(40, 10), (52, 40), (40, 70), (28, 40)], fill=(255, 255, 255, 255), outline=(251, 191, 36, 255), width=2)
    beam.save('images/game/light_beam.png', 'PNG')

    # 19. Item: Gema de Aether (Drop Moeda)
    gem = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dgm = ImageDraw.Draw(gem)
    dgm.ellipse([22, 54, 58, 68], fill=(0, 0, 0, 90))
    dgm.polygon([(40, 16), (58, 32), (40, 62), (22, 32)], fill=(251, 191, 36, 255), outline=(245, 158, 11, 255), width=2)
    dgm.polygon([(40, 22), (52, 32), (40, 56), (28, 32)], fill=(254, 240, 138, 255))
    gem.save('images/game/item_gem.png', 'PNG')

    # 20. Item: Coração de Vida (Drop Cura)
    heart = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dht = ImageDraw.Draw(heart)
    dht.ellipse([22, 54, 58, 68], fill=(0, 0, 0, 90))
    # Desenho do coração
    dht.ellipse([22, 22, 42, 42], fill=(239, 68, 68, 255))
    dht.ellipse([38, 22, 58, 42], fill=(239, 68, 68, 255))
    dht.polygon([(22, 34), (58, 34), (40, 60)], fill=(239, 68, 68, 255))
    dht.ellipse([26, 26, 32, 32], fill=(255, 255, 255, 200)) # Brilho
    heart.save('images/game/item_heart.png', 'PNG')

    # 21. Habilidade: Escudo de Cristal do Pagonix (Shield Dome)
    shield = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
    dsh = ImageDraw.Draw(shield)
    for r in range(36, 0, -4):
        dsh.ellipse([40-r, 40-r, 40+r, 40+r], fill=(56, 189, 248, int(60 * (1 - r/36))))
    dsh.ellipse([6, 6, 74, 74], outline=(56, 189, 248, 255), width=3)
    dsh.ellipse([12, 12, 68, 68], outline=(251, 191, 36, 200), width=1)
    # Hexágonos de cristal no escudo
    for ang in range(0, 360, 60):
        rad = math.radians(ang)
        x = 40 + int(24 * math.cos(rad))
        y = 40 + int(24 * math.sin(rad))
        dsh.ellipse([x-4, y-4, x+4, y+4], fill=(255, 255, 255, 230))
    shield.save('images/game/pagonix_shield.png', 'PNG')

    # 22. Avatar: Mercador do Dirigível (Shop NPC)
    shop = Image.new('RGBA', (140, 140), color=(15, 23, 42, 255))
    dsk = ImageDraw.Draw(shop)
    dsk.rectangle([0, 0, 140, 140], outline=(251, 191, 36, 255), width=2)
    dsk.ellipse([30, 20, 110, 100], fill=(180, 83, 9, 255), outline=(251, 191, 36, 255), width=2)
    dsk.ellipse([45, 35, 95, 85], fill=(254, 215, 170, 255))
    dsk.rectangle([40, 25, 100, 45], fill=(120, 53, 15, 255)) # Chapéu de explorador
    dsk.ellipse([52, 50, 60, 58], fill=(15, 23, 42, 255))
    dsk.ellipse([80, 50, 88, 58], fill=(15, 23, 42, 255))
    dsk.rectangle([0, 110, 140, 140], fill=(10, 15, 30, 240))
    dsk.text((70, 125), 'EXPLORADOR', fill=(251, 191, 36, 255), anchor='mm', font_size=12)
    shop.save('images/game/shop_avatar.png', 'PNG')

    print("[OK] Todos os 22 Sprites e Tiles para a Campanha com Drops, Escudo e Loja gerados com sucesso!")

if __name__ == '__main__':
    generate_game_assets()
