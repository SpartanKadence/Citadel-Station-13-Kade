/obj/machinery/sleep_console
	name = "sleeper console"
	icon = 'icons/obj/medical/cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/sleeper
	anchored = TRUE
	density = TRUE
	dir = 8
	use_power = USE_POWER_IDLE
	idle_power_usage = 40
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_ALLOW_SILICON
	circuit = /obj/item/circuitboard/sleeper_console

/obj/machinery/sleep_console/Initialize(mapload, newdir)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/sleep_console/LateInitialize()
	findsleeper()

/obj/machinery/sleep_console/Destroy()
	if(sleeper)
		sleeper.console = null
	return ..()

/obj/machinery/sleep_console/proc/findsleeper()
	var/obj/machinery/sleeper/sleepernew = null
	for(dir in list(NORTH, EAST, SOUTH, WEST)) // Loop through every direction
		sleepernew = locate(/obj/machinery/sleeper, get_step(src, dir)) // Try to find a scanner in that direction
		if(sleepernew)
			sleeper = sleepernew
			sleepernew.console = src
			break


/obj/machinery/sleep_console/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(..())
		return 1

	if(!sleeper)
		findsleeper()
		if(!sleeper)
			to_chat(user, "<span class='notice'>Sleeper not found!</span>")
			return

	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(sleeper)
		return nano_ui_interact(user)

/obj/machinery/sleep_console/attackby(obj/item/I, mob/user)
	if(computer_deconstruction_screwdriver(user, I))
		return
	else
		return attack_hand(user)

/obj/machinery/sleep_console/power_change()
	..()
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = "sleeperconsole-p"
	else
		icon_state = initial(icon_state)

/obj/machinery/sleep_console/nano_ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = outside_state)
	var/data[0]

	var/obj/machinery/sleeper/S = sleeper
	var/mob/living/carbon/human/occupant = sleeper.occupant

	data["power"] = S.machine_stat & (NOPOWER|BROKEN) ? FALSE : TRUE

	var/list/reagents = list()
	for(var/T in S.available_chemicals)
		var/list/reagent = list()
		reagent["id"] = T
		reagent["name"] = S.available_chemicals[T]
		if(occupant)
			reagent["amount"] = occupant.reagents.get_reagent_amount(T)
		reagents += list(reagent)
	data["reagents"] = reagents.Copy()

	if(occupant)
		data["occupant"] = 1
		switch(occupant.stat)
			if(CONSCIOUS)
				data["stat"] = "Conscious"
			if(UNCONSCIOUS)
				data["stat"] = "Unconscious"
			if(DEAD)
				data["stat"] = "<font color='red'>Dead</font>"
		data["health"] = occupant.health
		data["maxHealth"] = occupant.getMaxHealth()
		if(iscarbon(occupant))
			var/mob/living/carbon/C = occupant
			data["pulse"] = C.get_pulse(GETPULSE_TOOL)
		data["brute"] = occupant.getBruteLoss()
		data["burn"] = occupant.getFireLoss()
		data["oxy"] = occupant.getOxyLoss()
		data["tox"] = occupant.getToxLoss()
	else
		data["occupant"] = 0
	if(S.beaker)
		data["beaker"] = S.beaker.reagents.available_volume()
	else
		data["beaker"] = -1
	data["filtering"] = S.filtering
	data["pump"] = S.pumping

	var/stasis_level_name = "Error!"
	for(var/N in S.stasis_choices)
		if(S.stasis_choices[N] == S.stasis_level)
			stasis_level_name = N
			break
	data["stasis"] = stasis_level_name

	ui = SSnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sleeper.tmpl", "Sleeper UI", 600, 600, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return TRUE

	var/obj/machinery/sleeper/S = sleeper

	if(usr == S.occupant)
		to_chat(usr, SPAN_WARNING("You can't reach the controls from the inside."))
		return

	if(href_list["eject"])
		S.go_out()
	if(href_list["beaker"])
		S.remove_beaker()
	if(href_list["sleeper_filter"])
		if(S.filtering != text2num(href_list["sleeper_filter"]))
			S.toggle_filter()
	if(href_list["pump"])
		if(S.pumping != text2num(href_list["pump"]))
			S.toggle_pump()
	if(href_list["chemical"] && href_list["amount"])
		if(S.occupant && S.occupant.stat != DEAD)
			if(href_list["chemical"] in S.available_chemicals) // Your hacks are bad and you should feel bad
				S.inject_chemical(usr, href_list["chemical"], text2num(href_list["amount"]))
	if(href_list["change_stasis"])
		var/new_stasis = input("Levels deeper than 50% stasis level will render the patient unconscious.","Stasis Level") as null|anything in S.stasis_choices
		if(new_stasis && CanUseTopic(usr, default_state) == UI_INTERACTIVE)
			S.stasis_level = S.stasis_choices[new_stasis]

	return TRUE

