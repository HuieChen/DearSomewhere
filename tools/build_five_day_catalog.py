"""Runtime adaptation of the user's five-day flow; artwork is independently bound.
Source stays private and immutable. Connective copy is an adaptation, not a quote.
"""
import json
from pathlib import Path

events = []
def step(kind, place, title, **kw):
    return dict(kind=kind, place=place, title=title, **kw)
def read(place, title, *pages, **kw):
    return step('read', place, title, pages=list(pages), **kw)
def inspect(place, title, *pages, **kw):
    return step('inspect', place, title, pages=list(pages), **kw)
def talk(place, speaker, *lines, **kw):
    return step('talk', place, speaker, speaker=speaker, lines=list(lines), **kw)
def choice(place, title, options, **kw):
    return step('choice', place, title, options=[dict(id=k, label=v) for k,v in options], **kw)
def sort(place, title, options, correct, **kw):
    return step('sort', place, title, options=[dict(id=k, label=v) for k,v in options], correct=correct, **kw)
def pack(title, items, **kw):
    return step('pack','post_office',title,columns=6,rows=4,items=[dict(id=k,label=v,w=w,h=h) for k,v,w,h in items], **kw)
def sequence(title, *actions, **kw):
    return step('sequence','post_office',title,actions=list(actions), **kw)
def add(day, id, title, steps, memory, **kw):
    previous=[e for e in events if e['day']==day and not e.get('optional')]
    events.append(dict(id=id,day=day,title=title,steps=steps,memory=memory,after=[previous[-1]['id']] if previous else [],**kw))

add(1,'grandmother','外婆留给 Anne 的信',[
    talk('post_office','Mossner','柜台右边是工作桌。今天先从写给你的这封信开始。','遇到地址不清的信，先看信封，再去问人。拿不准就带回来，不必急着作决定。'),
    inspect('post_office','信封正反面','收件人：Anne。收件地址：Solmere 邮局。','背面写着外婆的名字。封口完整；这是留给 Anne 本人的信。'),
    sort('post_office','这封信交给谁？',[('anne','Anne，本人拆阅'),('return','按旧信退回')],'anne'),
    read('post_office','第一封信','Anne：\n\n你到了。桌上的东西也许和你记忆里不太一样。找不到的时候就问 Mossner。','本子留在抽屉里。里面有镇上的地址，也有我随手记下的小事。先从今天开始吧。\n\n外婆',gives={'notebook':'外婆的本子：周四留了一行约定，没有写名字。'})
], '外婆把本子留给我。第一封信写的是我的名字。')
add(1,'mayor','镇长的签收',[
    inspect('post_office','正式公函','收件人：南星镇长。送达地点：社区中心。需收取正式回执。'),
    talk('community_center','cici','事务一般由我处理。不过这封的收件人是南星。','他在院子里。对，就是那只金毛。照片和回执上的爪印都是他的。'),
    inspect('community_center','值班台','镇长照片：一只金毛，名牌写着「南星」。','签收存根：南星；签记为右前爪印。',gives={'mayor_identity':'南星是金毛；cici 办理社区事务，南星用爪印签收。'}),
    talk('food_truck','咸鱼','是给南星送信？带这根骨头去吧。等他坐好再摊开回执。',gives={'bone':'咸鱼给南星的骨头。'}),
    sort('community_center','交付公函',[('cici','请 cici 代签镇长名字'),('paw','让南星留下爪印')],'paw',requires=['mayor_identity','bone']),
    sequence('归档回执','展开回执','核对爪印','放入今日夹页',gives={'receipt':'第一日公函：已由南星本人爪印签收。'})
], '南星是镇长。回执上的签记是爪印。')
add(1,'offer','Congratulations',[
    inspect('post_office','一封 Offer','收件人：周晓六。地址：海阶居民楼。\n外封印着 Congratulations / Exclusive Offer。'),
    talk('residential','周晓六','是我的，谢谢。……哦，是软件打折。','先垫在桌脚下吧。作品集还差最后一页。你明天经过时也可以来看看。')
], '周晓六收到的是软件折扣信。她还在做作品集。')
add(1,'portfolio','周晓六的求职材料',[
    talk('residential','周晓六','这些要寄出去。简历别折到名字，附件放在文件夹旁边就行。'),
    pack('求职信封',[('cv','简历',2,3),('portfolio','作品集',3,3),('attachments','附件',1,2)]),
    sequence('寄出材料','合上文件夹','放进外封','封口','贴邮票')
], '材料已经装好。封装的方法不只有一种。')
add(1,'xanni','唱片店的合照',[
    talk('record_store','Xanni','你是 Anne 吧。你外婆以前常来这里。','这张照片你拿着。她挑唱片时很有主意，跟别人吵起音乐来可不客气。'),
    inspect('record_store','柜台上的照片','外婆站在唱片柜前，手里举着一张唱片。旁边的人笑得歪向一侧。',gives={'xanni_photo':'Xanni 给我的唱片店合照。'})
], 'Xanni 认识的外婆，和我记忆里的不完全一样。')
add(1,'music_found','回家路上的声音',[
    step('sound','chess_stall','路边的音乐贺卡',text='声音从路边的长椅附近传来。',gives={'music_card':'路边捡到一张会响的贺卡，未写收件人。'}),
    inspect('post_office','暂存贺卡','卡上没有收件人。合页内藏着发声片；合起后音乐停了。','先放在待认领格，不替它猜一个主人。'),
    talk('post_office','Mossner','这张旧照片也是你外婆留下的。楼上的东西可以慢慢看，床也已经收拾好了。',gives={'attic_key':'阁楼可以使用；每天收工后可上楼整理遗物、睡觉。'})
], '贺卡留在待认领格。楼上的房间可以住了。')

