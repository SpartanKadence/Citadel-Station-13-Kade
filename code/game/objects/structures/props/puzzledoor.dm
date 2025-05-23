// An indestructible blast door that can only be opened once its puzzle requirements are completed.

/obj/machinery/door/blast/puzzle
	name = "puzzle door"
	desc = "A large, virtually indestructible door that will not open unless certain requirements are met."
	icon_state_open = "pdoor0"
	icon_state_opening = "pdoorc0"
	icon_state_closed = "pdoor1"
	icon_state_closing = "pdoorc1"
	icon_state = "pdoor1"

	explosion_resistance = 100

	integrity_flags = INTEGRITY_INDESTRUCTIBLE

	var/list/locks = list()
	var/lockID = null
	var/checkrange_mult = 1

/obj/machinery/door/blast/puzzle/proc/check_locks()
	if(!locks || locks.len <= 0)	// Puzzle doors with no locks will only listen to boring buttons.
		return 0

	for(var/obj/structure/prop/lock/L in locks)
		if(!L.enabled)
			return 0
	return 1

/obj/machinery/door/blast/puzzle/on_bullet_act(obj/projectile/proj, impact_flags, list/bullet_act_args)
	impact_flags &= ~PROJECTILE_IMPACT_FLAGS_SHOULD_GO_THROUGH
	return ..()

/obj/machinery/door/blast/puzzle/legacy_ex_act(severity)
	visible_message("<span class='cult'>\The [src] is completely unaffected by the blast.</span>")
	return

/obj/machinery/door/blast/puzzle/Initialize(mapload)
	. = ..()
	implicit_material = RSmaterials.fetch_local_or_throw(/datum/prototype/material/alienalloy/dungeonium)
	if(locks.len)
		return
	var/check_range = world.view * checkrange_mult
	for(var/obj/structure/prop/lock/L in orange(src, check_range))
		if(L.lockID == lockID)
			L.linked_objects |= src
			locks |= L

/obj/machinery/door/blast/puzzle/Destroy()
	if(locks.len)
		for(var/obj/structure/prop/lock/L in locks)
			L.linked_objects -= src
			locks -= L
	..()

/obj/machinery/door/blast/puzzle/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(check_locks())
		force_toggle(1, user)
	else
		to_chat(user, "<span class='notice'>\The [src] does not respond to your touch.</span>")

/obj/machinery/door/blast/puzzle/attackby(obj/item/C as obj, mob/user as mob)
	if(istype(C, /obj/item))
		if(C.pry == 1 && (user.a_intent != INTENT_HARM || (machine_stat & BROKEN)))
			if(check_locks())
				force_toggle(1, user)
			else
				to_chat(user, "<span class='notice'>[src]'s arcane workings resist your effort.</span>")
			return

		else if(src.density && (user.a_intent == INTENT_HARM))
			var/obj/item/W = C
			user.setClickCooldownLegacy(user.get_attack_speed_legacy(W))
			if(W.damage_type == DAMAGE_TYPE_BRUTE || W.damage_type == DAMAGE_TYPE_BURN)
				user.do_attack_animation(src)
				user.visible_message("<span class='danger'>\The [user] hits \the [src] with \the [W] with no visible effect.</span>")

		else if(istype(C, /obj/item/plastique))
			to_chat(user, "<span class='danger'>On contacting \the [src], a flash of light envelops \the [C] as it is turned to ash. Oh.</span>")
			qdel(C)
			return 0

/obj/machinery/door/blast/puzzle/attack_generic(var/mob/user, var/damage)
	if(check_locks())
		force_toggle(1, user)

/obj/machinery/door/blast/puzzle/attack_alien(var/mob/user)
	if(check_locks())
		force_toggle(1, user)
