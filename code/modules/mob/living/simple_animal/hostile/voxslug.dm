/*SLUG
Small, little HP, poisonous.
*/

/mob/living/simple_animal/hostile/slug
	name = "slug"
	desc = "A viscious little creature, it has a mouth of too many teeth and a penchant for blood."
	icon_state = "slug"
	icon_living = "slug"
	item_state = "slug"
	icon_dead = "slug_dead"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	destroy_surroundings = 0
	health = 15
	maxHealth = 15
	speed = 0
	move_to_delay = 0
	density = 1
	min_gas = null
	mob_size = MOB_MINISCULE
	can_escape = TRUE
	pass_flags = PASS_FLAG_TABLE
	melee_damage_lower = 5
	melee_damage_upper = 10
	melee_damage_flags = DAM_SHARP
	holder_type = /obj/item/weapon/holder/slug
	faction = "angryslugs"

/mob/living/simple_animal/hostile/slug/ListTargets(var/dist = 7)
	var/list/L = list()
	for(var/a in hearers(src, dist))
		if(isliving(a))
			var/mob/living/M = a
			if(M.faction == faction)
				continue
		L += a

	return L

/mob/living/simple_animal/hostile/slug/get_scooped(var/mob/living/carbon/grabber)
	to_chat(grabber, "<span class='warning'>\The [src] wriggles out of your hands before you can pick it up!</span>")

/mob/living/simple_animal/hostile/slug/proc/attach(var/mob/living/carbon/human/H)
	var/obj/item/clothing/suit/space/S = H.get_covering_equipped_item_by_zone(BP_CHEST)
	if(istype(S) && !length(S.breaches))
		S.create_breaches(BRUTE, 20)
		if(!length(S.breaches)) //unable to make a hole
			return
	var/obj/item/organ/external/chest = H.organs_by_name[BP_CHEST]
	var/obj/item/weapon/holder/slug/holder = new(get_turf(src))
	src.forceMove(holder)
	chest.embed(holder,0,"\The [src] latches itself onto \the [H]!")
	holder.sync(src)

/mob/living/simple_animal/hostile/slug/AttackingTarget()
	. = ..()
	if(istype(., /mob/living/carbon/human))
		var/mob/living/carbon/human/H = .
		if(prob(H.getBruteLoss()/2))
			attach(H)

/mob/living/simple_animal/hostile/slug/Life()
	. = ..()
	if(. && istype(src.loc, /obj/item/weapon/holder) && isliving(src.loc.loc)) //We in somebody
		var/mob/living/L = src.loc.loc
		if(src.loc in L.get_visible_implants(0))
			if(prob(1))
				to_chat(L, "<span class='warning'>You feel strange as \the [src] pulses...</span>")
			var/datum/reagents/R = L.reagents
			R.add_reagent(/datum/reagent/cryptobiolin, 0.5)

/obj/item/weapon/holder/slug/attack(var/mob/target, var/mob/user)
	var/mob/living/simple_animal/hostile/slug/V = contents[1]
	if(!V.stat && istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(!do_after(user, 3 SECONDS, H))
			return
		V.attach(H)
		qdel(src)
		return
	..()