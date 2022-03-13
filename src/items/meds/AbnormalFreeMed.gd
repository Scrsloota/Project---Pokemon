extends Item
class_name AbnormalFreeMed

func implement_function(target):
	target.stats.remove_nv_status()
	#可能会实现动画
	return "%s fell better!" % target.stats.text_name
