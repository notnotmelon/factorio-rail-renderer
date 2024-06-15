local only_hr = true -- if this flag is enabled, the low res rails will be discarded

ITEM('rail'):copy('space-rail'):set_fields {
    subgroup = 'pystellarexpedition-items',
    order = 'y-d',
    curved_rail = 'curved-space-rail',
    straight_rail = 'space-rail',
    localised_name = {'entity-name.space-rail'},
    localised_description = {'entity-description.space-rail'},
    place_result = 'space-rail',
}.icon_mipmaps = nil

RECIPE {
    name = 'space-rail',
    ingredients = {
        {'steel-plate', 1},
        {'stone-brick', 1}
    },
    result = 'space-rail',
    enabled = false,
    energy_required = 0.5,
    category = 'crafting',
}:add_unlock('railway-mk02')

local curved = ENTITY('curved-rail'):copy('curved-space-rail')
local straight = ENTITY('straight-rail'):copy('space-rail')

local pictures = curved.pictures

for _, rail in pairs{curved, straight} do
    rail.minable = {mining_time = 0.1, result = 'space-rail'}
    rail.localised_name = {'entity-name.space-rail'}
    rail.localised_description = {'entity-description.space-rail'}
    rail.subgroup = 'pystellarexpedition-items'
    rail.order = 'y-d'
    rail.placeable_by = {item = 'space-rail', count = 1}
    rail.pictures = pictures
    rail.collision_mask = {'rail-layer', 'item-layer', 'object-layer'}
end

for k, v in pairs(pictures) do
    if k ~= 'rail_endings' then
        v.metals = py.empty_image()
        v.ties = py.empty_image()
    end
end

local sheet_template = pictures.rail_endings.sheets[1]
pictures.rail_endings.sheets = {}

local function add_pictures(picture_folder, picture_name)
    -- diagonal rail

    pictures.straight_rail_diagonal_left_top[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/diagonal-rail-top-left.png'
    pictures.straight_rail_diagonal_left_top[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-diagonal-rail-top-left.png'

    pictures.straight_rail_diagonal_right_top[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/diagonal-rail-top-right.png'
    pictures.straight_rail_diagonal_right_top[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-diagonal-rail-top-right.png'

    pictures.straight_rail_diagonal_right_bottom[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/diagonal-rail-bottom-right.png'
    pictures.straight_rail_diagonal_right_bottom[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-diagonal-rail-bottom-right.png'

    pictures.straight_rail_diagonal_left_bottom[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/diagonal-rail-bottom-left.png'
    pictures.straight_rail_diagonal_left_bottom[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-diagonal-rail-bottom-left.png'

    -- curved vertical rail

    pictures.curved_rail_vertical_left_top[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-top-left-vertical.png'
    pictures.curved_rail_vertical_left_top[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-top-left-vertical.png'

    pictures.curved_rail_vertical_right_top[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-top-right-vertical.png'
    pictures.curved_rail_vertical_right_top[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-top-right-vertical.png'

    pictures.curved_rail_vertical_right_bottom[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-bottom-right-vertical.png'
    pictures.curved_rail_vertical_right_bottom[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-bottom-right-vertical.png'

    pictures.curved_rail_vertical_left_bottom[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-bottom-left-vertical.png'
    pictures.curved_rail_vertical_left_bottom[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-bottom-left-vertical.png'

    -- curved horizontal rail

    pictures.curved_rail_horizontal_left_top[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-top-left-horizontal.png'
    pictures.curved_rail_horizontal_left_top[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-top-left-horizontal.png'

    pictures.curved_rail_horizontal_right_top[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-top-right-horizontal.png'
    pictures.curved_rail_horizontal_right_top[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-top-right-horizontal.png'

    pictures.curved_rail_horizontal_right_bottom[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-bottom-right-horizontal.png'
    pictures.curved_rail_horizontal_right_bottom[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-bottom-right-horizontal.png'

    pictures.curved_rail_horizontal_left_bottom[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/curved-rail-bottom-left-horizontal.png'
    pictures.curved_rail_horizontal_left_bottom[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-curved-rail-bottom-left-horizontal.png'

    -- straight rail

    pictures.straight_rail_horizontal[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/straight-rail-horizontal.png'
    pictures.straight_rail_horizontal[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-straight-rail-horizontal.png'

    pictures.straight_rail_vertical[picture_name].filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/straight-rail-vertical.png'
    pictures.straight_rail_vertical[picture_name].hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-straight-rail-vertical.png'

    -- endcaps

    local sheet = table.deepcopy(sheet_template)
    sheet.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/endcaps.png'
    --sheet.draw_as_shadow = draw_as_shadow       rails are always drawn below the shadow layer so this breaks rail intersections.
    sheet.hr_version.filename = '__pystellarexpeditiongraphics__/graphics/entity/space-rail/' .. picture_folder .. '/hr-endcaps.png'
    --sheet.hr_version.draw_as_shadow = draw_as_shadow
    table.insert(pictures.rail_endings.sheets, sheet)
    

    for _, picture_type in pairs {
        'straight_rail_diagonal_left_top',
        'straight_rail_diagonal_right_top',
        'straight_rail_diagonal_right_bottom',
        'straight_rail_diagonal_left_bottom',
        'curved_rail_vertical_left_top',
        'curved_rail_vertical_right_top',
        'curved_rail_vertical_right_bottom',
        'curved_rail_vertical_left_bottom',
        'curved_rail_horizontal_left_top',
        'curved_rail_horizontal_right_top',
        'curved_rail_horizontal_right_bottom',
        'curved_rail_horizontal_left_bottom',
        'straight_rail_horizontal',
        'straight_rail_vertical',
    } do
        pictures[picture_type][picture_name].variation_count = 1
        pictures[picture_type][picture_name].hr_version.variation_count = 1
    end
end

add_pictures('shadow', 'stone_path_background')
add_pictures('stone-path', 'stone_path')
add_pictures('backplates', 'backplates')

if only_hr then
    for k, v in pairs(pictures) do
        for kk, pic in pairs(v) do
            if pic.hr_version then v[kk] = pic.hr_version end
        end
    end
    for k, v in pairs(pictures.rail_endings.sheets) do
        pictures.rail_endings.sheets[k] = v.hr_version
    end
end