add(2,'returned_mayor','退回的镇长评估信',[
    inspect('post_office','退回件','同一封公函回来了。已有南星爪印；收件人一栏被涂黑。','昨日回执：本人签收。不能再按「无人签收」处理。',requires=['receipt']),
    talk('community_center','cici','他签了，又把信带回来了。里面是配对评估的要求。','南星，你是不想参加这个，还是不想再收到这种安排？'),
    choice('community_center','替南星写回函',[('decline','谢绝配对安排，询问能否参加普通活动'),('ask','说明意愿，先询问活动是否接纳狗')],flag='mayor_reply'),
    sequence('寄出回函','将回函装入','封口','贴邮票')
], '退信也是表达意愿。我们问了活动是否欢迎狗。')
add(2,'cat_letter','猫爪封蜡',[
    inspect('post_office','没有名字的信','信封粘着浅色毛，封蜡有一枚猫爪印。没有清楚的收件人名字。'),
    talk('residential','邻居','这边的小孩常用猫爪印作记号。她家的猫最近总往隔壁跑。'),
    choice('residential','如何确认',[('outside','凭爪印和主人核对，不拆信'),('open','私下打开，再重新封好')],flag='cat_open'),
    read('residential','折在里面的纸','你最近都不来找我了。你是不是更喜欢隔壁的零食？\n\n——给我家的猫',when={'key':'cat_open','value':'open'}),
    step('sequence','residential','恢复封口',actions=['折回原样','放回信封','重新封口'],when={'key':'cat_open','value':'open'}),
    talk('residential','小孩','原来它把信弄到邮筒里去了。给我就好，我会自己拿给它。',variants={'flag':'cat_open','value':'open','lines':['封口怎么动过？这是我写给它的。下次请先问我。','信我收下了。']}),
], '猫爪印和邻居的话对应上了。信归还给写信的小孩。')
add(2,'food_application','动物们的食物申请',[
    inspect('post_office','申请袋','袋里有一张食物清单和餐车菜单的碎片；尾页缺了收件地址。'),
    talk('market','Siri','Siri 把菜单碎片推过来，转身跑向树下棋摊。'),
    talk('chess_stall','Arthur','它们想问餐车要些合适的食物。把清单交给咸鱼吧。','你外婆？我周四常在这里下棋。不过我没有赴过她本子里的约。',gives={'arthur_thursday':'Arthur 周四在棋摊；本子里没写约见者的名字。'}),
    talk('food_truck','咸鱼','这张清单是它们的。海鸥那份也在里面。菜单背面是我写的，不是收件地址。')
], '食物申请交给餐车。周四的约定还不能凭 Arthur 猜定。')
add(2,'theo','Theo 的生日卡',[
    talk('record_store','Theo','我在等一张生日卡。是上周从北岸寄的，浅绿色信封。'),
    inspect('post_office','积压件索引','A：北岸，上周，浅绿色，Theo。\nB：北岸，本月初，灰色，退件。\nC：南港，上周，浅绿，Théo 商店。'),
    sort('post_office','领取哪一件？',[('a','A · 北岸 / 上周 / Theo'),('b','B · 北岸 / 本月初'),('c','C · 南港 / Théo 商店')],'a'),
    talk('record_store','Theo','就是这封。我自己拆吧。','你外婆坚持那首歌该慢一点，我总嫌慢。可我们还会一起听。照片背面有当时的日期。',gives={'theo_photo':'Theo 的照片：外婆也有与人争论音乐的日子。'})
], 'Theo 找到了生日卡。他和外婆的喜好并不总一致。')
add(2,'recipe','餐车的新配方',[
    talk('food_truck','咸鱼','BEETMAN 寄来的配方只写了一半：甜根茎、酸味果汁、少量香草。先去菜摊核对。'),
    inspect('market','今日食材','甜菜：甜味根茎。\n柠檬：酸味果汁。\n罗勒：香草。\n盐：调味品。\n面包：主食。',gives={'ingredients':'配方对应甜菜、柠檬和罗勒。'}),
    step('cook','food_truck','试做一小份',ingredients=['甜菜','柠檬','罗勒','盐','面包'],correct=['甜菜','柠檬','罗勒'],actions=['切碎','下锅','搅拌','盛出'],requires=['ingredients']),
    talk('food_truck','咸鱼','味道对上了。余下的我来，今天菜单上可以添这一项。')
], '菜摊的食材和 BEETMAN 的配方对上了。试做成功。')
add(2,'tarot_damage','塔罗店的破损包裹',[
    inspect('tarot_shop','当面检查包裹','外箱一角压凹，封条仍完整。','牌盒边缘压弯；内袋未破，牌面未发现折损。'),
    sort('tarot_shop','填写损坏情况',[('all','全部报废'),('box','外箱与牌盒受损，牌面完好'),('none','未见任何损坏')],'box'),
    talk('tarot_shop','夏透明','这样记就好。盒子和里面的东西不是一回事，谢谢你一起检查。')
], '破损登记写的是实际看到的损坏。')

