--·���б�
--ToDo: ��·����¼�����ݿ���

zone_map = {["��������"]="changanwest",
			["����ׯ"]="gao",
			["��¥һ��"]="honglou",
			["����ɽ"]="putuo",
			["�����"]="kaifeng",
			["�¹�"]="moon",
			["����"]="longgong",
			["������"]="changan",
			["����ɽ"]="fangcun",
			["��ׯ��"]="wuzhuang",
			["��ѩɽ"]="xueshan",
			["�"]="lijing",
			["�����"]="baoxiang",
			["�����ɵ�"]="penglai",
			["����ɽ"]="qilin",
			["����"]="yuhua",
			["������"]="jingjiling",
			["�����"]="biqiu",
			["Ů����"]="nuerguo",
			["���Ϲ�"]="zhuzi",
			["���ٹ�"]="chechi",
			["С����"]="xiaoxitian",
			["����ɽ"]="jilei",
			["ͨ���"]="tongtian",
			["���ɿ�"]="fengxian",
			["ëӱɽ"]="maoying",
			["���ɽ"]="zhujie",
			["ƽ��ɽ"]="pingding",
			["��˿��"]="pansi",
			["�ڼ���"]="wuji",
			["�շ���"]="qinfa",
			["����ɽ"]="firemount",
			["���ù�"]="tianzhu",
			["�̲�̶"]="bibotan",
			["��ƽ��"]="jinping",
			["������"]="jisaiguo",
			["����ɽ"]="qinglong",
			["����ɽ"]="yinwu",
			["�޵׶�"]="wudidong",
			["��ɽ"]="jindou",
			["����ɽ"]="dudi",
			["�׻���"]="baihuling",
			["��ͷɽ"]="baotou"}

