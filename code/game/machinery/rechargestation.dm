/obj/machinery/recharge_station
	name = "cyborg recharging station"
	desc = "A heavy duty rapid charging system, designed to quickly recharge cyborg power reserves."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1
	circuit = /obj/item/circuitboard/recharge_station
	use_power = USE_POWER_IDLE
	idle_power_usage = 10

	var/mob/occupant = null
	var/obj/item/cell/cell = null
	var/charging = FALSE

	/// Used to rebuild the overlay only once every 10 ticks.
	var/icon_update_tick = 0

	/// W. Power rating used for charging the cyborg. 120 kW if un-upgraded.
	var/charging_power
	/// W. Power drawn from APC when an occupant is charging. 40 kW if un-upgraded.
	var/restore_power_active
	/// W. Power drawn from APC when idle. 7 kW if un-upgraded.
	var/restore_power_passive
	/// How much brute damage is repaired per tick.
	var/weld_rate = 0
	/// How much burn damage is repaired per tick.
	var/wire_rate = 0

	/// Power used per point of brute damage repaired. 2.3 kW ~ about the same power usage of a handheld arc welder.
	var/weld_power_use = 2300
	/// Power used per point of burn damage repaired.
	var/wire_power_use = 500

/obj/machinery/recharge_station/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/recharge_station/proc/has_cell_power()
	return cell && cell.percent() > 0

/obj/machinery/recharge_station/process(delta_time)
	if(machine_stat & (BROKEN))
		return
	if(!cell) // Shouldn't be possible, but sanity check
		return

	if((machine_stat & NOPOWER) && !has_cell_power()) // No power and cell is dead.
		if(icon_update_tick)
			icon_update_tick = 0 //just rebuild the overlay once more only
			update_icon()
		return

	//First, draw from the internal power cell to recharge/repair/etc the occupant
	if(occupant)
		process_occupant()

	//Then, if external power is available, recharge the internal cell
	var/recharge_amount = 0
	if(!(machine_stat & NOPOWER))
		// Calculating amount of power to draw
		recharge_amount = (occupant ? restore_power_active : restore_power_passive)
		recharge_amount = DYNAMIC_W_TO_CELL_UNITS(recharge_amount, 1)
		recharge_amount = cell.give(recharge_amount)
		use_power(DYNAMIC_CELL_UNITS_TO_W(recharge_amount, 1))

	if(icon_update_tick >= 10)
		icon_update_tick = 0
	else
		icon_update_tick++

	if(occupant || recharge_amount)
		update_icon()

