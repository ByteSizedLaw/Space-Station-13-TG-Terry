/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "lockbox+l"
	inhand_icon_state = "lockbox"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	req_access = list(ACCESS_ARMORY)
	storage_type = /datum/storage/lockbox

	var/broken = FALSE
	var/open = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_open = "lockbox"
	var/icon_broken = "lockbox+b"

/obj/item/storage/lockbox/Initialize(mapload)
	. = ..()

	atom_storage.locked = STORAGE_FULLY_LOCKED

	register_context()

	update_appearance()

///screentips for lockboxes
/obj/item/storage/lockbox/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!held_item)
		return NONE
	if(src.broken)
		return NONE
	if(!held_item.GetID())
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = atom_storage.locked ? "Unlock with ID" : "Lock with ID"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/lockbox/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/card/card = tool.GetID()
	if(isnull(card))
		return ..()

	if(can_unlock(user, card))
		toggle_locked(user)
		return ITEM_INTERACT_SUCCESS

	return ITEM_INTERACT_BLOCKING

/obj/item/storage/lockbox/proc/can_unlock(mob/living/user, obj/item/card/id/id_card, silent = FALSE)
	if(check_access(id_card))
		return TRUE
	if(!silent)
		balloon_alert(user, "access denied!")
	return FALSE

/obj/item/storage/lockbox/proc/toggle_locked(mob/living/user)
	if(atom_storage.locked)
		atom_storage.locked = STORAGE_NOT_LOCKED
	else
		atom_storage.locked = STORAGE_FULLY_LOCKED
		atom_storage.close_all()
	balloon_alert(user, atom_storage.locked ? "locked" : "unlocked")
	update_appearance()

/obj/item/storage/lockbox/update_icon_state()
	. = ..()
	if(broken)
		icon_state = icon_broken
	else if(atom_storage?.locked)
		icon_state = icon_locked
	else if(open)
		icon_state = icon_open
	else
		icon_state = icon_closed

/obj/item/storage/lockbox/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(!broken)
		broken = TRUE
		atom_storage.locked = STORAGE_NOT_LOCKED
		balloon_alert(user, "lock destroyed")
		if (emag_card && user)
			user.visible_message(span_warning("[user] swipes [emag_card] over [src], breaking it!"))
		update_appearance()
		return TRUE
	return FALSE

/obj/item/storage/lockbox/examine(mob/user)
	. = ..()
	if(broken)
		. += span_notice("It appears to be broken.")

/obj/item/storage/lockbox/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	open = TRUE
	update_appearance()

/obj/item/storage/lockbox/Exited(atom/movable/gone, direction)
	. = ..()
	open = TRUE
	update_appearance()

/obj/item/storage/lockbox/loyalty
	name = "lockbox of mindshield implants"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/loyalty/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/implantcase/mindshield
	. += /obj/item/implanter/mindshield

/obj/item/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/clusterbang/PopulateContents()
	return  /obj/item/grenade/clusterbuster

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"
	icon_open = "medalboxopen"
	storage_type = /datum/storage/lockbox/medal

/obj/item/storage/lockbox/medal/examine(mob/user)
	. = ..()
	if(!atom_storage.locked)
		. += span_notice("Alt-click to [open ? "close":"open"] it.")

/obj/item/storage/lockbox/medal/click_alt(mob/user)
	if(!atom_storage.locked)
		open = !open
		update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/storage/lockbox/medal/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/clothing/accessory/medal/gold/captain = 1,
		/obj/item/clothing/accessory/medal/silver/valor = 2,
		/obj/item/clothing/accessory/medal/silver/security = 1,
		/obj/item/clothing/accessory/medal/bronze_heart = 1,
		/obj/item/clothing/accessory/medal/plasma/nobel_science = 2,
		/obj/item/clothing/accessory/medal/conduct = 3,
	))

/obj/item/storage/lockbox/medal/update_overlays()
	. = ..()
	if(!contents || !open)
		return
	if(atom_storage?.locked)
		return
	for(var/i in 1 to contents.len)
		var/obj/item/clothing/accessory/medal/M = contents[i]
		var/mutable_appearance/medalicon = mutable_appearance(initial(icon), M.medaltype)
		if(i > 1 && i <= 5)
			medalicon.pixel_w += ((i-1)*3)
		else if(i > 5)
			medalicon.pixel_z -= 7
			medalicon.pixel_w -= 2
			medalicon.pixel_w += ((i-6)*3)
		. += medalicon

