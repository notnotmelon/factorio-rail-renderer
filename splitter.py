from PIL import Image
import pathlib
import os

script_location = pathlib.Path(__file__).parent

output_path = 'C:/Users/zacha/Documents/factorio/mods/pystellarexpeditiongraphics/graphics/entity/space-rail/'

hr_mask_path = script_location / 'hr-inner-mask.png'
mask_path = script_location / 'inner-mask.png'

hr_endcap_mask_path = script_location / 'hr-endcap-mask.png'
endcap_mask_path = script_location / 'endcap-mask.png'

hr_vertical_curve_mask_path = script_location / 'hr-vertical-curve-mask.png'
vertical_curve_mask_path = script_location / 'vertical-curve-mask.png'

hr_horizontal_curve_mask_path = script_location / 'hr-horizontal-curve-mask.png'
horizontal_curve_mask_path = script_location / 'horizontal-curve-mask.png'

def subtract(original, subtractant, subtractant_position):
    subtractant_alpha = subtractant.copy()
    subtractant_alpha.putalpha(0)
    original.paste(subtractant_alpha, subtractant_position, mask=subtractant)

def mask_subtract(original, subtractant):
    white_square = Image.new('RGBA', subtractant.size, (255, 255, 255, 255))
    subtract(white_square, subtractant, (0, 0))
    white_square_alpha = subtractant.copy()
    white_square_alpha.putalpha(0)
    original.paste(white_square_alpha, (0, 0), mask=white_square)