/obj/machinery/sleeper
	name = "sleeper"
	desc = "A stasis pod with built-in injectors, a dialysis machine, and a limited health scanner."
	icon = 'icons/obj/medical/cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/sleeper
	var/mob/living/carbon/human/occupant = null
	var/list/available_chemicals = list()
	var/list/base_chemicals = list("inaprovaline" = "Inaprovaline", "paracetamol" = "Paracetamol", "anti_toxin" = "Dylovene", "dexalin" = "Dexalin")
	var/obj/item/reagent_containers/glass/beaker = null
	var/filtering = FALSE
	var/pumping = FALSE
	var/obj/machinery/sleep_console/console
	var/stasis_level = 0 //Every 'this' life ticks are applied to the mob (when life_ticks%stasis_level == 1)
	var/stasis_choices = list("Complete (1%)" = 100, "Deep (10%)" = 10, "Moderate (20%)" = 5, "Light (50%)" = 2, "None (100%)" = 0)

	use_power = USE_POWER_IDLE
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.

	/// filter flags we use for dialysis
	var/dialysis_reagent_filter_flags = ~REAGENT_FILTER_NO_COMMON_BIOANALYSIS

/obj/machinery/sleeper/Initialize(mapload)
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/beaker/large(src)

/obj/machinery/sleeper/Destroy()
	if(console)
		console.sleeper = null
	return ..()

/obj/machinery/sleeper/RefreshParts(limited = FALSE)
	var/man_rating = 0
	var/cap_rating = 0

	available_chemicals.Cut()
	available_chemicals = base_chemicals.Copy()
	idle_power_usage = initial(idle_power_usage)
	active_power_usage = initial(active_power_usage)

	for(var/obj/item/stock_parts/P in component_parts)
		if(istype(P, /obj/item/stock_parts/capacitor))
			cap_rating += P.rating

	cap_rating = max(1, round(cap_rating / 2))

	idle_power_usage /= cap_rating
	active_power_usage /= cap_rating

	if(!limited)
		for(var/obj/item/stock_parts/P in component_parts)
			if(istype(P, /obj/item/stock_parts/manipulator))
				man_rating += P.rating - 1

		var/list/new_chemicals = list()

		if(man_rating >= 4) // Alien tech.
			var/reag_ID = pickweight(list(
				"healing_nanites" = 10,
				"shredding_nanites" = 5,
				"irradiated_nanites" = 5,
				"neurophage_nanites" = 2)
				)
			new_chemicals[reag_ID] = "Nanite"
		if(man_rating >= 3) // Anomalous tech.
			new_chemicals["immunosuprizine"] = "Immunosuprizine"
		if(man_rating >= 2) // Tier 3.
			new_chemicals["spaceacillin"] = "Spaceacillin"
		if(man_rating >= 1) // Tier 2.
			new_chemicals["leporazine"] = "Leporazine"

		if(new_chemicals.len)
			available_chemicals += new_chemicals
		return

/obj/machinery/sleeper/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/sleeper/process(delta_time)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(occupant)
		occupant.Stasis(stasis_level)

		if(filtering > 0)
			if(beaker)
				// filter 3 units per chem-type inside them, or remaining volume, whichever is lesser
				// we will also pump out 1/3 of that volume as their blood.
				var/remaining_beaker_volume_for_dialysis = beaker.reagents.maximum_volume - beaker.reagents.total_volume
				var/filtered_volume = occupant.reagents?.filter_to_holder(
					beaker.reagents,
					min(
						remaining_beaker_volume_for_dialysis * (3 / 4),
						length(occupant.reagents.reagent_volumes) * 3,
					),
					dialysis_reagent_filter_flags,
				)
				occupant.take_blood_legacy(beaker, filtered_volume * (1 / 3))
			else
				toggle_filter()

		if(pumping > 0)
			if(beaker)
				// filter 3 units per chem-type inside them, or remaining volume, whichever is lesser
				occupant.ingested?.filter_to_holder(
					beaker.reagents,
					min(
						beaker.reagents.maximum_volume - beaker.reagents.total_volume,
						length(occupant.ingested.reagent_volumes) * 3,
					),
					dialysis_reagent_filter_flags,
				)
			else
				toggle_pump()

/obj/machinery/sleeper/update_icon_state()
	icon_state = "sleeper_[occupant ? TRUE : FALSE]"
	return ..()

