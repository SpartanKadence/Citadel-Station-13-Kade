#define DRINK_ICON_FILE 'icons/pdrink.dmi'

/var/const/DRINK_FIZZ = "fizz"
/var/const/DRINK_ICE = "ice"
/var/const/DRINK_ICON_DEFAULT = ""
/var/const/DRINK_ICON_NOISY = "_noise"

/obj/item/reagent_containers/food/drinks/glass2
	name = "glass" // Name when empty
	var/base_name = "glass" // Name to put in front of drinks, i.e. "[base_name] of [contents]"
	desc = "A generic drinking glass." // Description when empty
	icon = DRINK_ICON_FILE
	var/base_icon = "square" // Base icon name
	volume = 30

	var/list/filling_states // List of percentages full that have icons

	var/list/extras = list() // List of extras. Two extras maximum

	var/rim_pos

	center_of_mass = list("x"=16, "y"=10)

	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,15,30)
	atom_flags = OPENCONTAINER

	materials_base = list(MAT_GLASS = 60)

/obj/item/reagent_containers/food/drinks/glass2/examine(mob/user, dist)
	. = ..()

	for(var/I in extras)
		if(istype(I, /obj/item/glass_extra))
			. += "There is \a [I] in \the [src]."
		else if(istype(I, /obj/item/reagent_containers/food/snacks/fruit_slice))
			. += "There is \a [I] on the rim."
		else
			. += "There is \a [I] somewhere on the glass. Somehow."

	if(has_ice())
		. += "There is some ice floating in the drink."

	if(has_fizz())
		. += "It is fizzing slightly."

/obj/item/reagent_containers/food/drinks/glass2/proc/has_ice()
	if(reagents.total_volume)
		var/datum/reagent/R = reagents.get_majority_reagent_datum()
		if(!((R.id == "ice") || ("ice" in R.glass_special))) // if it's not a cup of ice, and it's not already supposed to have ice in, see if the bartender's put ice in it
			if(reagents.has_reagent("ice", reagents.total_volume / 10)) // 10% ice by volume
				return 1

	return 0

/obj/item/reagent_containers/food/drinks/glass2/proc/has_fizz()
	if(reagents.total_volume)
		var/datum/reagent/R = reagents.get_majority_reagent_datum()
		if(!("fizz" in R.glass_special))
			var/totalfizzy = 0
			for(var/datum/reagent/re in reagents.get_reagent_datums())
				if("fizz" in re.glass_special)
					totalfizzy += reagents.reagent_volumes[re.id]
			if(totalfizzy >= reagents.total_volume / 5) // 20% fizzy by volume
				return 1
	return 0

/obj/item/reagent_containers/food/drinks/glass2/Initialize(mapload)
	. = ..()
	icon_state = base_icon

/obj/item/reagent_containers/food/drinks/glass2/on_reagent_change()
	..()
	update_icon()

/obj/item/reagent_containers/food/drinks/glass2/proc/can_add_extra(obj/item/glass_extra/GE)
	if(!("[base_icon]_[GE.glass_addition]left" in icon_states(DRINK_ICON_FILE)))
		return 0
	if(!("[base_icon]_[GE.glass_addition]right" in icon_states(DRINK_ICON_FILE)))
		return 0

	return 1

/obj/item/reagent_containers/food/drinks/glass2/update_icon()
	underlays.Cut()

	if (reagents.total_volume)
		var/datum/reagent/R = reagents.get_majority_reagent_datum()
		name = "[base_name] of [R.glass_name ? R.glass_name : "something"]"
		desc = R.glass_desc ? R.glass_desc : initial(desc)

		var/list/under_liquid = list()
		var/list/over_liquid = list()

		var/amnt = 100
		var/percent = round((reagents.total_volume / volume) * 100)
		for(var/k in filling_states)
			if(percent <= k)
				amnt = k
				break

		if(has_ice())
			over_liquid |= "[base_icon][amnt]_ice"

		if(has_fizz())
			over_liquid |= "[base_icon][amnt]_fizz"

		for(var/S in R.glass_special)
			if("[base_icon]_[S]" in icon_states(DRINK_ICON_FILE))
				under_liquid |= "[base_icon]_[S]"
			else if("[base_icon][amnt]_[S]" in icon_states(DRINK_ICON_FILE))
				over_liquid |= "[base_icon][amnt]_[S]"

		for(var/k in under_liquid)
			underlays += image(DRINK_ICON_FILE, src, k, -3)

		var/image/filling = image(DRINK_ICON_FILE, src, "[base_icon][amnt][R.glass_icon]", -2)
		filling.color = reagents.get_color()
		underlays += filling

		for(var/k in over_liquid)
			underlays += image(DRINK_ICON_FILE, src, k, -1)
	else
		name = initial(name)
		desc = initial(desc)

	var/side = "left"
	for(var/item in extras)
		if(istype(item, /obj/item/glass_extra))
			var/obj/item/glass_extra/GE = item
			var/image/I = image(DRINK_ICON_FILE, src, "[base_icon]_[GE.glass_addition][side]")
			if(GE.glass_color)
				I.color = GE.glass_color
			underlays += I
		else if(istype(item, /obj/item/reagent_containers/food/snacks/fruit_slice))
			var/obj/FS = item
			var/image/I = image(FS)

			var/fsy = rim_pos[1] - 20
			var/fsx = rim_pos[side == "left" ? 2 : 3] - 16

			var/matrix/M = matrix()
			M.Scale(0.5)
			M.Translate(fsx, fsy)
			I.transform = M
			underlays += I
		else continue
		side = "right"

/obj/item/reagent_containers/food/drinks/glass2/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	if(user.a_intent == INTENT_HARM) //We only want splashing to be done if they are on harm intent.
		if(!is_open_container() || !(clickchain_flags & CLICKCHAIN_HAS_PROXIMITY))
			return 1
		if(standard_splash_mob(user, target))
			return 1
		if(reagents && reagents.total_volume) //They are on harm intent, aka wanting to spill it.
			to_chat(user, "<span class='notice'>You splash the solution onto [target].</span>")
			reagents.splash(target, reagents.total_volume)
			return 1
	..()

/obj/item/reagent_containers/food/drinks/glass2/standard_feed_mob(var/mob/user, var/mob/target)
	if(afterattack(target, user)) //Check to see if harm intent & splash.
		return
	else
		..() //If they're splashed, no need to do anything else.