add(3,'war_letter','旧地址上的 Arthur',[
    inspect('post_office','年代久远的信','寄件人：艾琳。收件人姓名旁附着旧职务，地址已经停用。外封附注：邮员可开封核实转交身份。'),
    read('post_office','艾琳的信','撤离那天，你十九岁，我七岁。你把我带到安全的地方，我一直记得。','我现在也老了。一直想好好说一声谢谢。如果这封信能找到你，请收下迟来的问候。\n\n艾琳',gives={'war_identity':'艾琳信中的救援者：当年十九岁；旧称呼与 Arthur 相符。'}),
    talk('chess_stall','Arthur','是那时候的事。原来她还记得。','我和你外婆不过是在镇上碰面、下过几盘棋。你找的那个人不是我。',requires=['war_identity'])
], '信送到了 Arthur 手里。外婆周四约见的人另有其人。')
add(3,'cici_forward','多次退回的信',[
    inspect('post_office','转递标签','最早：地址不详。\n后来：补填旧住所。\n再后来：收件人搬离。\n最新：cici 提供了有效新地址。'),
    step('order','post_office','依时间整理转递标签',actions=['地址不详','补填旧住所','收件人搬离','粘贴最新地址']),
    talk('community_center','cici','这一张才是现在用的地址。旧标签留作记录，别再让它盖住新地址。')
], '转递件按时间理顺，最新地址露在外侧。')
add(3,'future_self','外婆写给未来的自己',[
    read('post_office','套在一起的信纸','年轻时：我想有自己的工作，也想有钱到远一点的地方去。','中年时：每天都有必须先做的事。家人很重要，可我也想有一点自己的时间。','晚年时：想再学鼓，和朋友见面，看看海，也许还能去旅行。'),
    sequence('收好原来的层次','叠回年轻时的纸','包入中年信纸','放回晚年信封')
], '外婆写给自己的信，藏着不同年纪的愿望。')
add(3,'blank','一封空白信',[
    inspect('post_office','信封里的线索','随信夹着一角旧车票。外封写：给总在餐车前戴耳机、买完吃的还会站一会儿的人。'),
    sort('food_truck','核对收件人',[('chen','尘缘 · 戴耳机的常客'),('chef','咸鱼 · 餐车主人')],'chen'),
    talk('food_truck','尘缘','是我们说好的。就算没什么可写，也可以寄一封来。','空着也没关系。我知道他还记得。')
], '空白不是漏写。那是尘缘和朋友之间的约定。')
add(3,'maya_fracture','Maya 留下的另一份记录',[
    inspect('bookstore','演出资料','旧节目单和照片：Maya 曾参加演出。','原始访谈提到：报酬被扣，家里急需药钱。\n公开版只剩：「她缺少勇气。」'),
    talk('bookstore','Maya','那是你外婆写的。你可以喜欢她，可被删掉的事情确实发生过。','我以前也替她解释过。今天先说到这里吧。')
], '我看到了原始访谈与公开版本的差别。Maya 不必立即原谅。')
add(3,'anonymous','没有署名的三封信',[
    inspect('post_office','按习惯写的地址','第一封：给常带望远镜到观景台的人。\n第二封：给常在唱片柜边争论快慢的人。\n第三封：给一早为菜摊开门的人。'),
    talk('lookout','宇星晴','望远镜说的是我。这封我拿着，剩下的请继续核对。'),
    talk('record_store','Theo','听音乐争快慢？大概真是我。让我看看信封。'),
    talk('market','冥冥','每天最早到菜摊的是我。谢谢你跑一趟。')
], '三封按日常习惯寻人的信都送到了。',optional=True)