/obj/machinery/sleeper/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(G.affecting)
			go_in(G.affecting, user)
		return

	if(!occupant)
		if(default_deconstruction_screwdriver(user, I))
			return
		if(default_deconstruction_crowbar(user, I))
			return
		if(default_part_replacement(user, I))
			return

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(!beaker)
			if(!user.attempt_insert_item_for_installation(I, src))
				return
			beaker = I
			user.visible_message(SPAN_NOTICE("\The [user] adds \a [I] to \the [src]."), SPAN_NOTICE("You add \a [I] to \the [src]."))
		else
			to_chat(user, SPAN_WARNING("\The [src] has a beaker already."))
		return
	else
		..()

/obj/machinery/sleeper/verb/move_eject()
	set name = "Eject occupant"
	set category = VERB_CATEGORY_OBJECT
	set src in oview(1)
	if(usr == occupant)
		switch(usr.stat)
			if(DEAD)
				return
			if(UNCONSCIOUS)
				to_chat(usr, SPAN_NOTICE("You struggle through the haze to hit the eject button. This will take a couple of minutes..."))
				if(do_after(usr, 2 MINUTES, src))
					go_out()
			if(CONSCIOUS)
				go_out()
	else
		if(usr.stat != CONSCIOUS)
			return
		go_out()
	add_fingerprint(usr)

/obj/machinery/sleeper/MouseDroppedOnLegacy(var/mob/target, var/mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user) || !ishuman(target))
		return
	go_in(target, user)

/obj/machinery/sleeper/relaymove(var/mob/user)
	..()
	go_out()

/obj/machinery/sleeper/emp_act(var/severity)
	if(filtering)
		toggle_filter()

	if(pumping)
		toggle_pump()

	if(machine_stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(occupant)
		go_out()

	..(severity)
/obj/machinery/sleeper/proc/toggle_filter()
	if(!occupant || !beaker)
		filtering = 0
		return
	filtering = !filtering

/obj/machinery/sleeper/proc/toggle_pump()
	if(!occupant || !beaker)
		pumping = 0
		return
	pumping = !pumping

/obj/machinery/sleeper/proc/go_in(var/mob/M, var/mob/user)
	if(!M)
		return
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(occupant)
		to_chat(user, SPAN_WARNING("\The [src] is already occupied."))
		return
	if(!ishuman(M))
		to_chat(user, SPAN_WARNING("\The [src] is not designed for that organism!"))
		return
	if(M.buckled)
		to_chat(user, SPAN_WARNING("[M == user? "You are" : "[M] is"] buckled to something!"))
		return
	if(M == user)
		visible_message("\The [user] starts climbing into \the [src].")
	else
		visible_message("\The [user] starts putting [M] into \the [src].")

	if(do_after(user, 20))
		if(occupant)
			to_chat(user, SPAN_WARNING("\The [src] is already occupied."))
			return
		M.forceMove(src)
		update_use_power(USE_POWER_ACTIVE)
		occupant = M
		update_icon()

/obj/machinery/sleeper/proc/go_out()
	if(!occupant || occupant.loc != src)
		occupant = null // JUST IN CASE
		return
	occupant.forceMove(loc)
	occupant.update_perspective()
	occupant.Stasis(0)
	occupant.loc = src.loc
	occupant = null
	for(var/atom/movable/A in src) // In case an object was dropped inside or something
		if(A == beaker || A == circuit)
			continue
		if(A in component_parts)
			continue
		A.loc = src.loc
	update_use_power(USE_POWER_IDLE)
	update_icon()
	toggle_filter()
	toggle_pump()

/obj/machinery/sleeper/proc/remove_beaker()
	if(beaker)
		beaker.loc = src.loc
		beaker = null
		toggle_filter()

/obj/machinery/sleeper/proc/inject_chemical(mob/living/user, chemical, amount)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			use_power(amount * CHEM_SYNTH_ENERGY)
			occupant.reagents.add_reagent(chemical, amount)
			to_chat(user, "Occupant now has [occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in their bloodstream.")
		else
			to_chat(user, "The subject has too many chemicals in their bloodstream.")
	else
		to_chat(user, "There's no suitable occupant in \the [src].")

//Survival/Stasis sleepers
/obj/machinery/sleeper/survival_pod
	desc = "A limited functionality sleeper, all it can do is put patients into stasis. It lacks the medication and configuration of the larger units."
	icon_state = "sleeper_0"
	stasis_level = 100 //Just one setting

/obj/machinery/sleeper/survival_pod/Initialize(mapload)
	. = ..()
	RefreshParts(1)
