from PIL import Image, ImageDraw
import os

# ----------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------

# Brand colors (matching SwiftUI version)
TEAL = (64, 184, 176)       # #40B8B0
OFF_WHITE = (245, 245, 247) # #F5F5F7

# App icon sizes required by Apple
ICON_SIZES = [
    20, 29, 40, 60, 76, 83.5, 1024
]

OUTPUT_DIR = "SkinrIcons"

# ----------------------------------------------------------
# HELPER: draw Skinr logo
# ----------------------------------------------------------

def draw_skinr_logo(size):
    """
    Draw the Skinr logo (circle + dot) into a square PNG image.
    """
    img = Image.new("RGB", (size, size), OFF_WHITE)
    draw = ImageDraw.Draw(img)

    # Circle stroke thickness proportional to size
    stroke = int(size * 0.07)

    # Outer ring
    inset = stroke // 2
    draw.ellipse(
        (inset, inset, size - inset, size - inset),
        outline=TEAL,
        width=stroke
    )

    # Face dot
    dot_size = int(size * 0.22)
    dot_y_offset = int(size * 0.18)  # dot sits lower in the circle

    dot_x = (size - dot_size) // 2
    dot_y = (size - dot_size) // 2 + dot_y_offset

    draw.ellipse(
        (dot_x, dot_y, dot_x + dot_size, dot_y + dot_size),
        fill=TEAL
    )

    return img

# ----------------------------------------------------------
# MAIN GENERATOR
# ----------------------------------------------------------

def generate_icons():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    pixel_sizes = set()

    # Multiply points to pixels (@2x and @3x)
    for size in ICON_SIZES:
        pixel_sizes.add(int(size * 2))
        pixel_sizes.add(int(round(size * 3)))

    # Always include 1024
    pixel_sizes.add(1024)

    for px in sorted(pixel_sizes):
        img = draw_skinr_logo(px)
        filename = f"AppIcon-{px}x{px}.png"
        filepath = os.path.join(OUTPUT_DIR, filename)
        img.save(filepath, "PNG")
        print("Generated:", filepath)

    print("\nAll icons saved to:", os.path.abspath(OUTPUT_DIR))


# ----------------------------------------------------------
# RUN
# ----------------------------------------------------------

if __name__ == "__main__":
    generate_icons()

