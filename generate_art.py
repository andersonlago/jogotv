"""
Script para geração das ilustrações temáticas em alta fidelidade para Kurions.
"""
import os
import math
from PIL import Image, ImageDraw

def draw_crystal(draw, cx, cy, size, fill_color, outline_color):
    pts_top = [(cx, cy - size), (cx + size*0.55, cy - size*0.3), (cx, cy + size*0.1), (cx - size*0.55, cy - size*0.3)]
    pts_bot = [(cx, cy + size*0.1), (cx + size*0.55, cy - size*0.3), (cx, cy + size*0.9), (cx - size*0.55, cy - size*0.3)]
    draw.polygon(pts_top, fill=fill_color, outline=outline_color)
    draw.polygon(pts_bot, fill=(fill_color[0]+20, fill_color[1]+20, fill_color[2]+30, 240), outline=outline_color)
    draw.line([(cx, cy - size), (cx, cy + size*0.9)], fill=(255, 255, 255, 200), width=2)

def generate_all():
    os.makedirs('images/lore', exist_ok=True)
    os.makedirs('images/kurions', exist_ok=True)
    os.makedirs('images/characters', exist_ok=True)
    os.makedirs('images/episodes', exist_ok=True)

    # 1. ÍCONE FHD (540x405)
    icon = Image.new('RGBA', (540, 405), color=(8, 13, 26, 255))
    d = ImageDraw.Draw(icon)
    for r in range(180, 0, -10):
        alpha = int(60 * (1 - r/180))
        d.ellipse([270-r, 160-r, 270+r, 160+r], fill=(34, 197, 94, alpha))
    d.rounded_rectangle([18, 18, 522, 387], radius=24, fill=(13, 20, 38, 255), outline=(56, 189, 248, 255), width=3)
    d.rounded_rectangle([24, 24, 516, 381], radius=20, outline=(34, 197, 94, 150), width=1)
    draw_crystal(d, 270, 150, 75, (14, 165, 233, 220), (244, 244, 255, 255))
    d.ellipse([262, 142, 278, 158], fill=(255, 255, 255, 255))
    d.text((270, 275), 'KURIONS', fill=(56, 189, 248, 255), anchor='mm', font_size=44)
    d.text((270, 320), 'SAGA ORIGENS', fill=(251, 191, 36, 255), anchor='mm', font_size=22)
    d.text((270, 355), 'SERIE DE ANIMACAO - 10 ANOS', fill=(148, 163, 184, 255), anchor='mm', font_size=14)
    icon.save('images/icon_fhd.png', 'PNG')

    # 2. COLAR DO COMEÇO (LORE)
    colar = Image.new('RGBA', (800, 500), color=(10, 15, 30, 255))
    dc = ImageDraw.Draw(colar)
    for angle in range(0, 360, 15):
        rad = math.radians(angle)
        x2 = 400 + int(320 * math.cos(rad))
        y2 = 230 + int(240 * math.sin(rad))
        dc.line([(400, 230), (x2, y2)], fill=(56, 189, 248, 30), width=3)
    for i in range(120, 380, 20):
        y = 60 + int((i-250)**2 / 300)
        dc.ellipse([i-6, y-4, i+6, y+4], fill=(251, 191, 36, 220), outline=(217, 119, 6, 255))
    for i in range(420, 680, 20):
        y = 60 + int((i-550)**2 / 300)
        dc.ellipse([i-6, y-4, i+6, y+4], fill=(251, 191, 36, 220), outline=(217, 119, 6, 255))
    dc.polygon([(400, 120), (470, 210), (400, 360), (330, 210)], fill=(14, 165, 233, 230), outline=(251, 191, 36, 255), width=4)
    dc.polygon([(400, 150), (450, 220), (400, 330), (350, 220)], fill=(34, 197, 94, 200), outline=(255, 255, 255, 240), width=2)
    dc.line([(400, 180), (400, 280)], fill=(255, 255, 255, 255), width=3)
    dc.line([(350, 230), (450, 230)], fill=(255, 255, 255, 255), width=3)
    dc.rectangle([0, 430, 800, 500], fill=(7, 10, 20, 230))
    dc.text((400, 455), 'O COLAR DO COMECO', fill=(56, 189, 248, 255), anchor='mm', font_size=26)
    dc.text((400, 480), 'Artefato Ancestral que ressoa com os Kurions', fill=(203, 213, 225, 255), anchor='mm', font_size=16)
    colar.save('images/lore/colar.png', 'PNG')

    # 3. O GRANDE DIRIGÍVEL (LORE)
    diri = Image.new('RGBA', (800, 500), color=(12, 18, 36, 255))
    dd = ImageDraw.Draw(diri)
    for cy, cr in [(160, 70), (200, 90), (140, 60), (320, 80), (350, 100)]:
        dd.ellipse([100, cy, 320, cy+cr], fill=(30, 41, 59, 140))
        dd.ellipse([450, cy, 750, cy+cr], fill=(30, 41, 59, 140))
    dd.ellipse([140, 120, 660, 280], fill=(21, 30, 48, 255), outline=(56, 189, 248, 255), width=3)
    for x in [240, 340, 440, 540]:
        dd.arc([x-30, 122, x+30, 278], start=270, end=90, fill=(34, 197, 94, 200), width=2)
    dd.rounded_rectangle([280, 270, 520, 330], radius=12, fill=(15, 23, 42, 255), outline=(251, 191, 36, 255), width=2)
    for jx in range(300, 500, 28):
        dd.rectangle([jx, 285, jx+16, 310], fill=(251, 191, 36, 255))
    dd.polygon([(110, 170), (145, 190), (145, 210), (110, 230)], fill=(71, 85, 105, 255), outline=(56, 189, 248, 255))
    dd.polygon([(655, 180), (690, 160), (690, 240), (655, 220)], fill=(71, 85, 105, 255), outline=(56, 189, 248, 255))
    dd.rectangle([0, 430, 800, 500], fill=(7, 10, 20, 230))
    dd.text((400, 455), 'O GRANDE DIRIGIVEL', fill=(34, 197, 94, 255), anchor='mm', font_size=26)
    dd.text((400, 480), 'Base Movel e Fortaleza Aerea dos Exploradores', fill=(203, 213, 225, 255), anchor='mm', font_size=16)
    diri.save('images/lore/dirigivel.png', 'PNG')

    # 4. PAGONIX (KURION)
    pago = Image.new('RGBA', (800, 500), color=(10, 20, 30, 255))
    dp = ImageDraw.Draw(pago)
    for r in range(160, 0, -10):
        dp.ellipse([400-r, 220-r, 400+r, 220+r], fill=(34, 197, 94, int(45 * (1 - r/160))))
    dp.ellipse([270, 250, 340, 310], fill=(16, 185, 129, 240), outline=(244, 244, 255, 200), width=2)
    dp.ellipse([460, 250, 530, 310], fill=(16, 185, 129, 240), outline=(244, 244, 255, 200), width=2)
    dp.ellipse([280, 130, 520, 290], fill=(15, 30, 46, 255), outline=(34, 197, 94, 255), width=4)
    c_pts = [(400, 150), (460, 190), (440, 250), (360, 250), (340, 190)]
    dp.polygon(c_pts, fill=(56, 189, 248, 160), outline=(255, 255, 255, 220), width=2)
    for pt in c_pts:
        dp.line([(400, 205), pt], fill=(255, 255, 255, 180), width=1)
    dp.ellipse([460, 140, 560, 220], fill=(52, 211, 153, 255), outline=(34, 197, 94, 255), width=3)
    dp.ellipse([510, 160, 535, 185], fill=(255, 255, 255, 255))
    dp.ellipse([518, 166, 530, 178], fill=(15, 23, 42, 255))
    dp.ellipse([524, 168, 528, 172], fill=(255, 255, 255, 255))
    dp.arc([510, 180, 545, 205], start=0, end=180, fill=(6, 78, 59, 255), width=2)
    dp.rectangle([0, 430, 800, 500], fill=(7, 10, 20, 230))
    dp.text((400, 455), 'PAGONIX - "PAGO! PAGO!"', fill=(34, 197, 94, 255), anchor='mm', font_size=26)
    dp.text((400, 480), 'Kurion Cristal/Terrestre - Parceiro de Koli', fill=(203, 213, 225, 255), anchor='mm', font_size=16)
    pago.save('images/kurions/pagonix.png', 'PNG')

    # 5. CHALICRFAX (KURION)
    chali = Image.new('RGBA', (800, 500), color=(14, 18, 38, 255))
    dch = ImageDraw.Draw(chali)
    dch.polygon([(400, 240), (160, 90), (260, 260)], fill=(56, 189, 248, 180), outline=(255, 255, 255, 220), width=2)
    dch.polygon([(400, 240), (640, 90), (540, 260)], fill=(56, 189, 248, 180), outline=(255, 255, 255, 220), width=2)
    for ox in [-120, -60, 60, 120]:
        dch.line([(400, 240), (400+ox*2, 130)], fill=(251, 191, 36, 180), width=2)
    dch.polygon([(375, 200), (425, 200), (410, 320), (390, 320)], fill=(30, 58, 138, 255), outline=(56, 189, 248, 255), width=2)
    dch.polygon([(385, 140), (415, 140), (425, 190), (375, 190)], fill=(56, 189, 248, 255))
    dch.polygon([(400, 120), (410, 145), (390, 145)], fill=(251, 191, 36, 255))
    dch.rectangle([0, 430, 800, 500], fill=(7, 10, 20, 230))
    dch.text((400, 455), 'CHALICRFAX', fill=(56, 189, 248, 255), anchor='mm', font_size=26)
    dch.text((400, 480), 'Kurion Lendario Voador/Arcano - Protetor dos Ceus', fill=(203, 213, 225, 255), anchor='mm', font_size=16)
    chali.save('images/kurions/chalicrfax.png', 'PNG')

    # 6. PERSONAGENS (480x600)
    def make_char(path, name, role, color_theme, badge):
        img = Image.new('RGBA', (480, 600), color=(13, 19, 36, 255))
        d_c = ImageDraw.Draw(img)
        d_c.rounded_rectangle([15, 15, 465, 585], radius=20, fill=(18, 26, 48, 255), outline=color_theme, width=3)
        # Silhueta de personagem
        d_c.ellipse([190, 90, 290, 190], fill=color_theme)
        d_c.polygon([(140, 200), (340, 200), (390, 390), (90, 390)], fill=(color_theme[0], color_theme[1], color_theme[2], 180), outline=(255, 255, 255, 200))
        # Rótulo inferior
        d_c.rectangle([15, 440, 465, 585], fill=(10, 15, 28, 240))
        d_c.text((240, 470), badge, fill=(251, 191, 36, 255), anchor='mm', font_size=16)
        d_c.text((240, 510), name, fill=(255, 255, 255, 255), anchor='mm', font_size=30)
        d_c.text((240, 550), role, fill=(148, 163, 184, 255), anchor='mm', font_size=18)
        img.save(path, 'PNG')

    make_char('images/characters/koli.png', 'Koli', 'Protagonista da Saga Origens', (56, 189, 248, 255), 'PORTADORA DO COLAR')
    make_char('images/characters/pagonix.png', 'Pagonix', 'Kurion Leal Cristal/Terrestre', (34, 197, 94, 255), 'PARCEIRO INSEPARAVEL')
    make_char('images/characters/chalicrfax.png', 'Chalicrfax', 'Guardiao Alado dos Ceus', (147, 51, 234, 255), 'KURION LENDARIO')
    make_char('images/characters/dark_team.png', 'Dark Team', 'Sombras de Aether', (239, 68, 68, 255), 'ANTAGONISTAS')
    make_char('images/characters/grandma.png', 'Avo de Koli', 'Guardia dos Segredos Ancestrais', (245, 158, 11, 255), 'SABIA DA VILA')

    print('[OK] Todas as ilustracoes em alta fidelidade foram geradas com sucesso!')

if __name__ == '__main__':
    generate_all()
