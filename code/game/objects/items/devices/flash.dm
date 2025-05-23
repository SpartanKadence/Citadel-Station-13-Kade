/obj/item/flash
	name = "flash"
	desc = "Used for blinding and being an asshole."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"
	throw_force = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 10
	origin_tech = list(TECH_MAGNET = 2, TECH_COMBAT = 1)
	worth_intrinsic = 45

	var/times_used = 0 //Number of times it's been used.
	var/broken = FALSE     //Is the flash burnt out?
	var/last_used = 0 //last world.time it was used.
	var/max_flashes = 10 // How many times the flash can be used before needing to self recharge.
	var/halloss_per_flash = 30
	var/break_mod = 3 // The percent to break increased by every use on the flash.

	var/can_break = FALSE // Can the flash break?
	var/can_repair = FALSE // Can you repair the flash?
	var/repairing = FALSE // Are we repairing right now?

	var/safe_flashes = 2 // How many flashes are kept in 1% breakchance?

	var/charge_only = FALSE // Does the flash run purely on charge?

	var/base_icon = "flash"

	var/obj/item/cell/power_supply //What type of power cell this uses
	var/charge_cost = 30 //How much energy is needed to flash.
	var/use_external_power = FALSE // Do we use charge from an external source?

	var/cell_type = /obj/item/cell/device

	//? damage
	var/stagger_strength = 1.5
	var/stagger_duration = 3 SECONDS

/obj/item/flash/Initialize(mapload)
	. = ..()
	power_supply = new cell_type(src)

/obj/item/flash/attackby(var/obj/item/W, var/mob/user)
	if(W.is_screwdriver() && broken)
		if(repairing)
			to_chat(user, "<span class='notice'>\The [src] is already being repaired!</span>")
			return
		user.visible_message("<span class='notice'>\The [user] starts trying to repair \the [src]'s bulb.</span>")
		repairing = TRUE
		if(do_after(user, (40 SECONDS + rand(0, 20 SECONDS)) * W.tool_speed) && can_repair)
			if(prob(30))
				user.visible_message("<span class='notice'>\The [user] successfully repairs \the [src]!</span>")
				broken = FALSE
				update_icon()
			playsound(src.loc, W.tool_sound, 50, 1)
		else
			user.visible_message("<span class='notice'>\The [user] fails to repair \the [src].</span>")
		repairing = FALSE
	else
		..()

/obj/item/flash/update_icon()
	. = ..()
	var/obj/item/cell/battery = power_supply

	if(use_external_power)
		battery = get_external_power_supply()

	if(broken || !battery || battery.charge < charge_cost)
		icon_state = "[base_icon]burnt"
	else
		icon_state = "[base_icon]"

/obj/item/flash/get_cell(inducer)
	return power_supply

/obj/item/flash/proc/get_external_power_supply()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		return R.cell
	if(istype(src.loc, /obj/item/hardsuit_module))
		var/obj/item/hardsuit_module/module = src.loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/hardsuit/suit = H.back
				if(istype(suit))
					return suit.cell
	return null

