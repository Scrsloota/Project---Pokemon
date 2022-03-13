extends Node

func _ready():
	pass # Replace with function body.

func get_player_bag():
	return get_node("/root/Game/Party").get_children()
	
func get_player():
	return get_node("/root/Game/SceneManager").get_player()
	
func get_inventory():
	return get_node("/root/Game").get_inventory()

static func save_item(obj: Item):
	var item = {
		'icon': obj.icon.resource_path,
		'name': obj.name,
		'description': obj.description,
		'unique': obj.unique,
		'sell_price': obj.sell_price,
		'buy_price': obj.buy_price,
		'script': obj.get_script().resource_path
	}
	if obj is RecoveryHP:
		item['type'] = 'RecoveryHP'
		item['healing_value'] = obj.healing_value
	elif obj is RecoveryPP:
		item['type'] = 'RecoveryPP'
	elif obj is PokemonBall:
		item['type'] = 'PokemonBall'
		item['success_rate'] = obj.success_rate
	else:
		assert(false==true)
	return item
	
static func load_item(dict):
	var new_item
	match dict['type']:
		'RecoveryHP':
			new_item = RecoveryHP.new()
			new_item.healing_value = dict['healing_value']
		'RecoveryPP':
			new_item = RecoveryPP.new()
		'PokemonBall':
			new_item = PokemonBall.new()
			new_item.success_rate = dict['success_rate']
		_:
			assert(false==true)
	new_item.icon = load(dict['icon'])
	new_item.name = dict['name']
	new_item.description = dict['description']
	new_item.unique = dict['unique']
	new_item.sell_price = dict['sell_price']
	new_item.buy_price = dict['buy_price']
	new_item.set_script(load(dict['script']))
	return new_item

static func save_stats(obj: CharacterStats):
	var learned_skills = []
	for port_skill in obj.learned_skills:
		learned_skills.append(save_portable_skill(port_skill))
		
	return {
		'growth_stats': obj.growth_stats.resource_path,
		'individual_stats': obj.individual_stats.resource_path,
		'learned_skills': learned_skills,
		
		'modifiers': obj.modifiers,
		'level':obj.level,
		'tot_experience': obj.tot_experience,
		'text_name': obj.text_name,
		'pokemon_name': obj.pokemon_name,

		'health': obj.health,
		'max_health': obj.max_health,
		'strength': obj.strength,
		'defense': obj.defense,
		'spec_strength': obj.spec_strength,
		'spec_defense': obj.spec_defense,
		'speed': obj.speed,

		'primary_type': obj.primary_type,
		'secondary_type': obj.secondary_type,

		'is_alive': obj.is_alive ,

		'stat_modifier': obj.stat_modifier,
		'nv_status': obj.nv_status,
		'nv_counts': obj.nv_counts,
	}
	
static func load_stats(dict):
	var stats = CharacterStats.new()
	stats.growth_stats = load(dict['growth_stats'])
	stats.individual_stats = load(dict['individual_stats'])
	stats.learned_skills = []
	for port_skill in dict['learned_skills']:
		stats.learned_skills.append(load_portable_skill(port_skill))
		
	stats.modifiers = dict['modifiers']
	stats.level = dict['level']
	stats.tot_experience = dict['tot_experience']
	stats.text_name = dict['text_name']
	stats.pokemon_name = dict['pokemon_name']

	stats.health = dict['health']
	stats.max_health = dict['max_health']
	stats.strength = dict['strength']
	stats.defense = dict['defense']
	stats.spec_strength = dict['spec_strength']
	stats.spec_defense = dict['spec_defense']
	stats.speed = dict['speed']

	stats.primary_type = dict['primary_type']
	stats.secondary_type = dict['secondary_type']

	stats.is_alive = dict['is_alive']

	stats.stat_modifier = dict['stat_modifier']
	stats.nv_status = dict['nv_status']
	stats.nv_counts = dict['nv_counts']
	return stats
	
static func save_battler(obj: Battler):
	return {
		'battler_name': obj.battler_name,
		'party_member': obj.party_member,
		'selected': obj.selected,
		'selectable': obj.selectable,
		'stats': save_stats(obj.stats)
	}
	
static func load_battler(dict):
	var battler = PokemonFactory.construct_battler_from_state_dict(dict, 1)
	
	return battler

static func save_portable_skill(obj):
	return {
		'skill': obj.skill.resource_path,
		'cur_pp': obj.cur_pp
	}

static func load_portable_skill(dict):
	var loaded_skill = load(dict['skill'])
	var new_portable_skill = PortableSkill.new()
	new_portable_skill.skill = loaded_skill
	new_portable_skill.cur_pp = dict['cur_pp']
	return new_portable_skill

static func save_skill_action(obj: SkillAction):
	return {
		'skill': save_portable_skill(obj.skill)
	}

static func load_skill_action(dict):
	var loaded_skill = load_portable_skill(dict['skill'])
	var new_skill_action = SkillAction.new(loaded_skill)
	return new_skill_action

static func save_item_action(obj: ItemAction):
	return {
		'item': save_item(obj.item)
	}

static func load_item_action(dict):
	var loaded_item = load_item(dict['item'])
	var new_item_action = ItemAction.new(loaded_item)
	return new_item_action
	
static func save_run_action(obj: RunAction):
	return {}

static func load_run_action(dict):
	return RunAction.new()

static func save_change_action(obj: ChangeAction):
	return {
		'change_battler': save_battler(obj.change_battler)
	}

static func load_change_action(dict):
	var loaded_battler = load_battler(dict['change_battler'])
	var new_change_action = ChangeAction.new(loaded_battler)
	return new_change_action
	
static func save_surrender_action(obj):
	return {}
	
static func load_surrender_action(dict):
	return SurrenderAction.new()
	
static func save_action(obj):
	if obj is SkillAction:
		return {
			'type': 'SkillAction',
			'action': save_skill_action(obj)
		}
	elif obj is ItemAction:
		return {
			'type': 'ItemAction',
			'action': save_item_action(obj)
		}
	elif obj is RunAction:
		return {
			'type': 'RunAction',
			'action': save_run_action(obj)
		}
	elif obj is ChangeAction:
		return {
			'type': 'ChangeAction',
			'action': save_change_action(obj)
		}
	elif obj is SurrenderAction:
		return {
			'type': 'SurrenderAction',
			'action': save_surrender_action(obj)
		}
		
static func load_action(obj):
	match obj['type']:
		'SkillAction':
			return load_skill_action(obj['action'])
		'ItemAction':
			return load_item_action(obj['action'])
		'RunAction':
			return load_run_action(obj['action'])
		'ChangeAction':
			return load_change_action(obj['action'])
		'SurrenderAction':
			return load_surrender_action(obj['action'])
		_:
			assert(false==true)
