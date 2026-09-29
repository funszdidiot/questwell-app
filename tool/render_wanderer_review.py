"""Render review composites from the exact runtime layers (Pillow required)."""
import json
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
spec = json.loads((ROOT / 'tool/wanderer_wrap_fit.json').read_text())
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 18)
board = Image.new('RGB', (1440, 580), (35, 45, 59))
draw = ImageDraw.Draw(board)
lineup = Image.new('RGB', (960, 680), (35, 45, 59))
lineup_draw = ImageDraw.Draw(lineup)
for row, (kind, garment) in enumerate(spec['classes'].items()):
    visibility = json.loads((ROOT / f'tool/{kind}_underlayer_visibility.json').read_text())['bodies']
    for col, (body, fit) in enumerate(garment['bodies'].items()):
        base = Image.open(ROOT / f'assets/images/questwell/avatar/base/base_{body}.webp').convert('RGBA')
        front = Image.open(ROOT / fit['front']).convert('RGBA')
        rear = Image.open(ROOT / fit['output']).convert('RGBA')
        mask = Image.new('L', (960, 1280))
        painter = ImageDraw.Draw(mask)
        for polygon in visibility[body]:
            painter.polygon([(round(x*4), round(y*4)) for x, y in polygon], fill=255)
        base.putalpha(ImageChops.multiply(base.getchannel('A'), mask.resize((240, 320), Image.Resampling.LANCZOS)))
        previous = Image.alpha_composite(base, front)
        revised = Image.alpha_composite(Image.alpha_composite(rear, base), front)
        title = {'male': 'Male', 'female': 'Female', 'neutral': 'Gender Neutral'}[body]
        lineup_draw.text((col*320+20, 12), title, font=font, fill='white')
        portrait = revised.resize((312, 416), Image.Resampling.LANCZOS)
        lineup.paste(portrait, (col*320+4, 38), portrait)
        card = revised.resize((132, 176), Image.Resampling.LANCZOS)
        lineup.paste(card, (col*320+94, 480), card)
        x, y = col * 480, row * 580
        draw.text((x+15, y+6), f'{kind.title()} / {body}', font=font, fill='white')
        board.paste(previous, (x, y+36), previous)
        board.paste(revised, (x+240, y+36), revised)
        draw.text((x+70, y+360), 'Before', font=font, fill='#b7becb')
        draw.text((x+300, y+360), 'With rear', font=font, fill='#e6c988')
        thumb = revised.resize((132, 176), Image.Resampling.LANCZOS)
        board.paste(thumb, (x+294, y+390), thumb)
        if kind == 'wanderer' and body == 'female':
            close = Image.new('RGB', (960, 680), (35, 45, 59))
            pen = ImageDraw.Draw(close)
            for i, (label, art) in enumerate([('Before', previous), ('With rear lining', revised)]):
                large = art.resize((480, 640), Image.Resampling.NEAREST)
                close.paste(large, (i*480, 35), large)
                pen.text((i*480+20, 8), label, font=font, fill='white')
            close.save(ROOT / 'docs/qa/wanderer-female-wrap-v1.png')
board.save(ROOT / 'docs/qa/wanderer-fit-v1.png')
lineup.save(ROOT / 'docs/qa/wanderer-lineup-v1.png')