/obj/item/flash/proc/clown_check(var/mob/user)
	if(user && (MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>\The [src] slips out of your hand.</span>")
		user.drop_active_held_item()
		return 0
	return 1

/obj/item/flash/proc/flash_recharge()
	//Every ten seconds the flash doesn't get used, the times_used variable goes down by one, making the flash less likely to burn out,
	// as well as being able to flash more before reaching max_flashes cap.
	for(var/i=0, i < max_flashes, i++)
		if(last_used + 10 SECONDS > world.time)
			break

		else if(use_external_power)
			var/obj/item/cell/external = get_external_power_supply()
			if(!external || !external.use(charge_cost)) //Take power from the borg or rig!
				break

		else if(!power_supply || !power_supply.checked_use(charge_cost))
			break

		last_used += 10 SECONDS
		times_used--

	last_used = world.time
	times_used = max(0,round(times_used)) //sanity
	update_icon()

// Returns true if the device can flash.
/obj/item/flash/proc/check_capacitor(var/mob/user)
	//spamming the flash before it's fully charged (60 seconds) increases the chance of it breaking
	//It will never break on the first use.
	var/obj/item/cell/battery = power_supply

	if(use_external_power)
		battery = get_external_power_supply()

	if(times_used <= max_flashes && battery && battery.charge >= charge_cost)
		last_used = world.time
		if(prob( max(0, times_used - safe_flashes) * 2 + (times_used >= safe_flashes)) && can_break)	//if you use it 10 times in a minute it has a 30% chance to break.
			broken = TRUE
			if(user)
				to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
			update_icon()
			return FALSE
		else
			times_used++
			update_icon()
			return TRUE
	else if(!charge_only)	//can only use it 10 times a minute, unless it runs purely on charge.
		if(user)
			update_icon()
			to_chat(user, "<span class='warning'><i>click</i></span>")
			playsound(src.loc, 'sound/weapons/empty.ogg', 80, 1)
		return FALSE
	else if(battery && battery.checked_use(charge_cost + (round(charge_cost / 4) * max(0, times_used - max_flashes)))) // Using over your maximum flashes starts taking more charge per added flash.
		times_used++
		update_icon()
		return TRUE

//attack_as_weapon
/obj/item/flash/attack_mob(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	flash_mob(target, user)
	return CLICKCHAIN_DO_NOT_PROPAGATE

/obj/item/flash/proc/flash_mob(mob/M, mob/user)
	if(!user || !M)
		return	//sanity

	add_attack_logs(user,M,"Flashed (attempt) with [src]")

	user.setClickCooldownLegacy(user.get_attack_speed_legacy(src))
	user.do_attack_animation(M)

	if(!clown_check(user))
		return
	if(broken)
		to_chat(user, "<span class='warning'>\The [src] is broken.</span>")
		return

	flash_recharge()

	if(!check_capacitor(user))
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	var/flashfail = 0

	// NIF
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.nif && H.nif.flag_check(NIF_V_FLASHPROT,NIF_FLAGS_VISION))
			flashfail = 1
			H.nif.notify("High intensity light detected, and blocked!",TRUE)

	if(iscarbon(M) && !flashfail)
		var/mob/living/carbon/C = M
		if(C.stat != DEAD)
			var/safety = C.eyecheck()
			if(safety <= 0)
				var/flash_strength = 10
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					flash_strength *= H.species.flash_mod

					if(flash_strength > 0)
						H.Confuse(flash_strength + 5)
						H.afflict_stagger(FLASH_TRAIT, stagger_strength, stagger_duration)
						H.apply_status_effect(/datum/status_effect/sight/blindness, flash_strength SECONDS)
						H.eye_blurry = max(H.eye_blurry, flash_strength + 5)
						H.flash_eyes()
						H.adjustHalLoss(halloss_per_flash * (flash_strength / 5)) // Should take four flashes to stun.
						H.apply_damage(10 * (H.species.flash_burn / 5), DAMAGE_TYPE_BURN, BP_HEAD, 0, 0, "Photon burns")

			else
				flashfail = 1

	else if(issilicon(M))
		flashfail = 0
		var/mob/living/silicon/S = M
		if(isrobot(S))
			var/mob/living/silicon/robot/R = S
			if(R.has_active_type(/obj/item/borg/combat/shield))
				var/obj/item/borg/combat/shield/shield = locate() in R
				if(shield)
					if(shield.active)
						shield.adjust_flash_count(R, 1)
						flashfail = 1
	else
		flashfail = 1

	if(isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)

	if(!flashfail)
		flick("flash2", src)
		if(!issilicon(M))
			user.visible_message("<span class='disarm'>[user] blinds [M] with the flash!</span>")
		else
			user.visible_message("<span class='notice'>[user] overloads [M]'s sensors with the flash!</span>")
			M.afflict_paralyze(20 * rand(5,10))
	else
		user.visible_message("<span class='notice'>[user] fails to blind [M] with the flash!</span>")

/obj/item/flash/attack_self(mob/user, datum/event_args/actor/actor)
	if(!user || !clown_check(user))
		return

	user.setClickCooldownLegacy(user.get_attack_speed_legacy(src))

	if(broken)
		user.show_message("<span class='warning'>The [src.name] is broken</span>", 2)
		return

	flash_recharge()

	if(!check_capacitor(user))
		return

	playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("flash2", src)
	if(user && isrobot(user))
		spawn(0)
			var/atom/movable/overlay/animation = new(user.loc)
			animation.layer = user.layer + 1
			animation.icon_state = "blank"
			animation.icon = 'icons/mob/mob.dmi'
			animation.master = user
			flick("blspell", animation)
			sleep(5)
			qdel(animation)

	for(var/mob/living/carbon/C in oviewers(3, null))
		var/safety = C.eyecheck()
		if(!safety)
			if(!C.has_status_effect(/datum/status_effect/sight/blindness))
				C.flash_eyes()

	return

/obj/item/flash/emp_act(severity)
	if(broken)	return
	flash_recharge()
	if(!check_capacitor())
		return

	if(istype(loc, /mob/living/carbon))
		var/mob/living/carbon/C = loc
		var/safety = C.eyecheck()
		if(safety <= 0)
			C.adjustHalLoss(halloss_per_flash)
			//C.afflict_paralyze(20 * 10)
			C.flash_eyes()
			for(var/mob/M in viewers(C, null))
				M.show_message("<span class='disarm'>[C] is blinded by the flash!</span>")
	..()

/obj/item/flash/synthetic
	name = "synthetic flash"
	desc = "When a problem arises, SCIENCE is the solution."
	icon_state = "sflash"
	origin_tech = list(TECH_MAGNET = 2, TECH_COMBAT = 1)
	base_icon = "sflash"
	can_repair = FALSE

//attack_as_weapon
/obj/item/flash/synthetic/attack_mob(mob/target, mob/user, clickchain_flags, list/params, mult, target_zone, intent)
	. = ..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		update_icon()

/obj/item/flash/synthetic/attack_self(mob/user, datum/event_args/actor/actor)
	..()
	if(!broken)
		broken = 1
		to_chat(user, "<span class='warning'>The bulb has burnt out!</span>")
		update_icon()

/obj/item/flash/robot
	name = "mounted flash"
	can_break = FALSE
	use_external_power = TRUE
	charge_only = TRUE