pathes = { changan="set brief;l;l up;l down;e;n;l north;l east;s;l south;e;l north;l south;e;n;l north;s;l east;s;l east;sw;w;n;l north;s;w;enter;u;u;u;u;u;u;u;u;u;u;u;u;u;l up;d;d;d;d;d;d;d;d;d;d;d;d;d;out;e;s;e;se;ne;e;l east;w;se;l enter;nw;sw;nw;w;sw;se;s;enter;e;enter;u;u;u;u;u;l up;d;d;d;d;d;out;w;out;n;nw;w;l south;w;l south;l west;nw;l east;w;l south;l west;n;l east;w;l west;e;nw;l east;n;l west;l north;e;l north;s;s;l east;n;n;e;l north;l south;e;n;e;l east;w;l west;n;l north;s;s;s;l east;l west;s;l east;s;l east;l west;n;w;l south;l west;u;l east;l west;l south;l north;u;l east;l west;l south;l north;u;l east;l west;l south;l north;u;l east;l west;d;d;d;d;e;n;n;e;e;s;#dummy answer ��ʦ;answer ��ʦ;s;l west;l east;sw;e;l east;s;l west;s;sw;l west;se;s;sw;s;l west;l east;n;ne;e;se;l north;nw;n;ne;n;nw;nw;w;n;n;n;n;w;w;unset brief",
	changanwest="set brief;w;w;w;w;w;w;w;nw;w;w;sw;su;l southup;nd;w;#dummy give 2 silver to ma dao;give 2 silver to ma dao;nw;w;nu;l enter;sd;w;w;l southup;e;e;unset brief",
	fangcun="set brief;s;s;s;s;s;s;s;s;s;s;s;s;s;w;w;w;w;w;w;w;w;w;w;nw;nu;n;w;l south;w;l west;e;nu;n;l westup;nd;se;se;ne;l east;ne;nu;nu;n;l west;e;l east;l north;l south;w;n;l west;ne;l east;l south;n;l up;s;sw;nu;n;nw;ne;nw;ne;enter;out;say ������������;unset brief",
	gao="set brief;s;s;s;s;s;s;s;s;s;s;s;s;s;w;w;w;w;w;w;w;w;w;w;l north;s;s;s;l east;sw;ne;n;n;n;e;e;l north;l south;e;l south;e;n;l west;l east;n;l west;l east;n;w;u;d;e;l east;n;unset brief",
	honglou="set brief;west;south;#wait 3;#dummy withdraw 13 silver;withdraw 13 silver;#wait 3;north;east;south;west;#wait 3;#dummy buy huangliang zhen from dong;buy huangliang zhen from dong;#wait 3;east;east;#dummy give 3 silver to waiter;give 3 silver to waiter;east;#dummy get huangliang zhen from kuang;get huangliang zhen from kuang;#dummy sleep;sleep;u;s;l west;l east;l out;n;l west;n;l east;n;l west;l east;l enter;n;l up;n;l west;l east;n;l west;l east;l up;n;l down;n;l backyard;s;s;u;unset brief",
	honglou_skip="set brief;u;n;n;n;n;n;u;ask girl about back",
	kaifeng="set brief;e;e;e;e;e;e;e;e;e;e;e;e;l south;e;se;e;e;l east;w;w;s;eu;s;e;e;l east;w;w;sw;e;e;nw;su;s;w;s;l west;s;e;l south;e;n;l east;n;w;n;nd;n;wd;n;nw;nw;l west;n;l west;n;n;w;w;l north;l south;e;e;n;ne;se;e;l east;w;s;s;l east;s;e;e;n;l north;s;w;w;s;l east;n;n;n;n;nw;n;w;sw;nw;n;ne;e;se;e;e;e;n;e;se;se;sw;nw;nw;w;w;nu;l north;unset brief",
	longgong="set brief;s;s;s;s;s;s;s;s;s;s;s;s;s;s;s;s;e;e;e;#dummy get bishui zhou from kuang;get bishui zhou from kuang;#dummy dive;dive;#wait 3;e;e;ne;e;e;ne;ne;l east;l north;sw;sw;se;se;l east;l south;l north;nw;nw;eu;n;n;n;e;e;e;e;s;s;s;s;w;w;w;w;n;n;n;e;n;n;ne;l east;sw;l northwest;s;s;s;s;se;l east;nw;l southwest;n;n;e;eu;eu;e;l north;l south;e;l north;l south;e;l enter;unset brief",
	moon="set brief;w;w;w;w;w;w;w;nw;ne;nw;nw;nw;w;wu;su;su;wu;wu;nu;w;w;l west;e;e;e;l enter;w;n;l west;l east;l north;s;#dummy climb tree;#wait 1;climb tree;u;u;enter;n;n;l east;w;l south;u;gobed;out;d;e;n;w;l west;n;l west;e;se;s;l east;w;s;s;s;out;d;d;d;unset brief",
	moon2="set brief;climb tree;u;u;enter;n;n;l east;w;l south;u;gobed;out;d;e;n;w;l west;n;l west;e;se;s;l east;w;s;s;s;out;d;d;d;unset brief",
	putuo="set brief;s;s;s;s;s;s;s;s;s;s;s;s;s;s;s;s;#dummy swim;swim;mount horse;mount maolu;n;n;nu;nu;n;w;l south;l west;e;e;l east;l south;w;n;l enter;e;nd;n;nw;sw;s;l southup;n;ne;l south;n;ne;ne;n;w;s;e;n;l north;e;l enter;w;w;l enter;e;s;unset brief",
	putuo2="set brief;#dummy fly putuo;#wait 1;fly putuo;sd;sd;s;l south;n;nu;nu;n;w;l south;l west;e;e;l east;l south;w;n;l enter;e;nd;n;nw;sw;s;l southup;n;ne;l south;n;ne;ne;n;w;s;e;n;l north;e;l enter;w;w;l enter;e;s;unset brief",
	wuxudaozhang="set brief;e;s;e;e;n;#wait 2;ask daozhang about fu;#wait 2;s;w;w;unset brief",
	wuzhuang="set brief;w;w;w;w;w;w;w;nw;w;w;sw;w;#dummy give 2 silver to ma dao;give 2 silver to ma dao;nw;w;nu;n;nu;nw;n;nu;nu;nu;n;nu;e;l southup;n;n;l east;n;n;l west;n;w;w;s;l east;s;s;l west;s;s;l southup;n;e;l east;n;eu;l up;ed;s;open door;e;n;n;n;n;w;n;n;ne;d;u;n;sw;n;n;nw;nw;ne;ne;se;se;sw;n;nw;n;ne;se;s;sw;s;s;#dummy jump bridge;jump bridge;u;unset brief",
	xueshan="set brief;#dummy get xueshan map from kuang;get xueshan map from kuang;#dummy fly xueshan;fly xueshan;nu;nu;nu;l west;e;e;l south;l east;w;w;n;#dummy jump shi bi;jump shi bi;l west;l east;n;l west;l east;n;l west;l east;n;#dummy jump shi bi;jump shi bi;w;l south;l north;e;open door;e;w;n;n;#dummy jump shi bi;jump shi bi;w;w;n;e;s;e;l east;d;s;s;d;s;s;s;d;s;e;e;e;climb up;climb left;climb up;climb up;climb left;climb left;climb up;climb up;l west;l east;s;l west;l east;s;s;l west;n;n;n;l north;unset brief",
	lijing="set brief;d;s;w;w;n;n;e;e;s;s;s;s;s;w;w;w;w;fly changan;unset brief",
	baoxiang="set brief;fly baoxiang;north;north;north;north;l northwest;s;s;l east;s;l east;s;l east;l south;sw;l north;w;w;l south;w;nw;l qiao;#tri �����ϵĴ���������һ��;n;ne;nu;nw;ne;se;s;se;break shi ban;se;nw;#tri ��¡һ�����죬һ�ж���ԭ�ˣ�;nw;n;nw;nw;ed;e;e;l southeast;ne;ne;ne;l east;sw;sw;sw;w;w;wu;sd;nw;nw;nw;se;se;nu;ne;e;e;sink;w;e;mount maolu;mount shi;mount horse;fly baoxiang;south;south;south;south;s;unset brief",
	penglai="set brief;#dummy get eastsea map from kuang;get eastsea map from kuang;#dummy fly penglai;fly penglai;su;l south;l out;nd;nu;say �����ƶ���enter/n/n/n/ne/ne/nw/n/n;unset brief",
	qilin2="set brief;right;climb;right;climb;nw;wu;unset brief",
	qilin="set brief;fly zhuzi;south;south;south;south;south;south;south;south;south;south;n;n;n;n;n;n;e;e;e;e;ne;eu;eu;se;fly qilin;right;right;right;right;right;right;right;climb;right;right;right;right;right;climb;nw;wu;l northeast;say �ڶ��ڣ�׼���ε�;unset brief",
	yuhua="set brief;fly yuhua;south;south;south;south;south;south;south;southwest;north;east;east;east;east;east;west;west;west;south;south;south;southwest;ne;n;e;e;l east;w;w;n;n;w;l south;w;l west;e;e;e;l south;e;l east;w;w;n;n;l west;l east;n;l west;n;l east;n;w;l west;e;e;l east;w;n;n;n;w;w;l west;e;e;e;e;l southeast;w;w;nw;ne;unset brief",
	jingjiling="set brief;fly jingjiling;l east;get sword from kuang;wield sword;unset brief",
	biqiu="set brief;fly wudidong;northeast;northup;eastdown;southeast;east;northeast;e;s;l southeast;sw;s;l southwest;w;w;l south;e;e;n;ne;n;l east;n;l east;l northwest;ne;e;e;l south;l east;se;e;e;e;l east;nw;w;w;w;s;sw;l east;se;l west;se;s;sw;s;sw;s;e;sw;se;s;s;sw;w;w;se;e;e;ne;w;unset brief",
	nuerguo="set brief;fly nuerguo;north;north;west;west;e;nu;n;l west;l east;l north;s;sd;e;s;w;w;s;e;e;se;e;l north;w;s;su;open door;enter;out;nd;w;wu;nd;nu;nu;l eastdown;nw;say �����ںӶ���;fly tongtian;north;north;north;north;north;s;w;w;w;n;nw;w;w;sw;wu;sw;n;nw;nw;n;sw;w;sw;sd;wd;nw;w;s;s;unset brief",
	zhuzi="set brief;fly zhuzi;south;south;south;south;south;south;south;south;south;south;l east;n;l west;e;l southeast;l east;w;n;n;l west;l east;n;l east;n;n;w;w;w;l west;l north;l south;e;l north;l south;e;l north;l south;e;e;l north;e;l north;s;l east;l south;n;e;l east;n;n;w;w;w;w;w;l west;e;e;n;n;n;n;w;w;nw;se;e;e;ne;n;nw;unset brief",
	chechi="set brief;fly tongtian;south;south;south;south;south;n;n;e;ne;e;n;e;se;ne;ne;e;e;n;e;e;e;n;l west;n;l west;s;s;w;w;w;l west;n;l west;s;s;s;l west;s;l west;l south;n;e;e;e;e;s;l east;s;l east;n;n;n;e;e;se;l south;nw;w;n;n;n;w;w;w;su;eu;sw;su;se;e;n;l north;s;l southeast;e;e;l northup;w;w;w;nw;nd;ne;wd;nd;w;w;w;s;s;s;s;s;s;e;e;e;nu;nu;nu;l west;open door;e;w;n;n;l northwest;s;ne;e;l east;w;sw;s;sd;sd;sd;e;e;e;n;n;n;w;s;w;w;n;w;w;n;n;n;n;e;e;e;e;s;s;s;s;w;w;l north;say ���ʹ���������;unset brief",
	xiaoxitian="set brief;fly xiaoxitian;s;sw;l south;ne;e;l east;l north;l south;w;n;nw;nw;n;w;sw;l west;ne;e;s;e;ne;e;e;e;unset brief",
	jilei="set brief;fly jilei;northwest;southwest;s;se;sw;l southeast;w;l southwest;e;ne;nw;n;ne;ne;nd;w;nw;ne;nd;ne;w;nw;se;e;se;ne;unset brief",
	jisaiguo="set brief;fly jisaiguo;south;south;south;south;n;n;n;n;e;e;ne;e;eu;se;l east;nw;wd;w;sw;w;w;w;l south;w;l south;nu;l north;sd;w;l south;l north;w;w;l west;e;s;s;s;s;e;e;l east;open door;n;n;l west;l east;n;l west;l east;nu;ask chanshi about ɨ��;enter;u;u;u;u;u;u;u;u;u;u;u;l up;d;d;d;d;d;d;d;d;d;d;d;knock door;out;unset brief",
	tongtian="set brief;fly tongtian;north;north;north;north;north;s;w;s;w;n;w;s;s;l south;n;n;n;l north;l northwest;s;e;e;e;s;s;s;l south;n;e;ne;e;l east;l southeast;n;l west;l north;e;l northwest;l northeast;l southeast;w;s;se;bian kid;out;w;sw;w;n;w;unset brief",
	fengxian="set brief;fly yuhua;south;south;south;south;south;south;south;southwest;north;east;east;east;east;east;west;west;west;south;south;south;southwest;ne;n;n;n;n;n;n;n;n;n;n;n;e;e;se;e;ne;n;n;n;n;n;n;ne;ne;l east;sw;sw;s;w;n;l north;s;s;l south;w;n;w;l south;l north;w;n;l north;s;s;s;sw;se;ne;nw;n;n;w;l north;l south;w;l north;s;l south;w;l west;n;l north;unset brief",
	maoying="set brief;fly tianzhu;west;west;west;west;west;west;west;s;s;s;s;s;s;s;s;e;e;e;se;s;s;s;s;sw;s;se;se;sw;l southup;sw;sw;su;se;se;e;e;e;nd;ne;nw;nw;wd;l northwest;eu;se;se;say enter;unset brief",
	zhujie="set brief;fly yuhua;south;south;south;south;south;south;south;southwest;north;east;east;east;east;east;west;west;west;south;south;south;southwest;northeast;north;north;north;north;north;north;north;north;north;north;north;nw;ne;ne;ne;nu;nw;ne;nu;nw;ne;ne;e;e;e;se;sw;sd;sw;nw;l west;say �ڶ���;unset brief",
	pingding="set brief;fly pingding;north;northwest;northeast;se;se;se;l south;l northeast;e;l east;w;nw;nw;s;nw;sw;wd;sw;ne;eu;ne;s;se;sw;se;s;ed;ed;se;ne;sw;nw;wu;wu;sw;su;se;sw;sw;l southeast;su;sw;se;s;sw;l east;l southwest;ne;n;nw;ne;nd;ne;ne;nw;nd;unset brief",
	pansi="set brief;fly wudidong;northeast;northup;eastdown;se;e;e;e;n;ne;e;e;se;e;e;e;e;se;eu;ne;ed;ed;d;d;d;d;l down;u;u;u;u;wu;wu;sw;se;se;ed;e;ne;sw;w;wu;se;se;se;e;s;l west;e;l northeast;l south;w;n;w;nw;nw;w;sw;sw;ask furen about ��Ǯ;#tri �ϳ����˸���һ�Ż�Ǯ��;ne;se;e;l southdown;w;nw;ne;w;nw;w;s;s;l west;s;l southwest;n;n;n;e;se;e;e;nw;nw;nw;ne;ed;jump;e;nu;ne;nu;se;s;ne;e;l enter;se;e;e;n;nw;w;sw;w;sw;n;nw;sd;sw;sd;w;jump;wu;sw;se;se;se;se;se;e;say �ڵ�¯����ɣ���fly/jump/dive/teleport/penetrate/sink/enter����;unset brief",
	wuji="set brief;fly wuji;north;north;north;l north;l west;s;e;e;l east;l north;l south;w;w;s;s;e;s;l up;n;e;l south;e;e;e;ne;ne;sw;sw;sw;w;sw;ne;e;ne;eu;se;eu;l southup;e;se;ed;l east;wu;nw;nw;enter;n;l west;e;l north;w;s;out;s;wd;nw;wd;w;w;w;w;w;n;n;n;w;say ����ʿ;unset brief",
	qinfa="set brief;fly wudidong;westup;southdown;sw;w;w;w;w;w;w;l west;s;s;s;s;w;w;w;w;w;w;sw;l west;ne;e;e;e;n;n;l east;w;l west;e;n;n;l east;l north;w;w;w;l north;l south;w;l north;w;l west;e;e;e;n;l east;n;e;l north;e;e;l north;e;e;l northeast;l east;l southeast;unset brief",
	firemount="set brief;fly firemount;westup;southup;westup;southup;east;east;w;w;nd;ed;nd;ed;n;l northeast;nu;nu;nu;ed;nd;nd;ne;ne;wu;l westup;ed;e;e;e;l north;l south;e;se;unset brief",
	tianzhu="set brief;fly tianzhu;west;west;west;west;west;west;west;e;l south;e;l north;e;e;e;l north;e;e;l east;s;l west;s;l west;s;s;e;se;s;se;se;s;l south;sw;sw;s;w;l west;se;l south;n;n;ne;ne;n;nw;nw;n;nw;w;s;l west;s;l west;s;s;w;l north;w;l north;l south;w;sw;s;s;l south;n;n;nw;w;l south;w;l north;w;l south;n;l west;n;l west;n;l east;n;l west;n;l west;n;l east;n;l west;l east;s;s;s;e;e;l north;e;s;l west;s;l west;l east;l south;n;n;n;l north;s;e;l south;l east;w;unset brief",
	bibotan="set brief;fly jisaiguo;north;north;north;north;w;w;w;w;w;w;sw;s;se;l west;s;sw;su;wd;sd;l south;se;ed;se;e;ne;ne;l east;sw;sw;get bishui zhou from kuang;dive;n;n;nu;n;nu;l west;l east;n;n;e;e;enter;out;w;w;l north;unset brief",
	jinping="set brief;fly qinglong;sw;se;sd;se;s;se;se;s;s;s;l east;s;w;l south;e;e;l south;e;l north;e;n;l east;n;l east;l north;s;s;se;se;se;s;s;se;se;nw;nw;n;eu;e;e;l north;e;l north;e;l southeast;unset brief",
	qinglong="set brief;fly qinglong;sw;se;sd;se;l south;nw;nu;nw;ne;jump;unset brief",
	yinwu="set brief;fly wudidong;westup;southdown;sw;w;w;w;w;w;w;s;s;s;s;w;w;w;w;w;w;sw;w;w;w;sw;se;nw;ne;nw;sw;w;w;l west;e;e;ne;nw;nw;nw;w;se;ne;se;say Ҫ��ɽ��;unset brief",
	wudidong="set brief;fly wudidong;northup;eastdown;westup;southdown;sw;w;l north;w;l north;s;l south;n;w;l north;l south;w;w;l west;e;e;e;e;s;s;unset brief",
	jindou="set brief;fly tongtian;north;north;north;north;north;s;w;w;w;n;nw;w;w;sw;wu;sw;n;nw;nw;n;sw;w;sw;sd;l westdown;nu;ne;e;ne;bian yao guai;s;se;sw;bian;s;sw;l west;l southwest;ne;n;ne;unset brief",
	dudi="set brief;fly dudi;northwest;northeast;northeast;sw;se;l enter;nw;sw;se;sd;se;wd;se;ed;sw;l west;se;ne;e;l southeast;w;sw;nw;ne;wu;nw;eu;nw;nu;nw;ne;se;enter;say ɱ�˹֣���break door;unset brief",
	baihuling="set brief;w;w;w;w;w;w;w;nw;w;w;sw;w;#dummy give 2 silver to ma dao;give 2 silver to ma dao;nw;w;w;w;dismount horse;dismount shi;dismount maolu;w;su;sw;unset brief",
	baotou="set brief;fly yuhua;south;south;south;south;south;south;south;southwest;north;east;east;east;east;east;west;west;west;south;south;south;southwest;northeast;north;north;north;north;north;north;north;north;north;north;north;nw;nw;nu;nw;nw;nw;nu;nu;sd;sd;wu;wu;nw;bian diaozuan;se;ed;ed;nu;nu;ask guguai about ���ڶ�;bian;hp;unset brief"}

