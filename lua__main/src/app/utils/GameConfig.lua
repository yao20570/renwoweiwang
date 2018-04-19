----------------------------------------------------- 
-- author: xieruidong
-- updatetime: 2017-01-12 18:12:52 
-- Description: 游戏配置类，用来保存一些开关什么的
-----------------------------------------------------

f_outtime_http_wifi = F_OUTTIME_HTTP_LANU -- http在wifi下连接超时时长（配置在launcher中）
f_outtime_http_net = F_OUTTIME_HTTP_LANU*1.5 -- http在net下连接超时时长
f_outtime_socket_wifi = 6 -- socket在wifi下连接超时时长
f_outtime_socket_net = 8 -- socket在net下连接超时时长
f_outtime_checknet = 4 -- 判断网络状态的超时时间
f_outtime_connect_socket = 2 -- socket建立连接时的超时时间
f_outtime_reconnect = 10 -- 重连的超时时间
f_outtime_count_socket = 2 -- 尝试3次连接socket
f_delaytime_loading = 1 -- 延迟显示loading框的时间
n_last_background_time = 0 -- 最后暂停游戏的时间
n_last_foreground_time = 0 -- 最后恢复游戏的时间
f_outtime_login = 6 --登录的时候请求协议超时
n_last_collect_time = 0 --最后回收table数据的时间 

b_is_white_account = false -- 是否为白名单帐号
n_s_switches_tag_fubiao = 1001 -- sdk浮标开关控制tag值

b_open_far_and_near_view_forworld = true -- 是否开发世界远近视角
b_open_texture_cutquality = true --是否开放分类型加载不同纹理，会降低部分品质
b_open_viewpool = true -- 是否开启控件缓存池的使用
b_force_close_filldlg_enter_action = true --是否强行关闭全屏对话框进场动画
b_open_recharge = true -- 是否开放充值
b_open_scroll_hide_suburb = false --是否开启拖动基地隐藏资源田标题和名字
b_use_sec_fightlayer = true --是否使用第二本战斗表现
b_open_ui_cach	= true	--是否开启界面缓存

n_start_suburb_cell = 1000 --郊外建筑（资源田）开始下标
nCollectCnt = 0 --数据回收次数

b_open_guide = true --是否开启新手引导

b_open_world_help = true --是否开启世界玩法说明

b_close_paritcle_of_android = (device.platform == "android") --安卓关闭不是必要的特效
n_GMT = 3600 * 24 - os.time({year =1970, month = 1, day =1, hour = 24})

b_open_ios_shenpi = false --是否是ios审批

b_open_overview = false --是否开启总览
b_close_imperialwar = false --是否屏蔽皇城战

b_show_load_texture_info = true --开启打印图片加载信息

-- 判断是否为vivo渠道
function isVivo(  )
	if(AccountCenter.subcid and tonumber(AccountCenter.subcid) == 22) then
		return true
	end
	return false
end

