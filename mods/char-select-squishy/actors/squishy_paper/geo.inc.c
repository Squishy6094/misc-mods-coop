#include "src/game/envfx_snow.h"

const GeoLayout squishy_paper_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, squishy_paper_Plane_mesh_layer_5),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT, squishy_paper_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