add(4,'maya_truth','没有被刊出的部分',[
    talk('bookstore','Maya','你想看她后来寄给我的信，可以。先把两份访谈放在一起。'),
    inspect('bookstore','并排核对','原稿：演出方扣下报酬，家中缺药。离开是当时必须作出的选择。','公开稿：删掉处境，只留下「缺少勇气」。\n后来来信承认了删改，却不能替 Maya 决定是否释怀。'),
    choice('bookstore','Anne 的回应',[('listen','先听 Maya 说完'),('acknowledge','承认删改造成了伤害')],flag='maya_response')
], '喜欢外婆，不等于替她改掉伤害别人的事实。')
add(4,'old_quarrel','迟到二十年的争吵',[
    inspect('post_office','一封旧退件','寄件人：闹闹。收件人：Xanni。内容关乎二十年前的一次演出。'),
    talk('chess_stall','闹闹','那次我们为缺席和报酬吵过。后来已经和好了。信竟然还在。'),
    choice('post_office','如何处理旧信',[('intact','完整交给 Xanni'),('contact','先征询闹闹'),('hold','先留在待处理格'),('edit','私自打开并划改')],flag='quarrel_route'),
    talk('chess_stall','闹闹','给她吧。她现在看见，大概会想起当年的我们。',when={'key':'quarrel_route','value':'contact'}),
    choice('post_office','待处理格',[('resume','现在继续转交')],when={'key':'quarrel_route','value':'hold'}),
    step('strike','post_office','保留划改痕迹',sentences=['你那天为什么没有出现？','报酬的事，你一句也没有解释。','我不想再见你。'],flag='quarrel_strikes',when={'key':'quarrel_route','value':'edit'}),
    sequence('重新封装','折回信纸','放回原信封','封好折口',when={'key':'quarrel_route','value':'edit'}),
    talk('record_store','Xanni','我们后来都说开了。旧信也可以留着，不必假装那场争吵没有发生。',variants={'flag':'quarrel_route','value':'edit','lines':['这些线是谁划的？这是我们之间的信。','我会收下，但请不要替我们删掉那时候的话。']})
], '旧争吵的信送到了。是否改动，留在信上，也留在收信人的反应里。')
add(4,'maya_private','Maya 的私人信件',[
    talk('bookstore','Maya','请帮我把这封寄出去。收件信息在外面，里面的内容不用看。'),
    sequence('只处理外封','沿原折痕折好','装入信封','封口','贴邮票')
], 'Maya 的信已经寄出。正文始终没有打开。')
add(4,'visible','Visible 的申请',[
    read('post_office','注明可核实内容的申请','Visible：我想参加社区的音乐交流。我还年轻，正在写说唱。','我不知道该写哪个部门。若投错，请邮局核实后转交负责音乐交流的人。'),
    sort('community_center','交给哪个项目？',[('music','社区音乐交流'),('tax','税务'),('repair','道路维修')],'music'),
    talk('community_center','cici','音乐交流这边收。联系方式写得清楚，我们会回信给 Visible。')
], 'Visible 的申请交到了社区音乐交流项目。')
add(4,'solmere','To Solmere',[
    inspect('post_office','写给小镇的信','收件人：Solmere。信中向一起帮忙的居民道谢；附注允许公开传阅。'),
    talk('community_center','cici','写给整个镇子的啊。让我读一下，再带给其他人。'),
    talk('record_store','Xanni','我记得那次大家一起帮忙。谢谢你带来。'),
    talk('bookstore','Maya','放在大家能读到的地方吧。'),
    talk('food_truck','咸鱼','我读完了。Arthur 还在树下，带给他看看。'),
    talk('chess_stall','Arthur','嗯。读过的人也可以再读一次，别收进只有邮员能打开的柜子。'),
    sequence('邮局公开栏','摊平信纸','固定在公开栏')
], 'To Solmere 在镇上传阅，最后留在邮局的公开栏。')
add(4,'rae','外婆写给 Rae 的信',[
    inspect('post_office','核对周四的约定','本子记着周四；唱片店的索引与节目单指向同一段演出时期。','Theo 记得外婆听歌的习惯。Rae 曾说想留下那场演出的录音。',requires=['notebook','xanni_photo','theo_photo']),
    sort('lookout','核对收件人',[('rae','向 Rae 核对这段共同经历'),('arthur','把周四直接认作 Arthur')],'rae'),
    talk('lookout','Rae','是写给我的。谢谢，我想自己打开。','我们也曾想去很远的地方。后来并不是每件事都照着想法发生。','这张合照给你。演出的录音我整理一下，明天你再来。',gives={'rae_photo':'Rae 与外婆的合照；Rae 自己读了那封信，正文没有公开。','recording_promised':'Rae 会在第五日交出演出录音。'})
], '信由 Rae 自己打开。她和外婆的关系不是我的猜谜答案。')
add(4,'radio','Arthur 的收音机',[
    talk('chess_stall','Arthur','维修店说寄回来了。包裹号西区 B 架 17。'),
    inspect('post_office','包裹架索引','西区 B 架 17：Arthur，修复收音机。\n西区 A 架 17：工具。\n东区 B 架 17：衣物。'),
    sort('post_office','从哪一格取件？',[('wb17','西区 B 架 17'),('wa17','西区 A 架 17'),('eb17','东区 B 架 17')],'wb17'),
    talk('chess_stall','Arthur','能响了。今晚下棋有东西听了。',gives={'radio_repaired':'Arthur 的收音机已经送回棋摊。'})
], '收音机回到棋摊。架位和号码一起才能找到包裹。')

