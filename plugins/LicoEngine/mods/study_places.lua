--Module: study_places.lua
--����ѧϰ�ص�Ĳ���


study.places = {"xajh","han", "aolai", "bingmayong", "beilin","beilin2", "bobufen", "change",
			"gao", "luohanta", "shouxing", "taiyin",
			"tianjiantai", "tianmotai", "wangmu", "xueshan", "yunfang", "yushu", "temp"}

study.places.execroom_to_restroom = { 
			xajh="set brief;e;e;unset brief",				--Ц������
			han="set brief;nd;w;w;n;n;n;n;e;unset brief",		--������
			aolai="",			--����
			bingmayong="",	--����ٸ
			beilin="",			--examine bei�ı���
			beilin2="",		--touch gui�ı���
			bobufen="",		--𫲻��
			change="",		--�϶�
			luohanta="",		--�޺���
			shouxing="",		--����
			taiyin="",			--̫�����
			tianjiantai="",		--�콣̨
			tianmotai="",		--��ħ̨
			wangmu="",		--����ĸ
			xueshan="",		--ѩɽ���Ĺ㳡
			yunfang="",		--�Ʒ�lianwu
			yushu="",			--����
			temp=""}

study.places.restroom_to_execroom = {xajh="set brief;w;w;unset brief",
			han="set brief;w;s;s;s;s;e;e;su;unset brief",
			aolai="",
			bingmayong="",
			beilin="",
			beilin2="",
			bobufen="",
			change="",
			gao="",
			luohanta="",
			shouxing="",
			taiyin="",
			tianjiantai="",
			tianmotai="",
			wangmu="",
			xueshan="",
			yushu="",
			yunfang="",
			temp=""}

--w;w;w;w;w;w;w;nw;w;w;sw;w;give 2 silver to ma dao;nw;w;nu;n;nu;nw;n;nu;nu;nu;n;nu
--13s 10w (nw) (nu) n (nu) (ne) (ne) (nu) (nu) n
study.places.quit_action = {xajh="set brief;s;s;s;su;sd;s;out;sd;w;n;n;n;n;n;e;u;u;save;unset brief",
			han="set brief;nd;w;sd;s;sd;sd;sd;s;se;sd;s;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;s;e;u;u;save;unset brief",
			aolai="",
			bingmayong="w;w;sw;nw;w;sw;w;n;n;n;e;u;u;save",
			beilin="s;e;ne;n;w;w;w;s;e;u;u;save",
			beilin2="s;s;e;ne;n;w;w;w;s;e;u;u;save",
			bobufen="north;north;s;sw;s;s;sd;sd;sw;sw;sd;s;sd;se;e;e;e;e;e;e;e;e;e;e;n;n;n;n;n;n;n;n;n;n;n;n;e;u;u;save",
			change="e;e;s;s;s;out;d;d;d;sd;ed;ed;nd;nd;ed;e;se;se;se;sw;se;e;e;e;e;e;e;e;s;e;u;u;save",
			luohanta="",
			shouxing="sd;#dummy fly changan;fly changan;s;e;u;u;save",
			taiyin="s;s;s;out;d;d;d;sd;ed;ed;nd;nd;ed;e;se;se;se;sw;se;e;e;e;e;e;e;e;s;e;u;u;save",
			tianjiantai="e;s;s;e;u;u;save",
			tianmotai="pa down;out;u;s;s;s;s;s;u;#dummy fly changan;fly changan;s;e;u;u;save",
			wangmu="e;s;e;s;s;s;out;d;d;d;sd;ed;ed;nd;nd;ed;e;se;se;se;sw;se;e;e;e;e;e;e;e;s;e;u;u;save",
			xueshan="#dummy fly changan;fly changan;s;e;u;u;save",
			yunfang="n;nw;nw;w;w;sw;w;w;u;w;w;w;n;n;n;n;n;n;n;n;n;n;n;n;n;n;n;e;u;u;save",
			yushu="s;s;s;s;s;u;tell dumy fly changan;fly changan;s;e;u;u;save",
			temp=""}

study.places.feed_action = {xajh="s;w;chihe;e;n",
			han="",
			aolai="",
			bingmayong="",
			beilin="",
			beilin2="",
			bobufen="",
			change="",
			luohanta="",
			shouxing="",
			taiyin="",
			tianjiantai="",
			tianmotai="",
			wangmu="",
			xueshan="",
			yunfang="",
			yushu="",
			temp=""}

study.places.escape_path = {
			xajh="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;s;s;s;s;s;s;e;nu;xajh;n;nu;nd;n;n;n;unset brief",
			han="",
			aolai="",
			bingmayong="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;e;e;e;s;sw;s;se;ne;e;e;unset brief",
			beilin="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;e;e;e;s;sw;w;n;unset brief",
			beilin2="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;e;e;e;s;sw;w;n;n;unset brief",
			bobufen="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;s;s;s;s;s;s;s;s;s;s;s;s;s;w;w;w;w;w;w;w;w;w;w;nw;nu;n;nu;ne;ne;nu;nu;n;n;ne;unset brief",
			change="",
			luohanta="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;s;e;u;u;save;unset brief",
			shouxing="",
			taiyin="",
			tianjiantai="",
			tianmotai="",
			wangmu="",
			xueshan="",
			yunfang="set brief;out;wd;sd;e;se;e;ne;e;e;se;e;e;e;e;e;e;e;s;s;s;s;s;s;s;s;s;s;s;s;s;s;s;s;e;e;e;dive;#wait 3;e;e;ne;e;e;se;se;s;unset brief",
			yushu="",
			temp=""}