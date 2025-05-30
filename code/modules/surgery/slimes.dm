//////////////////////////////////////////////////////////////////
//				SLIME CORE EXTRACTION							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/slime
	is_valid_target(mob/living/simple_mob/slime/target)
		return istype(target, /mob/living/simple_mob/slime/)

/datum/surgery_step/slime/can_use(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	return target.stat == 2



/datum/surgery_step/slime/cut_flesh
	step_name = "Incise"
	allowed_tools = list(
	/obj/item/surgical/scalpel = 100,
	/obj/item/surgical/scalpel_bronze = 90,
	/obj/item/surgical/scalpel_primitive = 80,
	/obj/item/material/knife = 75,
	/obj/item/material/shard = 50,
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_flesh/can_use(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	return ..() && istype(target) && target.core_removal_stage == 0

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting through [target]'s flesh with \the [tool].", \
	"You start cutting through [target]'s flesh with \the [tool].")

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] cuts through [target]'s flesh with \the [tool].</font>",	\
	"<font color=#4F49AF>You cut through [target]'s flesh with \the [tool], revealing its silky innards.</font>")
	target.core_removal_stage = 1

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("<font color='red'>[user]'s hand slips, tearing [target]'s flesh with \the [tool]!</font>", \
	"<font color='red'>Your hand slips, tearing [target]'s flesh with \the [tool]!</font>")



/datum/surgery_step/slime/cut_innards
	step_name = "Expose core"

	allowed_tools = list(
	/obj/item/surgical/scalpel = 100,		\
	/obj/item/surgical/scalpel_bronze = 90,	\
	/obj/item/surgical/scalpel_primitive = 80,	\
	/obj/item/material/knife = 75,	\
	/obj/item/material/shard = 50, 		\
	)

	min_duration = 30
	max_duration = 50

/datum/surgery_step/slime/cut_innards/can_use(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	return ..() && istype(target) && target.core_removal_stage == 1

/datum/surgery_step/slime/cut_innards/begin_step(mob/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting [target]'s silky innards apart with \the [tool].", \
	"You start cutting [target]'s silky innards apart with \the [tool].")

/datum/surgery_step/slime/cut_innards/end_step(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("<font color=#4F49AF>[user] cuts [target]'s innards apart with \the [tool], exposing the cores.</font>",	\
	"<font color=#4F49AF>You cut [target]'s innards apart with \the [tool], exposing the cores.</font>")
	target.core_removal_stage = 2

/datum/surgery_step/slime/cut_innards/fail_step(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("<font color='red'>[user]'s hand slips, tearing [target]'s innards with \the [tool]!</font>", \
	"<font color='red'>Your hand slips, tearing [target]'s innards with \the [tool]!</font>")



/datum/surgery_step/slime/saw_core
	step_name = "Extract core"

	allowed_tools = list(
	/obj/item/surgical/circular_saw = 100, \
	/obj/item/surgical/saw_bronze = 90, \
	/obj/item/surgical/saw_primitive = 80, \
	/obj/item/material/knife/machete/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/slime/saw_core/can_use(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	return ..() && (istype(target) && target.core_removal_stage == 2 && target.cores > 0) //This is being passed a human as target, unsure why.

/datum/surgery_step/slime/saw_core/begin_step(mob/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts cutting out one of [target]'s cores with \the [tool].", \
	"You start cutting out one of [target]'s cores with \the [tool].")

/datum/surgery_step/slime/saw_core/end_step(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	target.cores--
	user.visible_message("<font color=#4F49AF>[user] cuts out one of [target]'s cores with \the [tool].</font>",,	\
	"<font color=#4F49AF>You cut out one of [target]'s cores with \the [tool]. [target.cores] cores left.</font>")

	if(target.cores >= 0)
		new target.coretype(target.loc)
	if(target.cores <= 0)
		target.icon_state = "slime extracted"


/datum/surgery_step/slime/saw_core/fail_step(mob/living/user, mob/living/simple_mob/slime/target, target_zone, obj/item/tool)
	var/datum/gender/T = GLOB.gender_datums[user.get_visible_gender()]
	user.visible_message("<font color='red'>[user]'s hand slips, causing [T.him] to miss the core!</font>", \
	"<font color='red'>Your hand slips, causing you to miss the core!</font>")