walk_policy = { honglou = {pre_action="set brief;w;s;#wait 3;withdraw 13 silver;#wait 3;n;e;s;w;#wait 3;buy huangliang zhen from dong;#wait 3;e;e;give 3 silver to waiter;e;sleep", start_trigger="^������������\\s\\-\\s$"} }

--��ѩɽ·��  ����ѻ��{nw;#3 n;e;w;#3 {#2 n;e};#4 n;#2 climb down;#2 climb right;#2 climb down;climb right;climb down}
--���ƶ�·��  {enter;#5 ne;#7 nw;#3 n;#2 ne;nw;#3 n}
--���ƶ�  ·�� {enter;n;n;n;ne;ne;nw;n;n}
--xx���Ǵ����йء����桻����Ϣ��
--xx��»�Ǵ����йء����桻����Ϣ
--xx�����Ǵ����йء���ź������Ϣ��

--tell xxytx help   ����
--tell letmebe help ����
--��¯��fly jump dive teleport penetrate sink enter

--ask rulai about qujing
--ask fo about book ��Ȼ�� decide
--ask fo about change ����
--ask rulai about death  �þ�����ë

--һֻ���������ž���������ͷ�ϣ�

--��ѩɽ������tell bmanb ֥�鿪��

--�̲�̶����԰��jump ��Сͤ

--�ڼ���������԰��װ�����ӣ�kan bajiao

--( ���Ѿ�һ��ͷ�ؽ����ģ������������֧���Ų�����ȥ�� )
--( ��ҡͷ���ԡ�����бб��վ��վ���ȣ��ۿ���Ҫ���ڵ��ϡ� )
--( ���Ѿ���������״̬����ʱ������ˤ����ȥ�� )
--( �����۷�ֱ���ڽ����ѣ����ǿ�ʼ���ҡ� )

--�޵׶��������⣺{#9 pull skull;push skull}
--�ݹǵ�������51��Ȼ��Ҫѧ��70�ٶ�
--unwield blade;wield bi shou;cut me;exert heal;exert heal;exert heal;exert heal;unwield bi shou;wield blade;du xue shu
--�����ġ����Ʒ�(Quezizai)����Ч100����Բ�enforce ��������ȥ��̨��˯�����Դ�Ҳ��ô���СС�׽�ȥ��
--�����Ǯ����ͷ��Ȼ����ʦ����СС�״Ӻ�¥�α����ȥ

--��һ���ˣ�ȥ�������˻ָ���qn��������
--�龭������ tell rascal

--����¼��retrieve zishou lu to xxx

--ǧ��  ��100��1000�֡��ȼ���10��20��30��60��100��150��210��280��360��450

--��ѧ  ��ѧէ�� 0 �����ž� 338 ��ͨƤë 2700 ��֪һ�� 9113
--        �������� 21600 ������ 42188 ����С�� 72900 ����Ѿ� 115763
--        ������� 172800 ��Ȼ���� 246038 ������� 337500
--        ������� 449213 ����似 583200 �����뻯741488
--        ��Ȼ��ͨ 926100 �Ƿ��켫 1139063 ������˫ 1382400
--        һ����ʦ 1658138 ������ 1968300 ��ɲ� 2314913
--����  ���߷��� 0  �����仯 40  �������� 160  ���Ƽ��� 360  �����û 640
--         Ԥ֪���� 1000  ������� 1440  ���绽�� 1960  ������ɽ 2560
--         ���ǻ��� 3240  �������� 4000  Sui������ 4840 �任Ī�� 5760  �����ޱ� 6760
--����  �����; 0  �ŵ���ϲ 2  ������� 16  ��ͨ���� 54  ����Ѿ� 128
--         Ԫ����� 250  �����ȹ� 432  һ��ǧ�� 686 ���ߵ�¡ 1024
--         ��̥���� 1458  ϼ�ٷ��� 2000  �������� 2662 �����ֻ� 3456
--          ��֤��� 4394  ��豹�ՠ5488  ���˺�һ 6750