//Processes the occupant, drawing from the internal power cell if needed.
/obj/machinery/recharge_station/proc/process_occupant()
	if(isrobot(occupant))
		var/mob/living/silicon/robot/R = occupant

		if(R.module)
			R.module.respawn_consumable(R, DYNAMIC_W_TO_CELL_UNITS(charging_power, 1) / 250) //consumables are magical, apparently
		if(R.cell && !R.cell.fully_charged())
			var/diff = min(R.cell.maxcharge - R.cell.charge, DYNAMIC_W_TO_CELL_UNITS(charging_power, 1)) // Capped by charging_power / tick
			var/charge_used = cell.use(diff)
			R.cell.give(charge_used)

		//Lastly, attempt to repair the cyborg if enabled
		if(weld_rate && R.getBruteLoss() && cell.checked_use(DYNAMIC_W_TO_CELL_UNITS(weld_power_use * weld_rate, 1)))
			R.adjustBruteLoss(-weld_rate)
		if(wire_rate && R.getFireLoss() && cell.checked_use(DYNAMIC_W_TO_CELL_UNITS(wire_power_use * wire_rate, 1)))
			R.adjustFireLoss(-wire_rate)

	//Handles drone matrix upgrades
	if(isDrone(occupant))
		var/mob/living/silicon/robot/drone/D = occupant
		if(D.master_matrix && D.upgrade_cooldown < world.time && D.cell.fully_charged())
			D.upgrade_cooldown = world.time + 1 MINUTE
			D.master_matrix.apply_upgrades(D)

	else if(is_holosphere_shell(occupant))
		var/mob/living/simple_mob/holosphere_shell/shell = occupant
		handle_human_nutrition(shell.hologram)

	else if(ishuman(occupant))
		var/mob/living/carbon/human/H = occupant

		if(H.isSynthetic())
			// In case they somehow end up with positive values for otherwise unobtainable damage...
			if(H.getToxLoss() > 0)
				H.adjustToxLoss(-(rand(1,3)))
			if(H.getOxyLoss() > 0)
				H.adjustOxyLoss(-(rand(1,3)))
			if(H.getCloneLoss() > 0)
				H.adjustCloneLoss(-(rand(1,3)))
			if(H.getBrainLoss() > 0)
				H.adjustBrainLoss(-(rand(1,3)))

			handle_human_nutrition(H)

		var/obj/item/hardsuit/wornrig = H.get_hardsuit()
		if(wornrig) // just to make sure
			for(var/obj/item/hardsuit_module/storedmod in wornrig)
				if(weld_rate && storedmod.damage != 0 && cell.checked_use(DYNAMIC_W_TO_CELL_UNITS(weld_power_use * weld_rate, 1)))
					to_chat(H, "<span class='notice'>\The [storedmod] is repaired!</span>")
					storedmod.damage = 0
			var/obj/item/cell/rigcell = wornrig.get_cell()
			if(rigcell)
				var/diff = min(rigcell.maxcharge - rigcell.charge, DYNAMIC_W_TO_CELL_UNITS(charging_power, 1)) // Capped by charging_power / tick
				var/charge_used = cell.use(diff)
				rigcell.give(charge_used)

/obj/machinery/recharge_station/proc/handle_human_nutrition(mob/living/carbon/human/H)
	// Also recharge their internal battery.
	if(H.nutrition < H.species.max_nutrition)
		var/needed = clamp(H.species.max_nutrition - H.nutrition, 0, 20)
		var/drained = cell.use(DYNAMIC_KJ_TO_CELL_UNITS(needed * SYNTHETIC_NUTRITION_KJ_PER_UNIT))
		H.nutrition += DYNAMIC_CELL_UNITS_TO_KJ(drained) / SYNTHETIC_NUTRITION_KJ_PER_UNIT

	// And clear up radiation
	H.cure_radiation(RAD_MOB_CURE_SYNTH_CHARGER)

/obj/machinery/recharge_station/examine(mob/user, dist)
	. = ..()
	. += "<span class = 'notice'>The charge meter reads: [round(chargepercentage())]%</span>"

/obj/machinery/recharge_station/proc/chargepercentage()
	if(!cell)
		return 0
	return cell.percent()

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	go_out()
	return

/obj/machinery/recharge_station/emp_act(severity)
	if(occupant)
		occupant.emp_act(severity)
		go_out()
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/recharge_station/attackby(obj/item/O, mob/user)
	if(!occupant)
		if(default_deconstruction_screwdriver(user, O))
			return
		if(default_deconstruction_crowbar(user, O))
			return
		if(default_part_replacement(user, O))
			return
		if (istype(O, /obj/item/grab) && get_dist(src,user)<2)
			var/obj/item/grab/G = O
			if(istype(G.affecting,/mob/living))
				var/mob/living/M = G.affecting
				qdel(O)
				go_in(M)

	..()

/obj/machinery/recharge_station/MouseDroppedOnLegacy(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user))
		return

	go_in(target)

/obj/machinery/recharge_station/RefreshParts()
	..()
	var/man_rating = 0
	var/cap_rating = 0

	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/capacitor))
			cap_rating += P.rating
		if(istype(P, /obj/item/stock_parts/manipulator))
			man_rating += P.rating
	cell = locate(/obj/item/cell) in component_parts

	charging_power = 40000 + 40000 * cap_rating
	restore_power_active = 10000 + 15000 * cap_rating
	restore_power_passive = 5000 + 1000 * cap_rating
	weld_rate = max(0, man_rating - 3)
	wire_rate = max(0, man_rating - 5)

	desc = initial(desc)
	desc += " Uses a dedicated internal power cell to deliver [charging_power]W when in use."
	if(weld_rate)
		desc += "<br>It is capable of repairing structural damage."
	if(wire_rate)
		desc += "<br>It is capable of repairing burn damage."

