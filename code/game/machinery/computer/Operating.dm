#define OP_COMPUTER_COOLDOWN 60

/obj/machinery/computer/operating
	name = "patient monitoring console"
	density = TRUE
	anchored = TRUE
	icon_keyboard = "med_key"
	icon_screen = "crew"
	circuit = /obj/item/circuitboard/operating
	var/obj/machinery/optable/table = null
	var/mob/living/carbon/human/victim = null
	///General speaker toggle.
	var/verbose = TRUE
	///Healther announcer toggle
	var/healthAnnounce = TRUE
	///Health at which the computer will beep.
	var/healthAlarm = 50
	///Crit beeping toggle
	var/crit = TRUE
	///Oxygen beeping toggle
	var/oxy = TRUE
	///Oxy damage at which the computer will beep.
	var/oxyAlarm = 30
	///The name of our vic- I mean patient.
	var/patientName = null
	///Just for going into and out of the options menu
	var/choice = FALSE
	var/nextTick = OP_COMPUTER_COOLDOWN

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	for(var/direction in ALL_CARDINALS)
		table = locate(/obj/machinery/optable, get_step(src, direction))
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/Destroy()
	if(table)
		table.computer = null
		table = null
	if(victim)
		victim = null
	return ..()

/obj/machinery/computer/operating/attack_ai(mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)

/obj/machinery/computer/operating/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	ui_interact(user)
	..()

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", "Patient Monitor")
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user, datum/tgui/ui)
	var/data[0]
	var/mob/living/carbon/human/occupant
	if(!table)
		data["table"] = 0
	else
		data["table"] = 1
		occupant = table.victim
	data["hasOccupant"] = occupant ? 1 : 0
	var/occupantData[0]

	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = occupant.getMinHealth()
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["paralysis"] = round(occupant.is_unconscious()?.time_left() / 10) / 2
		occupantData["hasBlood"] = 0
		occupantData["bodyTemperature"] = occupant.bodytemperature
		occupantData["maxTemp"] = 1000 // If you get a burning vox armalis into the sleeper, congratulations
		// Because we can put simple_animals in here, we need to do something tricky to get things working nice
		occupantData["temperatureSuitability"] = 0 // 0 is the baseline
		if(ishuman(occupant) && occupant.species)
			// I wanna do something where the bar gets bluer as the temperature gets lower
			// For now, I'll just use the standard format for the temperature status
			var/datum/species/sp = occupant.species
			if(occupant.bodytemperature < sp.cold_level_3)
				occupantData["temperatureSuitability"] = -3
			else if(occupant.bodytemperature < sp.cold_level_2)
				occupantData["temperatureSuitability"] = -2
			else if(occupant.bodytemperature < sp.cold_level_1)
				occupantData["temperatureSuitability"] = -1
			else if(occupant.bodytemperature > sp.heat_level_3)
				occupantData["temperatureSuitability"] = 3
			else if(occupant.bodytemperature > sp.heat_level_2)
				occupantData["temperatureSuitability"] = 2
			else if(occupant.bodytemperature > sp.heat_level_1)
				occupantData["temperatureSuitability"] = 1
		else if(isanimal(occupant))
			var/mob/living/simple_mob/silly = occupant
			if(silly.bodytemperature < silly.minbodytemp)
				occupantData["temperatureSuitability"] = -3
			else if(silly.bodytemperature > silly.maxbodytemp)
				occupantData["temperatureSuitability"] = 3
		// Blast you, imperial measurement system
		occupantData["btCelsius"] = occupant.bodytemperature - T0C
		occupantData["btFaren"] = ((occupant.bodytemperature - T0C) * (9.0/5.0))+ 32

		if(ishuman(occupant) && !(NO_BLOOD in occupant.species.species_flags) && occupant.blood_holder)
			occupantData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			occupantData["hasBlood"] = 1
			var/blood_volume = round(occupant.blood_holder.get_total_volume())
			occupantData["bloodLevel"] = blood_volume
			occupantData["bloodMax"] = occupant.species.blood_volume
			occupantData["bloodPercent"] = round(100*(blood_volume/occupant.species.blood_volume), 0.01) //copy pasta ends here

			occupantData["bloodType"] = occupant.dna.b_type
			occupantData["procedures"] = build_surgery_list(user)

	data["patient"] = occupantData
	data["verbose"]=verbose
	data["oxyAlarm"]=oxyAlarm
	data["choice"]=choice
	data["health"]=healthAnnounce
	data["crit"]=crit
	data["healthAlarm"]=healthAlarm
	data["oxy"]=oxy

	return data

