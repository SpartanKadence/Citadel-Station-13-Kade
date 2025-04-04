/turf/unsimulated/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'

/turf/unsimulated/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/unsimulated/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/unsimulated/beach/water
	name = "Water"
	icon_state = "water"

/turf/unsimulated/beach/water/Initialize(mapload)
	. = ..()
	add_overlay(/obj/effect/turf_overlay/beach_water, TRUE)

/obj/effect/turf_overlay/beach_water
	icon = 'icons/misc/beach.dmi'
	icon_state = "water2"
	layer = ABOVE_MOB_LAYER

/turf/simulated/floor/outdoors/beach
	name = "beach"
	icon = 'icons/misc/beach.dmi'
	initial_flooring = /datum/prototype/flooring/outdoors/beach
	edge_blending_priority = 1
	smoothing_flags = NONE

/turf/simulated/floor/outdoors/beach/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/shovel))
		var/grave_type = /obj/structure/closet/grave/sand
		if(do_after(user, 60))
			to_chat(user, "<span class='warning'>You dig out a hole.</span>")
			new grave_type(get_turf(src))
			return

/turf/simulated/floor/outdoors/beach/sand
	name = "sand"
	icon_state = "sand"

/turf/simulated/floor/outdoors/beach/sand/desert
	name = "Dunes"
	desc = "It seems to go on and on.."
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "desert"
	initial_flooring = /datum/prototype/flooring/outdoors/beach/sand/desert

/turf/simulated/floor/outdoors/beach/sand/desert/Initialize(mapload)
	. = ..()
	if(prob(5))
		icon_state = "desert[rand(0,4)]"

/turf/simulated/floor/outdoors/beach/sand/desert/indoors
	initial_gas_mix = ATMOSPHERE_USE_INDOORS
	outdoors = FALSE

/turf/simulated/floor/outdoors/beach/sand/lowdesert
	name = "\improper low desert"
	icon = 'icons/turf/outdoors.dmi'
	icon_state = "lowdesert"

/turf/simulated/floor/outdoors/beach/outdoors/sand/lowdesert/Initialize(mapload)
	. = ..()
	if(prob(5))
		icon_state = "lowdesert[rand(0,4)]"

/turf/simulated/floor/beach/sand/dirt
	name = "worn out path"
	desc = "A compacted bit of sand with footprints all over it..."
	icon_state = "dirt-dark"
	icon = 'icons/turf/outdoors.dmi'

/turf/simulated/floor/outdoors/beach/sand/dirtlight
	name = "sun bleached path"
	desc = "A cracked path of compacted sand, worn by heavy traffic and bleached by constant sunlight."
	icon_state = "dirt-light"
	icon = 'icons/turf/outdoors.dmi'

/turf/simulated/floor/outdoors/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/simulated/floor/outdoors/beach/water
	name = "Water"
	icon_state = "water"
	initial_flooring = /datum/prototype/flooring/water

/turf/simulated/floor/outdoors/beach/water/ocean
	icon_state = "seadeep"

/turf/simulated/floor/outdoors/beach/water/Initialize(mapload)
	. = ..()
	add_overlay(/obj/effect/turf_overlay/beach_ocean, TRUE)

/obj/effect/turf_overlay/beach_ocean
	icon = 'icons/misc/beach.dmi'
	icon_state = "water5"
	layer = ABOVE_MOB_LAYER
