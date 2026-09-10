#!/usr/bin/env python3
"""Gera o icone Android (adaptive icon) e o boot splash a partir do concept art aprovado.

Determinismo: mesma filosofia do generate_audio_assets.py - zero downloads,
zero dependencia de rede, 100% reproduzivel a partir dos assets ja versionados.

Fonte do elemento central: assets/concept_art/survivor_v2.png (cena completa,
sem alpha). Como a arte e uma cena pintada (aleia + zumbis ao fundo), nao ha
corte de silhueta limpo disponivel via threshold simples - a abordagem usada
aqui e um crop de busto (rosto + tronco + arma) com uma mascara circular
suavizada (feather radial), que funciona como um "medalhao" e fica correto
sob qualquer mascara de launcher Android (circulo, squircle, teardrop etc.),
em vez de tentar simular um recorte alfa preciso que a arte de origem nao
permite gerar de forma confiavel sem segmentacao manual/ML.
"""
import os
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC_CONCEPT = os.path.join(ROOT, "assets", "concept_art", "survivor_v2.png")
OUT_DIR = os.path.join(ROOT, "assets", "icons", "android")

CANVAS = 432
MAIN_SIZE = 192
BOOT_SIZE = 600

# Safe-zone do Adaptive Icon Android: circulo de 66dp de diametro central
# num canvas de 108dp -> em px (canvas 432px = 108dp, 4px/dp): raio = 132px.
SAFE_RADIUS = 132
# Nucleo totalmente opaco dentro da safe zone (com margem de seguranca) e
# feather ate um raio que ainda cabe no canvas, garantindo que nao sobra
# nenhuma borda dura visivel em nenhuma mascara.
FEATHER_INNER = 120
FEATHER_OUTER = 200

BUST_CROP_BOX = (350, 130, 700, 560)  # rosto + tronco + arma, ver crop_bust.png
BUST_DISPLAY_HEIGHT = 300

BG_CENTER_COLOR = np.array([54, 58, 52], dtype=np.float32)
BG_EDGE_COLOR = np.array([10, 11, 10], dtype=np.float32)
STRIPE_COLOR = np.array([120, 90, 20], dtype=np.float32)


def make_background(size: int) -> Image.Image:
    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32)
    cx = cy = size / 2.0
    dist = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2)
    max_dist = np.sqrt(2) * (size / 2.0)
    t = np.clip(dist / max_dist, 0.0, 1.0)[..., None]
    base = BG_CENTER_COLOR * (1 - t) + BG_EDGE_COLOR * t

    # Vinheta extra nos cantos, mais escura que o gradiente radial puro.
    vignette = np.clip((dist / max_dist) ** 2, 0.0, 1.0)[..., None]
    base = base * (1.0 - 0.35 * vignette)

    # Faixas de advertencia (estilo fita de risco) bem sutis, na diagonal,
    # visiveis so perto da base do canvas.
    period = size / 9.0
    diag_pos = np.mod(xs - ys, period)
    stripe_mask = (diag_pos < period * 0.4).astype(np.float32)
    lower_half = np.clip((ys / size - 0.55) * 3.0, 0.0, 1.0)
    stripe_alpha = (stripe_mask * lower_half * 0.10)[..., None]
    base = base * (1 - stripe_alpha) + STRIPE_COLOR * stripe_alpha

    arr = np.clip(base, 0, 255).astype(np.uint8)
    return Image.fromarray(arr, mode="RGB").convert("RGBA")


def make_foreground(size: int) -> Image.Image:
    concept = Image.open(SRC_CONCEPT).convert("RGB")
    bust = concept.crop(BUST_CROP_BOX)
    scale = BUST_DISPLAY_HEIGHT / bust.height
    bust = bust.resize((max(1, round(bust.width * scale)), BUST_DISPLAY_HEIGHT), Image.LANCZOS)

    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = (size - bust.width) // 2
    py = (size - bust.height) // 2 - 10  # leve deslocamento pra cima (peito/rosto no centro visual)
    canvas.paste(bust, (px, py))

    ys, xs = np.mgrid[0:size, 0:size].astype(np.float32)
    cx = cy = size / 2.0
    dist = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2)
    ramp = np.clip((FEATHER_OUTER - dist) / (FEATHER_OUTER - FEATHER_INNER), 0.0, 1.0)

    arr = np.array(canvas)
    existing_alpha = arr[..., 3].astype(np.float32)
    final_alpha = np.minimum(existing_alpha, ramp * 255.0).astype(np.uint8)
    arr[..., 3] = final_alpha
    return Image.fromarray(arr, mode="RGBA")


def composite(bg: Image.Image, fg: Image.Image) -> Image.Image:
    out = bg.convert("RGBA").copy()
    out.alpha_composite(fg)
    return out


def main():
    os.makedirs(OUT_DIR, exist_ok=True)

    bg = make_background(CANVAS)
    fg = make_foreground(CANVAS)
    bg_path = os.path.join(OUT_DIR, "adaptive_background_432x432.png")
    fg_path = os.path.join(OUT_DIR, "adaptive_foreground_432x432.png")
    bg.convert("RGB").save(bg_path)
    fg.save(fg_path)
    print(f"Generated {bg_path}")
    print(f"Generated {fg_path}")

    flattened = composite(bg, fg)
    main_icon = flattened.convert("RGB").resize((MAIN_SIZE, MAIN_SIZE), Image.LANCZOS)
    main_path = os.path.join(OUT_DIR, "main_192x192.png")
    main_icon.save(main_path)
    print(f"Generated {main_path}")

    boot = flattened.convert("RGB").resize((BOOT_SIZE, BOOT_SIZE), Image.LANCZOS)
    boot_path = os.path.join(OUT_DIR, "boot_splash.png")
    boot.save(boot_path)
    print(f"Generated {boot_path}")


if __name__ == "__main__":
    main()