/obj/machinery/recharge_station/proc/build_overlays()
	cut_overlays()
	switch(round(chargepercentage()))
		if(1 to 20)
			add_overlay(image('icons/obj/objects.dmi', "statn_c0"))
		if(21 to 40)
			add_overlay(image('icons/obj/objects.dmi', "statn_c20"))
		if(41 to 60)
			add_overlay(image('icons/obj/objects.dmi', "statn_c40"))
		if(61 to 80)
			add_overlay(image('icons/obj/objects.dmi', "statn_c60"))
		if(81 to 98)
			add_overlay(image('icons/obj/objects.dmi', "statn_c80"))
		if(99 to 110)
			add_overlay(image('icons/obj/objects.dmi', "statn_c100"))

/obj/machinery/recharge_station/update_icon()
	..()
	if(machine_stat & BROKEN)
		icon_state = "borgcharger0"
		return

	if(occupant)
		if((machine_stat & NOPOWER) && !has_cell_power())
			icon_state = "borgcharger2"
		else
			icon_state = "borgcharger1"
	else
		icon_state = "borgcharger0"

	if(icon_update_tick == 0)
		build_overlays()

/obj/machinery/recharge_station/Bumped(mob/living/L)
	go_in(L)

/obj/machinery/recharge_station/proc/go_in(mob/living/L)
	if(!istype(L))
		return
	if(occupant || L.buckled)
		return

	if(istype(L, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = L

		if(R.incapacitated())
			return

		if(!R.cell)
			return

		add_fingerprint(R)
		R.forceMove(src)
		R.update_perspective()
		occupant = R
		update_icon()
		return TRUE

	else if(istype(L,  /mob/living/carbon/human))
		var/mob/living/carbon/human/H = L
		if(H.isSynthetic() || H.wearing_rig)
			add_fingerprint(H)
			H.forceMove(src)
			H.update_perspective()
			occupant = H
			update_appearance()
			return TRUE
	else if(is_holosphere_shell(L))
		var/mob/living/simple_mob/holosphere_shell/shell = L
		var/mob/living/carbon/human/H = shell.hologram
		add_fingerprint(H)
		shell.forceMove(src)
		shell.update_perspective()
		occupant = shell
		update_appearance()
		return TRUE
	else
		return

/obj/machinery/recharge_station/proc/go_out()
	if(!occupant)
		return

	occupant.forceMove(src.loc)
	occupant.update_perspective()
	occupant = null
	update_appearance()

/obj/machinery/recharge_station/verb/move_eject()
	set category = VERB_CATEGORY_OBJECT
	set name = "Eject Recharger"
	set src in oview(1)

	if(usr.incapacitated() || !isliving(usr))
		return

	go_out()
	add_fingerprint(usr)
	return

/obj/machinery/recharge_station/verb/move_inside()
	set category = VERB_CATEGORY_OBJECT
	set name = "Enter Recharger"
	set src in oview(1)

	if(usr.incapacitated() || !isliving(usr))
		return

	go_in(usr)

/obj/machinery/recharge_station/ghost_pod_recharger
	name = "drone pod"
	desc = "This is a pod which used to contain a drone... Or maybe it still does?"
	icon = 'icons/obj/structures.dmi'

/obj/machinery/recharge_station/ghost_pod_recharger/update_icon()
	..()
	if(machine_stat & BROKEN)
		icon_state = "borg_pod_closed"
		desc = "It appears broken..."
		return

	if(occupant)
		if((machine_stat & NOPOWER) && !has_cell_power())
			icon_state = "borg_pod_closed"
			desc = "It appears to be unpowered..."
		else
			icon_state = "borg_pod_closed"
	else
		icon_state = "borg_pod_opened"

	if(icon_update_tick == 0)
		build_overlays()