add(5,'dog_gift','南星的礼盒',[
    talk('community_center','cici','回信到了，活动欢迎南星参加。给他的礼盒也请你帮忙。'),
    choice('community_center','挑一张合照',[('garden','院子里的合照'),('desk','办公桌旁的合照')],flag='dog_photo'),
    pack('给南星的礼盒',[('bone','骨头',3,1),('toy','玩具',2,2),('frame','相框',3,2)]),
    sequence('封好礼盒','合盖','绕好纸带','贴收件签'),
    talk('community_center','cici','刚好装下。南星，合照可不能当玩具咬。')
], '南星会参加活动。骨头、玩具和相框装进了礼盒。')
add(5,'music_home','贺卡终于有了收件人',[
    talk('lookout','宇星晴','你说的那段旋律，我做过一张会响的卡。是准备送给夏透明的。','那天带着望远镜，收东西时把卡弄丢了。她在塔罗店。',requires=['music_card']),
    inspect('post_office','待认领的卡','熟悉的旋律与宇星晴哼出的调子相同。折角和制作方式也对得上。'),
    talk('tarot_shop','夏透明','原来是给我的。我打开听听。','谢谢你一直替它找主人。',gives={'music_delivered':'宇星晴做的音乐贺卡，已交给夏透明。'})
], '第一晚捡到的音乐贺卡，交到了夏透明手里。')
add(5,'cover_letter','周晓六的求职信',[
    talk('residential','周晓六','我想投设计岗位。想让人看到我做过什么，不想全是「充满热情」。'),
    step('strike','residential','一起改求职信',sentences=['我对贵公司充满无限热情。','我完成过社区活动的视觉设计。','附件里有三组作品和制作过程。','我愿意无条件奉献全部时间。'],flag='cover_edits'),
    talk('residential','周晓六','让我最后读一遍。嗯，留下作品和过程，这样更像我。','就用我确认过的这份吧。'),
    sequence('寄出确认稿','放入确认稿','附上作品索引','封口','贴邮票')
], '求职信由周晓六确认后寄出。不是替她决定要成为什么样的人。')
add(5,'last_letter','外婆留到最后的信',[
    talk('post_office','Mossner','这是她早先交给我的。她只说，等你安顿下来，再交给你。'),
    read('post_office','给 Anne','记得你小时候拿着柠檬，酸得皱起脸还不肯放下。后来你长大了，我们说话也越来越短。','你说忙，我也说都好。有些话不是不想说，只是总想着还有下一次。','你不用把我的日子再过一遍。也不用急着告诉我你已经想清楚了。\n\n外婆'),
    choice('post_office','把信收在哪里？',[('bag','随身留着'),('attic','和阁楼的遗物放在一起')],flag='last_letter_place')
], '外婆留下这封信时，不知道我这几天会经历什么。')
add(5,'performance','留存的演出',[
    talk('lookout','Rae','录音整理好了。可以坐在这里听，不急着回去。',requires=['recording_promised']),
    step('listen','lookout','听一段演出录音',seconds=12,gives={'performance':'听过 Rae 留下的演出录音；可在本子中重听。'})
], 'Rae 把录音交给了我。演出并不完美，但那时的人都在里面。')
add(5,'somewhere','Dear Somewhere',[
    step('write','post_office','写给某处',recipients=['外婆','未来的自己','陌生人','Somewhere']),
    sequence('寄出自己的信','折好信纸','放进信封','封口','写下 Dear Somewhere'),
    talk('post_office','Anne','这封信，写给某处。','镇上的一天还在继续。我也可以再出去走走。')
], '我寄出了自己的信。旅程结束后，小镇仍然可以自由探索。')