/obj/machinery/computer/operating/ui_act(action, list/params, datum/tgui/ui)
	if(..())
		return TRUE
	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	. = TRUE
	switch(action)
		if("verboseOn")
			verbose = TRUE
		if("verboseOff")
			verbose = FALSE
		if("healthOn")
			healthAnnounce = TRUE
		if("healthOff")
			healthAnnounce = FALSE
		if("critOn")
			crit = TRUE
		if("critOff")
			crit = FALSE
		if("oxyOn")
			oxy = TRUE
		if("oxyOff")
			oxy = FALSE
		if("oxy_adj")
			oxyAlarm = clamp(text2num(params["new"]), -100, 100)
		if("choiceOn")
			choice = TRUE
		if("choiceOff")
			choice = FALSE
		if("health_adj")
			healthAlarm = clamp(text2num(params["new"]), -100, 100)
		else
			return FALSE

/obj/machinery/computer/operating/process(delta_time)
	if(table && table.check_victim())
		if(verbose)
			if(patientName!=table.victim.name)
				patientName=table.victim.name
				atom_say("New patient detected, loading stats")
				victim = table.victim
				atom_say("[victim.real_name], [victim.dna.b_type] blood, [victim.stat ? "Non-Responsive" : "Awake"]")
				SStgui.update_uis(src)
			if(nextTick < world.time)
				nextTick=world.time + OP_COMPUTER_COOLDOWN
				if(crit && victim.health <= -50 )
					playsound(src.loc, 'sound/machines/defib_success.ogg', 50, 0)
				if(oxy && victim.getOxyLoss()>oxyAlarm)
					playsound(src.loc, 'sound/machines/defib_safetyOff.ogg', 50, 0)
				if(healthAnnounce && ((victim.health / victim.maxHealth) * 100) <= healthAlarm)
					atom_say("[round(((victim.health / victim.maxHealth) * 100))]% health.")

// Surgery Helpers
/obj/machinery/computer/operating/proc/build_surgery_list(mob/user)
	if(!istype(victim))
		return null

	. = list()

	for(var/limb in victim.organs_by_name)
		var/obj/item/organ/external/E = victim.organs_by_name[limb]
		if(E && E.open)
			. += list(list("name" = E.name, "currentStage" = find_stage(E), "nextSteps" = find_next_steps(user, limb)))

/**
 * This proc is actually hell. I hate the surgery system Polaris uses.
 * Basically, surgery is completely stateless, and what "stage" we're on is just dependent
 * on the current state of 5 separate variables that determine what stages we can perform
 * next.
 *
 * So, here's a little guide to understand this proc:
 * Surgery is broken down into 5 different variables:
 *		`open`,
 *		`stage`,
 *		`cavity`,
 *		`burn_stage`,
 *		and `brute_stage`.
 * Naturally, the values assigned to these don't use defines or names or anything, they're just magic numbers.
 * So, we have to figure out ourselves what we should call each value.
 * Open can be 4 values, and represents the "openness" of the surgery site.
 *		1 = Cut Open.
 *		2 = Retracted.
 *		2.5 = Bones cut.
 *		3 = Bones spread.
 * Stage can be 3 values, and represents the progress in fixing broken bones
 *		0 = Closed, can be either "we're done" or "we haven't started" FFS.
 *		1 = Bones glued.
 *		2 = Bones set.
 * Cavity is just representing the cavity implant surgeries, and can be 2 values.
 *		0 = Cavity Closed
 *		1 = Cavity Open
 * burn_stage and brute_stage are literally only used for repairing brute/burn damage to limbs
 * I have no idea why you would ever perform these surgeries, given that Bicaradine and Kelotane exist.
 * So I'm not even going to bother trying to represent them here. Fuck it.
 */
