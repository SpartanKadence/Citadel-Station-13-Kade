/obj/item/clothing/head/helmet/space/void/science
	name = "hazard bypass helmet"
<<<<<<< HEAD
	desc = "A special helmet designed for the immense pressures, heat, cold, and anomlous natures that may be thrown at a scientist."
=======
	desc = "A special helmet designed for the immense pressures, heat, cold, and anomalous natures that may be thrown at a scientist."
>>>>>>> 79eb113fa483ad51b06ac271fe037bad778aa2eb
	icon_state = "phase"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "sec_helm", SLOT_ID_LEFT_HAND = "sec_helm")
	armor_type = /datum/armor/science/phase
	siemens_coefficient = 0.7
<<<<<<< HEAD
	max_heat_protection_temperature = 5000
	min_pressure_protection = 0 * ONE_ATMOSPHERE
	max_pressure_protection = 20* ONE_ATMOSPHERE

/obj/item/clothing/suit/space/void/science
	name = "hazard bypass voidsuit"
	desc = "A special suit designed for the immense pressures, heat, cold, and anomlous natures that may be thrown at a scientist."
=======
	max_heat_protection_temperature = 10000
	min_pressure_protection = 0 * ONE_ATMOSPHERE
	max_pressure_protection = 20* ONE_ATMOSPHERE
	worth_intrinsic = 159
	integrity_flags = INTEGRITY_ACIDPROOF

/obj/item/clothing/suit/space/void/science
	name = "hazard bypass voidsuit"
	desc = "A special suit designed for the immense pressures, heat, cold, and anomalous natures that may be thrown at a scientist."
>>>>>>> 79eb113fa483ad51b06ac271fe037bad778aa2eb
	icon_state = "phase"
	item_state_slots = list(SLOT_ID_RIGHT_HAND = "sec_voidsuit", SLOT_ID_LEFT_HAND = "sec_voidsuit")
	armor_type = /datum/armor/science/phase
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank,/obj/item/suit_cooling_unit,/obj/item/melee/baton)
	siemens_coefficient = 0.7
<<<<<<< HEAD
	max_heat_protection_temperature = 5000
	min_pressure_protection = 0 * ONE_ATMOSPHERE
	max_pressure_protection = 20* ONE_ATMOSPHERE
	encumbrance = 60
	helmet_type = /obj/item/clothing/head/helmet/space/void/science


=======
	max_heat_protection_temperature = 10000
	min_pressure_protection = 0 * ONE_ATMOSPHERE
	max_pressure_protection = 20* ONE_ATMOSPHERE
	integrity_flags = INTEGRITY_ACIDPROOF
	encumbrance = 55
	worth_intrinsic = 350
	helmet_type = /obj/item/clothing/head/helmet/space/void/science
>>>>>>> 79eb113fa483ad51b06ac271fe037bad778aa2eb