nights = [
 dict(title='第一晚',objects=[dict(title='合照',text='照片里的外婆站在唱片柜前。我从来没和她一起逛过那里。'),dict(title='周四的本子',text='「周四」旁边留了一道墨迹，没有名字。暂时还不知道是谁。')]),
 dict(title='第二晚',objects=[dict(title='另一张照片',text='外婆也有不想留在原地的日子。照片背面的日期，和 Theo 说的那段时间接近。'),dict(title='没有写完的页',text='本子里有出走的计划，也有划掉的日期。不能只凭周四就认定是 Arthur。')]),
 dict(title='第三晚',objects=[dict(title='叠好的信',text='不同年纪的愿望，被她叠回同一个信封。'),dict(title='节目单',text='Maya 的名字还在节目单上。今天听到的话没有因为回家就变轻。')]),
 dict(title='第四晚',objects=[dict(title='Rae 的合照',text='有些事情，只属于照片里的两个人。信的内容不在这里。'),dict(title='留出的空位',text='旧照片旁边留着空位，明天还可以放进新的东西。')]),
 dict(title='第五晚',objects=[])
]
catalog=dict(version=1,source_sha256='18acd0e0c74481cee5a00553e5b0f001fd1d208b0e26382a86e8c902afbfde50',copy_status='Flow-faithful playable adaptation; connective prose pending author review.',events=events,nights=nights)
times={1:[540,600,720,840,975,1185],2:[540,630,720,825,930,1020],3:[540,660,780,900,1050,900],4:[540,660,750,840,930,1050,1185],5:[540,660,780,960,1050,1155]}
for day, minutes in times.items():
    for event, minute in zip([e for e in events if e['day']==day],minutes):event['minute']=minute
dest=Path(__file__).resolve().parents[1]/'data/campaign/five_days.json'
dest.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(events)} events / {sum(len(e["steps"]) for e in events)} steps')