def split_layer(prefix, img, factor, mask, endcap_mask, vertical_curve_mask, horizontal_curve_mask):
    width, height = img.size
    quadrant_width = width // 2
    quadrant_height = height // 2

    # straight rail horizontal
    y_offset = quadrant_height - 64*6 // factor
    straight_rail_horizontal = img.crop((-128//2 // factor + quadrant_width, y_offset, 128//2 // factor + quadrant_width, y_offset + 256 // factor))
    straight_rail_horizontal.save(output_path + prefix + 'straight-rail-horizontal.png')

    # straight rail vertical
    y_offset = quadrant_height + 128*2 // factor
    straight_rail_vertical = img.crop((-256//2 // factor + quadrant_width, y_offset - 64 // factor, 256//2 // factor + quadrant_width, y_offset + 64 // factor))
    straight_rail_vertical.save(output_path + prefix + 'straight-rail-vertical.png')

    # Top left quadrant
    top_left = img.crop((0, 0, quadrant_width, quadrant_height))

    # Top right quadrant
    top_right = img.crop((quadrant_width, 0, width, quadrant_height))

    # Bottom left quadrant
    bottom_left = img.crop((0, quadrant_height, quadrant_width, height))

    # Bottom right quadrant
    bottom_right = img.crop((quadrant_width, quadrant_height, width, height))

    # Center of each quadrant
    center_size = 96 // factor
    center_offset = -16 // factor
    center_width = quadrant_width // 2
    center_height = quadrant_height // 2
    top_left_center_position = (center_width - center_size - center_offset, center_height - center_size - center_offset, center_width + center_size - center_offset, center_height + center_size - center_offset)
    top_right_center_position = (center_width - center_size + center_offset, center_height - center_size - center_offset, center_width + center_size + center_offset, center_height + center_size - center_offset)
    bottom_left_center_position = (center_width - center_size - center_offset, center_height - center_size + center_offset, center_width + center_size - center_offset, center_height + center_size + center_offset)
    bottom_right_center_position = (center_width - center_size + center_offset, center_height - center_size + center_offset, center_width + center_size + center_offset, center_height + center_size + center_offset)

    # Cut out the center 192x192 area of each quadrant
    top_left_center = top_left.crop(top_left_center_position)
    top_right_center = top_right.crop(top_right_center_position)
    bottom_left_center = bottom_left.crop(bottom_left_center_position)
    bottom_right_center = bottom_right.crop(bottom_right_center_position)

    # Create masks for each quadrant center cutout
    top_left_mask = mask.copy().rotate(90)
    top_right_mask = mask.copy().rotate(180)
    bottom_left_mask = mask.copy()
    bottom_right_mask = mask.copy().rotate(270)

    # Subtract our masks from the center pieces
    mask_subtract(top_left_center, top_left_mask)
    mask_subtract(top_right_center, top_right_mask)
    mask_subtract(bottom_left_center, bottom_left_mask)
    mask_subtract(bottom_right_center, bottom_right_mask)

    # Use each center piece as a mask to crop the center of each quadrant
    subtract(top_left, top_left_center, top_left_center_position)
    subtract(top_right, top_right_center, top_right_center_position)
    subtract(bottom_left, bottom_left_center, bottom_left_center_position)
    subtract(bottom_right, bottom_right_center, bottom_right_center_position)

    # Calculate the size of the remainder crops
    vertical_remainder_width = 384 // factor
    vertical_remainder_height = 576 // factor
    horizontal_remainder_width = vertical_remainder_height
    horizontal_remainder_height = vertical_remainder_width

    top_left_remainder_horizontal = top_left.crop((quadrant_width - horizontal_remainder_width, 0, quadrant_width, horizontal_remainder_height))
    mask_subtract(top_left_remainder_horizontal, horizontal_curve_mask)
    top_left_remainder_horizontal.save(output_path + prefix + 'curved-rail-bottom-right-horizontal.png')

    top_left_remainder_vertical = top_left.crop((0, quadrant_height - vertical_remainder_height, vertical_remainder_width, quadrant_height))
    mask_subtract(top_left_remainder_vertical, vertical_curve_mask)
    top_left_remainder_vertical.save(output_path + prefix + 'curved-rail-bottom-right-vertical.png')

    top_right_remainder_horizontal = top_right.crop((0, 0, horizontal_remainder_width, horizontal_remainder_height))
    mask_subtract(top_right_remainder_horizontal, horizontal_curve_mask)
    top_right_remainder_horizontal.save(output_path + prefix + 'curved-rail-bottom-left-horizontal.png')

    top_right_remainder_vertical = top_right.crop((quadrant_width - vertical_remainder_width, quadrant_height - vertical_remainder_height, quadrant_width, quadrant_height))
    mask_subtract(top_right_remainder_vertical, vertical_curve_mask)
    top_right_remainder_vertical.save(output_path + prefix + 'curved-rail-bottom-left-vertical.png')

    bottom_left_remainder_horizontal = bottom_left.crop((quadrant_width - horizontal_remainder_width, quadrant_height - horizontal_remainder_height, quadrant_width, quadrant_height))
    mask_subtract(bottom_left_remainder_horizontal, horizontal_curve_mask)
    bottom_left_remainder_horizontal.save(output_path + prefix + 'curved-rail-top-right-horizontal.png')

    bottom_left_remainder_vertical = bottom_left.crop((0, 0, vertical_remainder_width, vertical_remainder_height))
    mask_subtract(bottom_left_remainder_vertical, vertical_curve_mask)
    bottom_left_remainder_vertical.save(output_path + prefix + 'curved-rail-top-right-vertical.png')

    bottom_right_remainder_horizontal = bottom_right.crop((0, quadrant_height - horizontal_remainder_height, horizontal_remainder_width, quadrant_height))
    mask_subtract(bottom_right_remainder_horizontal, horizontal_curve_mask)
    bottom_right_remainder_horizontal.save(output_path + prefix + 'curved-rail-top-left-horizontal.png')

    bottom_right_remainder_vertical = bottom_right.crop((quadrant_width - vertical_remainder_width, 0, quadrant_width, vertical_remainder_height))
    mask_subtract(bottom_right_remainder_vertical, vertical_curve_mask)
    bottom_right_remainder_vertical.save(output_path + prefix + 'curved-rail-top-left-vertical.png')

    # Create endcaps
    endcap_offset = [0]
    endcaps = Image.new('RGBA', (2048 // factor, 256 // factor), (0, 0, 0, 0))

    def add_endcap(x, y, shift_vector=(0, 0)):
        shift_vector = (shift_vector[0] // factor, shift_vector[1] // factor)

        endcap = Image.new('RGBA', (2048 // factor, 256 // factor), (0, 0, 0, 0))
        endcap.paste(img.crop((x // factor, y // factor, (x + 256) // factor, (y + 256) // factor)), (endcap_offset[0], 0))
        mask_subtract(endcap, endcap_mask)
        endcap = endcap.crop((endcap_offset[0], 0, endcap_offset[0] + 256 // factor, 256 // factor))
        
        endcaps.paste(endcap, (endcap_offset[0] + shift_vector[0], shift_vector[1]), endcap)
        endcap_offset[0] += 256 // factor

    def flip_x(x):
        return width * factor - (x + 256)

    diagonal_inset = 8-45.2548339959
    vertical_endcaps_x = 736 # 1, 5
    horizontal_endcaps_y = 480 # 3, 7
    horizontal_endcaps_x = 880-15 # 3, 7
    diagonal_endcaps_outer_y = 667-diagonal_inset+8 # 2, 8
    diagonal_endcaps_outer_x = 549+diagonal_inset-8 # 2, 8
    diagonal_endcaps_inner_y = 808+diagonal_inset # 4, 6
    diagonal_endcaps_inner_x = 1063+diagonal_inset # 4, 6

    add_endcap(vertical_endcaps_x, 861+3, (0, -64))
    add_endcap(diagonal_endcaps_outer_x, diagonal_endcaps_outer_y)
    add_endcap(horizontal_endcaps_x, horizontal_endcaps_y, (64, 0))
    add_endcap(diagonal_endcaps_inner_x, diagonal_endcaps_inner_y)
    add_endcap(vertical_endcaps_x, 1153-32+9, (0, 64))
    add_endcap(flip_x(diagonal_endcaps_inner_x), diagonal_endcaps_inner_y)
    add_endcap(flip_x(horizontal_endcaps_x), horizontal_endcaps_y, (-64, 0))
    add_endcap(flip_x(diagonal_endcaps_outer_x), diagonal_endcaps_outer_y)
    
    endcaps.save(output_path + prefix + 'endcaps.png')

    # diagonals

    def get_diagnol_rail_cutout(x, y):
        width, height = 192 // factor, 192 // factor
        x, y = x // factor, y // factor
        return img.crop((x, y, x + width, y + height))

    def flip_x(x):
        return width * factor - (x + 192)
    
    def add_to_right(original, addend):
        result = Image.new('RGBA', (original.width + addend.width, original.height), (0, 0, 0, 0))
        result.paste(original, (0, 0))
        result.paste(addend, (original.width, 0))
        return result

    # Create alt versions of the diagonals
    top_x = 960
    top_y = 831
    bottom_x = 1094
    bottom_y = 714
    top_left_center_2 = get_diagnol_rail_cutout(flip_x(top_x), top_y)
    top_right_center_2 = get_diagnol_rail_cutout(top_x, top_y)
    bottom_left_center_2 = get_diagnol_rail_cutout(bottom_x, bottom_y)
    bottom_right_center_2 = get_diagnol_rail_cutout(flip_x(bottom_x), bottom_y)
    mask_subtract(top_left_center_2, top_left_mask)
    mask_subtract(top_right_center_2, top_right_mask)
    mask_subtract(bottom_left_center_2, bottom_left_mask)
    mask_subtract(bottom_right_center_2, bottom_right_mask)
    
    # Save the diagonal rails
    add_to_right(top_left_center, top_left_center_2).save(output_path + prefix + 'diagonal-rail-top-left.png')
    add_to_right(top_right_center, top_right_center_2).save(output_path + prefix + 'diagonal-rail-top-right.png')
    add_to_right(bottom_left_center, bottom_left_center_2).save(output_path + prefix + 'diagonal-rail-bottom-left.png')
    add_to_right(bottom_right_center, bottom_right_center_2).save(output_path + prefix + 'diagonal-rail-bottom-right.png')

def main(prefix):
    file_path = script_location / ('hr-space-rail-' + prefix + '.png')
    os.makedirs(output_path + prefix, exist_ok=True)
    with Image.open(file_path) as img:
        split_layer(prefix + '/hr-', img, 1, Image.open(hr_mask_path).convert('RGBA'), Image.open(hr_endcap_mask_path).convert('RGBA'), Image.open(hr_vertical_curve_mask_path).convert('RGBA'), Image.open(hr_horizontal_curve_mask_path).convert('RGBA'))
        split_layer(prefix + '/', img.resize((img.width // 2, img.height // 2)), 2, Image.open(mask_path).convert('RGBA'), Image.open(endcap_mask_path).convert('RGBA'), Image.open(vertical_curve_mask_path).convert('RGBA'), Image.open(horizontal_curve_mask_path).convert('RGBA'))

main('backplates')
main('shadow')
main('ties')
main('stone-path')