/obj/item/storage/lockbox/medal/hop
	name = "Head of Personnel medal box"
	desc = "A locked box used to store medals to be given to those exhibiting excellence in management."
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/medal/hop/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/clothing/accessory/medal/silver/bureaucracy
	. += /obj/item/clothing/accessory/medal/gold/ordom

/obj/item/storage/lockbox/medal/sec
	name = "security medal box"
	desc = "A locked box used to store medals to be given to members of the security department."
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/medal/med
	name = "medical medal box"
	desc = "A locked box used to store medals to be given to members of the medical department."
	req_access = list(ACCESS_CMO)

/obj/item/storage/lockbox/medal/med/PopulateContents()
	return flatten_quantified_list(list(
		/obj/item/clothing/accessory/medal/med_medal = 1,
		/obj/item/clothing/accessory/medal/med_medal2 = 1,
		/obj/item/clothing/accessory/medal/silver/emergency_services/medical = 3,
	))

/obj/item/storage/lockbox/medal/sec/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/clothing/accessory/medal/silver/security

/obj/item/storage/lockbox/medal/cargo
	name = "cargo award box"
	desc = "A locked box used to store awards to be given to members of the cargo department."
	req_access = list(ACCESS_QM)

/obj/item/storage/lockbox/medal/cargo/PopulateContents()
	return  /obj/item/clothing/accessory/medal/ribbon/cargo

/obj/item/storage/lockbox/medal/service
	name = "service award box"
	desc = "A locked box used to store awards to be given to members of the service department."
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/medal/service/PopulateContents()
	return /obj/item/clothing/accessory/medal/silver/excellence

/obj/item/storage/lockbox/medal/sci
	name = "science medal box"
	desc = "A locked box used to store medals to be given to members of the science department."
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/medal/sci/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/clothing/accessory/medal/plasma/nobel_science

/obj/item/storage/lockbox/medal/engineering
	name = "engineering medal box"
	desc = "A locked box used to store awards to be given to members of the engineering department."
	req_access = list(ACCESS_CE)

/obj/item/storage/lockbox/medal/engineering/PopulateContents()
	. = list()
	for(var/i in 1 to 3)
		. += /obj/item/clothing/accessory/medal/silver/emergency_services/engineering
	. += /obj/item/clothing/accessory/medal/silver/elder_atmosian

/obj/item/storage/lockbox/order
	name = "order lockbox"
	desc = "A box used to secure small cargo orders from being looted by those who didn't order it. Yeah, cargo tech, that means you."
	icon_state = "secure"
	icon_closed = "secure"
	icon_locked = "secure_locked"
	icon_broken = "secure_locked"
	icon_open = "secure"
	inhand_icon_state = "sec-case"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE

	///The bank account of the mob who purchased this lockbox
	var/datum/bank_account/buyer_account

/obj/item/storage/lockbox/order/Initialize(mapload, datum/bank_account/_buyer_account)
	. = ..()
	buyer_account = _buyer_account
	ADD_TRAIT(src, TRAIT_NO_MISSING_ITEM_ERROR, TRAIT_GENERIC)
	ADD_TRAIT(src, TRAIT_NO_MANIFEST_CONTENTS_ERROR, TRAIT_GENERIC)

/obj/item/storage/lockbox/order/can_unlock(mob/living/user, obj/item/card/id/id_card, silent = FALSE)
	if(id_card.registered_account == buyer_account)
		return TRUE
	if(!silent)
		balloon_alert(user, "incorrect bank account!")
	return FALSE

//Storage case.
/obj/item/storage/lockbox/dueling
	name = "dueling pistol case"
	desc = "Let's solve this like gentlespacemen."
	icon_state = "medalbox+l"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"
	base_icon_state = "medalbox"
	icon_open = "medalboxopen"
	storage_type = /datum/storage/lockbox/dueling

/obj/item/storage/lockbox/dueling/PopulateContents()
	var/obj/item/gun/energy/dueling/gun_A = new(null)
	var/obj/item/gun/energy/dueling/gun_B = new(null)
	new /datum/duel(gun_A, gun_B)