/obj/machinery/computer/operating/proc/find_stage(var/obj/item/organ/external/E)
	. = "None."
	switch(E.open)
		if(1)
			. = "Incision made."
		if(2)
			. = "Surgical site opened."
			switch(E.stage)
				// if(0) // Nothing.
				if(1)
					. = "Surgical site opened; Bones glued."
				if(2)
					. = "Surgical site opened; Bones set."
			switch(E.cavity)
				if(1)
					. = "Surgical site opened; Cavity open."
		if(2.5) // WHY IS THIS A FLOAT. WHY?
			. = "Bones cut."
			switch(E.stage)
				// if(0) // Nothing.
				if(1)
					. = "Bones cut; Bones glued."
				if(2)
					. = "Bones cut; Bones set."
		if(3)
			. = "Bones retracted."
			switch(E.stage)
				// if(0) // Nothing.
				if(1)
					. = "Bones retracted; Bones glued."
				if(2)
					. = "Bones retracted; Bones reset."
			switch(E.cavity)
				if(1)
					. = "Bones retracted; Cavity open."

/**
 * This converts a typepath into a pretty name.
 * As best as it can, anyways.
 */
/proc/pretty_type(var/datum/A)
	var/typeStr = "[A.type]"
	. = copytext(typeStr, findlasttext(typeStr, "/") + 1, length(typeStr) + 1)
	. = capitalize(replacetext(., "_", " "))

/proc/get_surgery_steps_without_basetypes()
	var/static/list/good_surgeries = list()
	if(LAZYLEN(good_surgeries))
		return good_surgeries
	var/static/list/banned_surgery_steps = list(
			/datum/surgery_step,
			/datum/surgery_step/generic,
			/datum/surgery_step/open_encased,
			/datum/surgery_step/repairflesh,
			/datum/surgery_step/face,
			/datum/surgery_step/cavity,
			/datum/surgery_step/limb,
			/datum/surgery_step/brainstem,
		)
	good_surgeries = GLOB.surgery_steps
	for(var/datum/surgery_step/S in good_surgeries)
		if(S.type in banned_surgery_steps)
			good_surgeries -= S
		if(!LAZYLEN(S.allowed_tools))
			good_surgeries -= S
	return good_surgeries

/**
 * Funnily enough, this proc is actually considerably less awful than find_stage.
 * All we have to do is check what surgeries can be done, like surgery mechanics themselves do.
 * Then, build a string telling the user what they can do next.
 */
/obj/machinery/computer/operating/proc/find_next_steps(mob/user, zone)
	. = list()
	var/list/possible_next_steps = get_surgery_steps_without_basetypes()
	// these steps prompt the player in can_use, don't call them every ui update
	var/list/prompting_surgery_steps = list(
			/datum/surgery_step/internal/detatch_organ,
			/datum/surgery_step/internal/remove_organ,
			/datum/surgery_step/internal/attach_organ,
			/datum/surgery_step/internal/rip_organ,
			/datum/surgery_step/robotics/detatch_organ_robotic,
			/datum/surgery_step/robotics/attach_organ_robotic,
		)
	for(var/datum/surgery_step/S in possible_next_steps)
		if (S.type in prompting_surgery_steps)
			continue
		if(S.can_use(user, victim, zone, null) && S.is_valid_target(victim))
			var/allowed_tools_by_name = list()
			for(var/tool in S.allowed_tools)
				// Exempt ghetto tools.
				if(S.allowed_tools[tool] < 100)
					continue
				var/obj/tool_path = tool
				allowed_tools_by_name += capitalize(initial(tool_path.name))
			. += list(S.step_name = english_list(allowed_tools_by_name))
