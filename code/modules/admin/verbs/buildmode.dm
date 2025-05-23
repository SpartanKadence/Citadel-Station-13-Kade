/proc/togglebuildmode(mob/M as mob in GLOB.player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"
	if(M.client)
		if(M.client.buildmode)
			log_admin("[key_name(usr)] has left build mode.")
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			for(var/obj/effect/bmode/buildholder/H in GLOB.buildholders)
				if(H.cl == M.client)
					qdel(H)
		else
			log_admin("[key_name(usr)] has entered build mode.")
			M.client.buildmode = 1
			M.client.show_popup_menus = 0

			var/obj/effect/bmode/buildholder/H = new/obj/effect/bmode/buildholder()
			var/obj/effect/bmode/builddir/A = new/obj/effect/bmode/builddir(H)
			A.master = H
			var/obj/effect/bmode/buildhelp/B = new/obj/effect/bmode/buildhelp(H)
			B.master = H
			var/obj/effect/bmode/buildmode/C = new/obj/effect/bmode/buildmode(H)
			C.master = H
			var/obj/effect/bmode/buildquit/D = new/obj/effect/bmode/buildquit(H)
			D.master = H

			H.builddir = A
			H.buildhelp = B
			H.buildmode = C
			H.buildquit = D
			M.client.screen += A
			M.client.screen += B
			M.client.screen += C
			M.client.screen += D
			H.cl = M.client

/obj/effect/bmode//Cleaning up the tree a bit
	density = 1
	anchored = 1
	layer = HUD_LAYER_BASE
	plane = HUD_PLANE
	dir = NORTH
	icon = 'icons/misc/buildmode.dmi'
	var/obj/effect/bmode/buildholder/master = null

/obj/effect/bmode/Destroy()
	if(master && master.cl)
		master.cl.screen -= src
	master = null
	return ..()

/obj/effect/bmode/builddir
	icon_state = "build"
	screen_loc = "TOP,LEFT"


/obj/effect/bmode/builddir/Click()
	switch(dir)
		if(NORTH)
			setDir(EAST)
		if(EAST)
			setDir(SOUTH)
		if(SOUTH)
			setDir(WEST)
		if(WEST)
			setDir(NORTHWEST)
		if(NORTHWEST)
			setDir(NORTH)
	return 1

/obj/effect/bmode/buildhelp
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "TOP,LEFT+1"

/obj/effect/bmode/buildhelp/Click()
	switch(master.cl.buildmode)
		if(1) // Basic Build
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button        = Construct / Upgrade</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button       = Deconstruct / Delete / Downgrade</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button + ctrl = R-Window</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button + alt  = Airlock</span>")
			to_chat(usr, "")
			to_chat(usr, "<span class='notice'>Use the button in the upper left corner to</span>")
			to_chat(usr, "<span class='notice'>change the direction of built objects.</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(2) // Adv. Build
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on buildmode button = Set object type</span>")
			to_chat(usr, "<span class='notice'>Middle Mouse Button on buildmode button= On/Off object type saying</span>")
			to_chat(usr, "<span class='notice'>Middle Mouse Button on turf/obj        = Capture object type</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj          = Place objects</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button                     = Delete objects</span>")
			to_chat(usr, "<span class='notice'>Mouse Button + ctrl                    = Copy object type</span>")
			to_chat(usr, "")
			to_chat(usr, "<span class='notice'>Use the button in the upper left corner to</span>")
			to_chat(usr, "<span class='notice'>change the direction of built objects.</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(3) // Edit
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on buildmode button = Select var(type) & value</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Set var(type) & value</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Reset var's value</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(4) // Throw
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Throw</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(5) // Room Build
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf              = Select as point A</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf             = Select as point B</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on buildmode button = Change floor/wall type</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(6) // Make Ladders
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf              = Set as upper ladder loc</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf             = Set as lower ladder loc</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(7) // Move Into Contents
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Select</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Move into selection</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(8) // Make Lights
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on turf/obj/mob      = Make it glow</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on turf/obj/mob     = Reset glowing</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on buildmode button = Change glow properties</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
		if(9) // Control mobs with ai_holders.
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button on AI mob            = Select/Deselect mob</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button + alt on AI mob      = Toggle hostility on mob</span>")
			to_chat(usr, "<span class='notice'>Left Mouse Button + ctrl on AI mob     = Reset target/following/movement</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on enemy mob        = Command selected mobs to attack mob</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on allied mob       = Command selected mobs to follow mob</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button + shift on any mob  = Command selected mobs to follow mob regardless of faction</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button on tile             = Command selected mobs to move to tile (will cancel if enemies are seen)</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button + shift on tile     = Command selected mobs to reposition to tile (will not be inturrupted by enemies)</span>")
			to_chat(usr, "<span class='notice'>Right Mouse Button + alt on obj/turfs  = Command selected mobs to attack obj/turf</span>")
			to_chat(usr, "<span class='notice'>***********************************************************</span>")
	return 1

/obj/effect/bmode/buildquit
	icon_state = "buildquit"
	screen_loc = "TOP,LEFT+3"

/obj/effect/bmode/buildquit/Click()
	togglebuildmode(master.cl.mob)
	return 1

GLOBAL_LIST_EMPTY(buildholders)

/obj/effect/bmode/buildholder
	density = 0
	anchored = 1
	var/client/cl = null
	var/obj/effect/bmode/builddir/builddir = null
	var/obj/effect/bmode/buildhelp/buildhelp = null
	var/obj/effect/bmode/buildmode/buildmode = null
	var/obj/effect/bmode/buildquit/buildquit = null
	var/atom/movable/throw_atom = null
	var/list/selected_mobs = list()

/obj/effect/bmode/buildholder/New()
	GLOB.buildholders += src
	return ..()

/obj/effect/bmode/buildholder/Destroy()
	GLOB.buildholders -= src
	qdel(builddir)
	builddir = null
	qdel(buildhelp)
	buildhelp = null
	qdel(buildmode)
	buildmode = null
	qdel(buildquit)
	buildquit = null
	throw_atom = null
	for(var/mob/living/unit in selected_mobs)
		deselect_AI_mob(cl, unit)
	selected_mobs.Cut()
	cl = null
	return ..()

/obj/effect/bmode/buildholder/proc/select_AI_mob(client/C, mob/living/unit)
	selected_mobs += unit
	C.images += unit.selected_image

/obj/effect/bmode/buildholder/proc/deselect_AI_mob(client/C, mob/living/unit)
	selected_mobs -= unit
	C.images -= unit.selected_image

/obj/effect/bmode/buildmode
	icon_state = "buildmode1"
	screen_loc = "TOP,LEFT+2"
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = /obj/structure/closet
	var/objsay = 1

	var/wall_holder = /turf/simulated/wall
	var/floor_holder = /turf/simulated/floor/plating
	var/turf/coordA = null
	var/turf/coordB = null

	var/new_light_color = "#FFFFFF"
	var/new_light_range = 3
	var/new_light_intensity = 3

/obj/effect/bmode/buildmode/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("middle"))
		switch(master.cl.buildmode)
			if(2)
				objsay=!objsay


	if(pa.Find("left"))
		switch(master.cl.buildmode)
			if(1)
				master.cl.buildmode = 2
				src.icon_state = "buildmode2"
			if(2)
				master.cl.buildmode = 3
				src.icon_state = "buildmode3"
			if(3)
				master.cl.buildmode = 4
				src.icon_state = "buildmode4"
			if(4)
				master.cl.buildmode = 5
				src.icon_state = "buildmode5"
			if(5)
				master.cl.buildmode = 6
				src.icon_state = "buildmode6"
			if(6)
				master.cl.buildmode = 7
				src.icon_state = "buildmode7"
			if(7)
				master.cl.buildmode = 8
				src.icon_state = "buildmode8"
			if(8)
				master.cl.buildmode = 9
				src.icon_state = "buildmode9"
			if(9)
				master.cl.buildmode = 1
				src.icon_state = "buildmode1"

	else if(pa.Find("right"))
		switch(master.cl.buildmode)
			if(1) // Basic Build
				return 1
			if(2) // Adv. Build
				objholder = get_path_from_partial_text(/obj/structure/closet)

			if(3) // Edit
				var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

				master.buildmode.varholder = input(usr,"Enter variable name:" ,"Name", "name")
				if((master.buildmode.varholder in locked) && !check_rights(R_DEBUG,0))
					return 1
				var/thetype = input(usr,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
				if(!thetype) return 1
				switch(thetype)
					if("text")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", "value") as text
					if("number")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", 123) as num
					if("mob-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as mob in GLOB.mob_list
					if("obj-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as obj in world
					if("turf-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as turf in world
			if(5) // Room build
				var/choice = alert("Would you like to change the floor or wall holders?","Room Builder", "Floor", "Wall")
				switch(choice)
					if("Floor")
						floor_holder = get_path_from_partial_text(/turf/simulated/floor/plating)
					if("Wall")
						wall_holder = get_path_from_partial_text(/turf/simulated/wall)
			if(8) // Lights
				var/choice = alert("Change the new light range, power, or color?", "Light Maker", "Range", "Power", "Color")
				switch(choice)
					if("Range")
						var/input = input("New light range.","Light Maker",3) as null|num
						if(input)
							new_light_range = input
					if("Power")
						var/input = input("New light power.","Light Maker",3) as null|num
						if(input)
							new_light_intensity = input
					if("Color")
						var/input = input("New light color.","Light Maker",3) as null|color
						if(input)
							new_light_color = input
	return 1

/proc/build_click(var/mob/user, buildmode, params, var/obj/object)
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H in GLOB.buildholders)
		if(H.cl == user.client)
			holder = H
			break
	if(!holder)
		return
	var/list/pa = params2list(params)

	if(!get_turf(object))
		return

	switch(buildmode)
		if(1) // Basic Build
			if(istype(object,/turf) && pa.Find("left") && !pa.Find("alt") && !pa.Find("ctrl") )
				var/turf/T = object
				if(istype(object,/turf/space) || istype(object, /turf/simulated/open))
					T.ChangeTurf(/turf/simulated/floor/plating)
					log_admin("[key_name(usr)] created 1 plating at [COORD(T)]")
					return
				else if(T.outdoors)
					log_admin("[key_name(usr)] created 1 plating at [COORD(T)]")
					T.PlaceOnTop(/turf/simulated/floor/plating)
					return
				else if(istype(object,/turf/simulated/floor))
					log_admin("[key_name(usr)] created 1 wall at [COORD(T)]")
					T.PlaceOnTop(/turf/simulated/wall)
					return
				else if(istype(object,/turf/simulated/wall))
					log_admin("[key_name(usr)] created 1 rwall at [COORD(T)]")
					T.ChangeTurf(/turf/simulated/wall/r_wall)
					return
			else if(pa.Find("right"))
				if(istype(object, /turf))
					var/turf/T = object
					log_admin("[key_name(usr)] tore away 1 [T] at [COORD(T)]")
					T.ScrapeAway()
					return
				else if(istype(object,/obj))
					var/turf/TC = get_turf(object)
					log_admin("[key_name(usr)] deleted [object] at [COORD(TC)]")
					qdel(object)
					return
			else if(istype(object,/turf) && pa.Find("alt") && pa.Find("left"))
				var/turf/TC = get_turf(object)
				log_admin("[key_name(usr)] made an airlock at [COORD(TC)]")
				new/obj/machinery/door/airlock(get_turf(object))
			else if(istype(object,/turf) && pa.Find("ctrl") && pa.Find("left"))
				switch(holder.builddir.dir)
					if(NORTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.setDir(NORTH)
					if(SOUTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.setDir(SOUTH)
					if(EAST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.setDir(EAST)
					if(WEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.setDir(WEST)
					if(NORTHWEST)
						new /obj/spawner/window/reinforced/full(get_turf(object))
				var/turf/TC = get_turf(object)
				log_admin("[key_name(usr)] made a window at [COORD(TC)]")
		if(2) // Adv. Build
			if(pa.Find("left") && !pa.Find("ctrl"))
				var/turf/TC = get_turf(object)
				if(ispath(holder.buildmode.objholder,/turf))
					// warning: this is bad heuristics, but for the time being, we don't have another choice / i'm too lazy to think this through.
					var/turf/T = get_turf(object)
					var/turf/making_path = holder.buildmode.objholder
					if(T.density) // T is dense, we likely want to replace it as it's likely a wall
						T.ChangeTurf(holder.buildmode.objholder)
					else if(initial(making_path.density)) // thing we're placing is dense but not existing turf, place on top
						T.PlaceOnTop(holder.buildmode.objholder)
					else // densities match / other cases just changeturf.
						T.ChangeTurf(holder.buildmode.objholder)
				else
					var/obj/A = new holder.buildmode.objholder (get_turf(object))
					A.setDir(holder.builddir.dir)
				log_admin("[key_name(usr)] made 1 [holder.buildmode.objholder] at [COORD(TC)]")
			else if(pa.Find("right"))
				if(isobj(object))
					qdel(object)
			else if(pa.Find("ctrl"))
				holder.buildmode.objholder = object.type
				to_chat(user, "<span class='notice'>[object]([object.type]) copied to buildmode.</span>")
			if(pa.Find("middle"))
				holder.buildmode.objholder = text2path("[object.type]")
				if(holder.buildmode.objsay)	to_chat(usr, "[object.type]")


		if(3) // Edit
			if(pa.Find("left")) //I cant believe this shit actually compiles.
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = holder.buildmode.valueholder
				else
					to_chat(user, "<span class='danger'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")
			if(pa.Find("right"))
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = initial(object.vars[holder.buildmode.varholder])
				else
					to_chat(user, "<span class='danger'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>")

		if(4) // Throw
			if(pa.Find("left"))
				if(istype(object, /atom/movable))
					holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom)
					holder.throw_atom.throw_at_old(object, 10, 1)
					log_admin("[key_name(usr)] threw [holder.throw_atom] at [object]")
		if(5) // Room build
			if(pa.Find("left"))
				holder.buildmode.coordA = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as point A.</span>")

			if(pa.Find("right"))
				holder.buildmode.coordB = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as point B.</span>")

			if(holder.buildmode.coordA && holder.buildmode.coordB)
				to_chat(user, "<span class='notice'>A and B set, creating rectangle.</span>")
				holder.buildmode.make_rectangle(
					holder.buildmode.coordA,
					holder.buildmode.coordB,
					holder.buildmode.wall_holder,
					holder.buildmode.floor_holder
					)
				holder.buildmode.coordA = null
				log_admin("[key_name(usr)] mass-built [AREACOORD(holder.buildmode.coordA)] to [AREACOORD(holder.buildmode.coordB)] with [holder.buildmode.wall_holder] [holder.buildmode.floor_holder]")
				holder.buildmode.coordB = null
		if(6) // Ladders
			if(pa.Find("left"))
				holder.buildmode.coordA = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as upper ladder location.</span>")

			if(pa.Find("right"))
				holder.buildmode.coordB = get_turf(object)
				to_chat(user, "<span class='notice'>Defined [object] ([object.type]) as lower ladder location.</span>")

			if(holder.buildmode.coordA && holder.buildmode.coordB)
				to_chat(user, "<span class='notice'>Ladder locations set, building ladders.</span>")
				var/obj/structure/ladder/A = new /obj/structure/ladder/up(holder.buildmode.coordA)
				var/obj/structure/ladder/B = new /obj/structure/ladder(holder.buildmode.coordB)
				A.target_up = B
				B.target_down = A
				A.update_icon()
				B.update_icon()
				holder.buildmode.coordA = null
				holder.buildmode.coordB = null
				log_admin("[key_name(usr)] built ladders at [AREACOORD(holder.buildmode.coordA)], [AREACOORD(holder.buildmode.coordB)]")
		if(7) // Move into contents
			if(pa.Find("left"))
				if(istype(object, /atom))
					holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom && istype(object, /atom/movable))
					object.forceMove(holder.throw_atom)
					log_admin("[key_name(usr)] moved [object] into [holder.throw_atom].")
		if(8) // Lights
			if(pa.Find("left"))
				if(object)
					object.set_light(holder.buildmode.new_light_range, holder.buildmode.new_light_intensity, holder.buildmode.new_light_color)
					log_admin("[key_name(usr)] set light [object] at [AREACOORD(object)] to [holder.buildmode.new_light_range]/[holder.buildmode.new_light_intensity]/[holder.buildmode.new_light_color]")
			if(pa.Find("right"))
				if(object)
					object.set_light(0, 0, "#FFFFFF")
					log_admin("[key_name(usr)] reset light [object] at [AREACOORD(object)]")
		if(9) // AI control
			if(pa.Find("left"))
				if(isliving(object))
					var/mob/living/L = object
					// Reset processes.
					if(pa.Find("ctrl"))
						if(!isnull(L.get_polaris_AI_stance())) // Null means there's no AI datum or it has one but is player controlled w/o autopilot on.
							var/datum/ai_holder/polaris/AI = L.ai_holder
							AI.forget_everything()
							to_chat(user, SPAN_NOTICE("\The [L]'s AI has forgotten its target/movement destination/leader."))
						else
							to_chat(user, SPAN_WARNING( "\The [L] is not AI controlled."))
						return

					// Toggle hostility
					if(pa.Find("alt"))
						if(!isnull(L.get_polaris_AI_stance()))
							var/datum/ai_holder/polaris/AI = L.ai_holder
							AI.hostile = !AI.hostile
							to_chat(user, SPAN_NOTICE("\The [L] is now [AI.hostile ? "hostile" : "passive"]."))
						else
							to_chat(user, SPAN_WARNING( "\The [L] is not AI controlled."))
						return

					// Select/Deselect
					if(!isnull(L.get_polaris_AI_stance()))
						if(L in holder.selected_mobs)
							holder.deselect_AI_mob(user.client, L)
							to_chat(user, SPAN_NOTICE("Deselected \the [L]."))
						else
							holder.select_AI_mob(user.client, L)
							to_chat(user, SPAN_NOTICE("Selected \the [L]."))
					else
						to_chat(user, SPAN_WARNING( "\The [L] is not AI controlled."))

			if(pa.Find("right"))
				if(istype(object, /atom)) // Force attack.
					var/atom/A = object

					if(pa.Find("alt"))
						var/i = 0
						for(var/mob/living/unit in holder.selected_mobs)
							var/datum/ai_holder/polaris/AI = unit.ai_holder
							AI.give_target(A)
							i++
						to_chat(user, SPAN_NOTICE("Commanded [i] mob\s to attack \the [A]."))
						log_admin("[key_name(usr)] buildmode AI: Commanded [i] mob\s to attack \the [A].")
						return

				if(isliving(object)) // Follow or attack.
					var/mob/living/L = object
					var/i = 0 // Attacking mobs.
					var/j = 0 // Following mobs.
					for(var/mob/living/unit in holder.selected_mobs)
						var/datum/ai_holder/polaris/AI = unit.ai_holder
						if(L.IIsAlly(unit) || !AI.hostile || pa.Find("shift"))
							AI.set_follow(L)
							j++
						else
							AI.give_target(L)
							i++
					var/message = "Commanded "
					if(i)
						message += "[i] mob\s to attack \the [L]"
						if(j)
							message += ", and "
						else
							message += "."
					if(j)
						message += "[j] mob\s to follow \the [L]."
					to_chat(user, SPAN_NOTICE(message))
					log_admin("[key_name(usr)] buildmode AI: [message]")

				if(isturf(object)) // Move or reposition.
					var/turf/T = object
					var/i = 0
					for(var/mob/living/unit in holder.selected_mobs)
						var/datum/ai_holder/polaris/AI = unit.ai_holder
						AI.give_destination(T, 1, pa.Find("shift")) // If shift is held, the mobs will not stop moving to attack a visible enemy.
						i++
					to_chat(user, SPAN_NOTICE("Commanded [i] mob\s to move to \the [T]."))
					log_admin("[key_name(usr)] buildmode AI: Commanded [i] mob\s to move to \the [T].")

/obj/effect/bmode/buildmode/proc/get_path_from_partial_text(default_path)
	var/desired_path = input("Enter full or partial typepath.","Typepath","[default_path]")

	var/list/types = typesof(/atom)
	var/list/matches = list()

	for(var/path in types)
		if(findtext("[path]", desired_path))
			matches += path

	if(matches.len==0)
		alert("No results found.  Sorry.")
		return

	var/result = null

	if(matches.len==1)
		result = matches[1]
	else
		result = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
		if(!objholder)
			result = default_path
	return result

/obj/effect/bmode/buildmode/proc/make_rectangle(var/turf/A, var/turf/B, var/turf/wall_type, var/turf/floor_type)
	if(!A || !B) // No coords
		return
	if(A.z != B.z) // Not same z-level
		return

	var/height = A.y - B.y
	var/width = A.x - B.x
	var/z_level = A.z

	var/turf/lower_left_corner = null
	// First, try to find the lowest part
	var/desired_y = 0
	if(A.y <= B.y)
		desired_y = A.y
	else
		desired_y = B.y

	//Now for the left-most part.
	var/desired_x = 0
	if(A.x <= B.x)
		desired_x = A.x
	else
		desired_x = B.x

	lower_left_corner = locate(desired_x, desired_y, z_level)

	// Now we can begin building the actual room.  This defines the boundries for the room.
	var/low_bound_x = lower_left_corner.x
	var/low_bound_y = lower_left_corner.y

	var/high_bound_x = lower_left_corner.x + abs(width)
	var/high_bound_y = lower_left_corner.y + abs(height)

	for(var/i = low_bound_x, i <= high_bound_x, i++)
		for(var/j = low_bound_y, j <= high_bound_y, j++)
			var/turf/T = locate(i, j, z_level)
			if(i == low_bound_x || i == high_bound_x || j == low_bound_y || j == high_bound_y)
				if(isturf(wall_type))
					T.ChangeTurf(wall_type)
				else
					new wall_type(T)
			else
				if(isturf(floor_type))
					T.ChangeTurf(floor_type)
				else
					new floor_type(T)
