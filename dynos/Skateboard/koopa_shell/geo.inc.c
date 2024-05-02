#include "src/game/envfx_snow.h"

const GeoLayout koopa_shell_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, koopa_shell_skateboard_mesh_layer_1),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_bobomb_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_coop_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_goomba_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_mario_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_mips_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_power_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_star_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_tbhcreature_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_TRANSPARENT, 0, 25, 0, 0, -90, 0, koopa_shell_uoker_mesh_layer_5),
		GEO_TRANSLATE_ROTATE_WITH_DL(LAYER_OPAQUE, 0, 25, 0, 0, -90, 0, koopa_shell_wheels_mesh_layer_1),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, koopa_shell_material_revert_render_settings),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, koopa_shell_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
