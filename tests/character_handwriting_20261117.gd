extends SceneTree
var out:=""
var checks:=0
var failures:Array[String]=[]
const Writing=preload("res://scripts/rebuild/character_handwriting.gd")
func _initialize():
	for arg:String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-out="):out=arg.trim_prefix("--qa-out=")
	if out.is_empty():quit(1);return
	run.call_deferred()
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures.append(label);push_error(label)
func run():
	root.unfocusable=true;Engine.max_fps=60
	root.size=Vector2i(1600,900);root.content_scale_size=Vector2i(1600,900);root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	DirAccess.make_dir_recursive_absolute(out)
	var names:Array=Writing.PROFILES.keys()
	var descriptions:={"Anne":"圆润轻快 · 小幅起伏","cici":"活泼便签 · 字距更松","Maya":"钢笔书写 · 工整收笔","Rae":"纤细修长 · 利落时尚","guitarist":"随性行草 · 摇滚笔势","Arthur":"复古笔意 · 轻微不齐","Mossner":"温和整齐 · 邮务书写","Xanni":"松弛连笔 · 音乐节奏","尘缘":"收敛小字 · 认真克制","冥冥":"细笔手账 · 略有迟疑","周晓六":"松散速记 · 低精力感","BEETMAN":"宽稳硬笔 · 偶尔跳脱","夏透明":"细字疏行 · 安静倾听","宇星晴":"清瘦留白 · 温和安静","咸鱼":"厚实快写 · 热情直接","闹闹":"斜势连笔 · 夜间随性","Theo":"紧凑清晰 · 条理分明"}
	for batch:int in range(3):
		var sheet:=Control.new();root.add_child(sheet);sheet.size=Vector2(1600,900)
		var background:=ColorRect.new();background.color=Color("f3eee1");background.size=sheet.size;sheet.add_child(background)
		var title:=Label.new();sheet.add_child(title);title.position=Vector2(55,22);title.text="Dear Somewhere 角色手写字样  "+str(batch+1)+" / 3";title.add_theme_color_override("font_color",Color("354a4a"));title.add_theme_font_size_override("font_size",28)
		for offset:int in range(6):
			var index:=batch*6+offset
			if index>=names.size():break
			var speaker:String=names[index]
			var origin:=Vector2(55+(offset%2)*760,90+(offset/2)*260)
			var card:=ColorRect.new();card.color=Color("fffaf0");sheet.add_child(card);card.position=origin;card.size=Vector2(730,242)
			var name_label:=Label.new();sheet.add_child(name_label);name_label.position=origin+Vector2(24,14);name_label.size=Vector2(680,38);name_label.text=("黄毛乐队男（未定名）" if speaker=="guitarist" else speaker)+"  /  "+descriptions[speaker]
			var body:=RichTextLabel.new();sheet.add_child(body);body.position=origin+Vector2(24,66);body.size=Vector2(680,160);body.scroll_active=false
			var sample:="今天的风很轻，雨停以后再出发。\n把想说的话，慢慢写在这张纸上。\nDear Somewhere, 2026. 手写样字。"
			Writing.apply(body,name_label,speaker,sample)
			await process_frame
			check(body.get_parsed_text()==sample,"literal text retained: "+speaker)
			check(body.get_content_height()<=body.size.y,"specimen fits: "+speaker)
			check(body.get_theme_font("normal_font")==Writing.font_for(speaker),"speaker font selected: "+speaker)
		await create_timer(.4).timeout;await RenderingServer.frame_post_draw
		var first:=root.get_texture().get_image()
		first.save_png(out+"/handwriting-"+str(batch+1)+".png")
		await create_timer(.4).timeout;await RenderingServer.frame_post_draw
		check(first.get_data()==root.get_texture().get_image().get_data(),"writing marks remain static page "+str(batch))
		sheet.queue_free();await process_frame
	# Speaker switch and actual notebook layout, including literal brackets and long lines.
	for speaker:String in ["Maya","Rae","guitarist","Arthur","Anne","cici"]:
		var dialogue=load("res://scripts/rebuild/scene_dialogue.gd").new();root.add_child(dialogue);dialogue.size=Vector2(1600,900);dialogue.authored_text_enabled=true
		dialogue.configure(speaker,"今天的风很轻，雨停以后再出发。把想说的话，慢慢写在这张纸上。[笔记] Dear Somewhere，留给以后再读。")
		await create_timer(.5).timeout
		check(dialogue.get_node("SpokenLine").get_parsed_text().contains("[笔记]"),"brackets remain literal: "+speaker)
		check(dialogue.get_node("SpokenLine").get_content_height()<=dialogue.get_node("SpokenLine").size.y,"notebook text fits: "+speaker)
		await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(out+"/notebook-"+speaker+".png")
		dialogue.set_line("Anne","我把它记下来了。");await create_timer(.25).timeout
		check(dialogue.get_node("SpokenLine").get_theme_font("normal_font")==Writing.font_for("Anne"),"font changes with speaker: "+speaker)
		dialogue.queue_free();await process_frame
	FileAccess.open(out+"/receipt.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
