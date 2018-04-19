--
-- Author: liangzhaowei
-- Date: 2017-06-19 15:11:12
-- 活动数据
local Goods = require("app.data.Goods")

local Activity = class("Activity", Goods)
--en_get_state_type.canget
en_get_state_type = {
	cannotget = 1, --不可领取
	canget   = 2, --可以领取
	haveget = 3 , --已经领取
	null = 4, --不需要显示
}
--e_id_activity.firstrecharge
e_id_activity = {
    --活动a
	nanbeiwar         		=     1001          ,   --南征北战
	countryfight 	   		=     1002 			,   --国战排行	
	expeditefuben     		=     1003          ,   --副本加速(副本掉落)
	expediteworkshop  		=     1004          ,   --工坊加速
	forgerank 		   		=     1005			, 	--锻造排行
	doubleexp         		=     1006          ,   --翻倍经验
	expeditenemy      		=     1007          ,   --乱军加速
	dayrebate 	   	   		=	  1008 			,	--每日返利
	foodstore 		   		= 	  1009 			, 	--屯粮排行
	armyrank           		=     1010 			, 	--兵力排行
	consumegift        		=     1011          ,   --消费好礼
	enemyremoval      		=     1013          ,   --敌军迁城
	doublecollect     		=     1014          ,   --采集翻倍
	succinctrank 	   		= 	  1015			,   --洗练排行
	enemydrawing      		=     1016          ,   --乱军图纸
	expediteproducts  		=     1017          ,   --物产加速
	enemyresource     		=     1018          ,   --乱军资源
	ironstore 		   		=	  1019 			, 	--屯铁排行
	cityfight 		   		=	  1020 			, 	--城战排行
	giftrecharge      		=     1021          ,   --礼包兑换                
	sevendaylog        		=     1022          ,   --七天登录
	totalrecharge 	   		=	  1023 			,	--累计充值
	sevenking 		   		=     1024 			, 	--七日登基
	eatchicken         		=     1025          ,   --每日吃鸡
	redpacket				=     1026 			, 	--红包馈赠 
	phonebind       		=     1027          ,   --手机绑定        
	freecall				=     1028 			, 	--免费召唤 
	magiccrit				=     1029 			, 	--神兵暴击
	palacecollect			=     1030 			, 	--王宫采集
	onlinewelfare			=	  1031          ,	--在线福利
	energydiscount			=	  1032 			, 	--体力折扣
	doubleegg				=	  1033          ,	--双旦活动
	rechargesign			=	  1034			, 	--充值签到
	packetgift              =     1035    		,   --特惠礼包(送审用)
	equipmake				=	  1036			,   --装备打造
	herocollect				=     1037  		,   --武将收集
	fubenpass				=	  1038			,   --副本推进
	playerlvup				=	  1039			,   --主公升级
	equiprefine				=	  1040			,   --装备洗炼
	blueequipmake			=	  1041			,   --打造蓝装
	artifactmake			=	  1042			,   --神器升级
	attackvillage			=     1043  		,   --攻城拔寨
	nationpillars			= 	  1044 			, 	--国家栋梁    
	realnamecheck			= 	  1045 			, 	--实名认证
	regress					= 	  1046			, 	--回归有礼

	--活动b
	growthfound        		=     2001          ,	--成长基金
	updateplace        		=     2002          ,	--王宫升级
	specialsale        		=     2003          ,   --特价卖场
	firstrecharge      		=     2004          ,   --首冲好礼
	blessworld 	   	   		=	  2005 			,	--福泽天下
	peoplerebate	   		=     2006          ,   --全民返利
	heromansion 	   		=	  2007 			, 	--登坛拜将
	consumeiron        		=     2008          ,   --耗铁有礼
	farmtroopsplan     		=     2009          ,   --屯田计划
	snatchturn         		=     2010          ,   --夺宝转盘
	acttreasureshop    		=     2011          ,   --珍宝阁
	freebenefits 	   		=	  2012 			,	--免费福利
	dayloginaward      		=     2013          ,   --每日收贡
	wuwang             		=     2014          ,   --武王讨伐
	dragontreasure 			=     2015 			, 	--寻龙夺宝
	laba 					=	  2017 			,	--腊八拉霸
	newgrowthfound 			= 	  2018 			,	--新版成长基金
	everydaypreference		=	  2019			, 	--每日特惠
	searchbeauty			=	  2020 			, 	--寻访美人
    exam                    =     2021          ,   --每日抢答
	luckystar				=	  2022 			,	--福星高照
	nianattack				=	  2023 			,	--年兽来袭
	mothcard				=	  2024 			,	--月卡入口
	mingjie					=	  2016 			, 	--冥界入侵
	monthweekcard 			=     2025			, 	--周卡月卡
	sciencepromote 			= 	  2026			,   --科技兴国
	tlboss                  =     2027          ,   --魔神来袭
	zhouwangtrial 			= 	  2028			, 	--纣王试炼
	developgift    			= 	  2029 			, 	--发展礼包
	welcomeback    			= 	  2030 			, 	--王者归来

	newfirstrecharge      	=     3001          ,   --新首充好礼
	royaltycollect	 		= 	  3002			, 	--王权征收
	severalrecharge			=	  3003			, 	--多次首充
	wuwangforcast 			=	  3004 			,	--武王预告
	attackcity 				=	  3006 			,	--攻城掠地
	newroyaltycollect		=     3007 			,   --新王权征收


	triggergift             =     1000000000    ,   --前端自己写当做入口
}

function Activity:ctor(eType)
	Activity.super.ctor(self,e_type_goods.type_activity)
	-- body
	self:myInit()
	self.nId = eType or e_id_activity.limitshop
	self:initDatasByDB()

end



function Activity:myInit( )

	-- 基本信息
    self.nId             	      =      0  --活动ID          	    
    self.sName	         	      =      ""  --活动名称      
    self.sTitle	         	      =      0  --活动副标题 
    self.nType	         	      =      0  --活动计时类型  (3永久类型,其它剩余时间与领奖时间切换)
    self.nActivityOpenTime 	      =      0  --活动开启时间        
    self.nActivityCloseTime	      =      0  --活动关闭时间    	  
    self.nActivityEndTime      	  =      0  --活动移除时间        	    
    self.nOrder	         	      =      0  --排序      
    self.sDesc	         	      =      ""  --描述内容
    self.nRemainTime              =      0      --剩余时间
    self.nUiVer					  = 	 0  --UI版本，0为旧UI,1为新UI,默认为0
    
    --读表字段
    self.sIcon 					  = 	 "ui/daitu.png"   --图标
    self.sIconBg 				  = 	 "ui/daitu.png"   --图标背景
    self.tBanners 				  = 	 nil  --banner图
    self.sRule                    =      ""   --活动规则   
    self.nTips                    =      0   --登陆时红点提示 0活动开启时提示 1登陆提示
    self.tSubtitle                =      {}  --目标标题


    --额外信息
	self.nLoginState              =      0     --0为原始状态 1为已经转换成红点 2已经点击
 --    self.bIsLogin                 =      false --初始化为 false
	self.nLoginRedNums   		  =		 0     --登录红点数
	self.nRefreshLoginTime        =      0     --刷新重置活动的时间
	self.tParam                   =      nil   --活动参数

	--是否是新开启
	self.bIsNew = false
end

--读取配表中的字段
function Activity:initDatasByDB()
	if self.nId then
		local tActTemp = getActivityByIdAndVer(self.nId, 1)
		self:refreshActParam(tActTemp)
	end
end

function Activity:refreshActParam(tActTemp)
	if tActTemp then
		if tActTemp.regulation then
			self.sRule = tActTemp.regulation
		end
		if tActTemp.icon then
			self.sIcon = "#"..tActTemp.icon..".png"
		end
		if tActTemp.iconbg then
			self.sIconBg = "#"..tActTemp.iconbg..".png"
		end
		--登陆时红点提示
		if tActTemp.tips then
			self.nTips = tActTemp.tips
		end
		--banner
		self.tBanners = nil
		if tActTemp.banner and #tActTemp.banner > 0 then
			if self.tBanners == nil then
				self.tBanners = {}
			end
			local tTemp = luaSplit(tActTemp.banner, ";")
			if tTemp and table.nums(tTemp) > 0 then
				for k, v in pairs (tTemp) do
					local sBanner = "#" .. v .. ".jpg"
					table.insert(self.tBanners, sBanner)
				end
			end
		end

	    self.sName	         	      =  tActTemp.name               or  self.sName	          --活动名称      		 
	    self.sTitle	          	      =  tActTemp.title	             or  self.sTitle	      --活动副标题 		
	    self.sDesc	         	      =  getTextColorByConfigure(tActTemp.desc)     or  self.sDesc           --内容          	  
	    self.tParam                   =  tActTemp.param              or  self.param           --参数
  		self.tSubtitle                =  self:anlaysisSubtitle(tActTemp.subtitle)   --目标标题.
	end
end

-- 读取服务器中的数据
function Activity:refreshActService(_tData)
	if not _tData then
		return
	end
    self.nId             	      =  _tData.id	              or  self.nId             	--活动ID         			    
    self.nType	         	      =  _tData.ty	              or  self.nType	         --活动计时类型  		
    self.nActivityOpenTime 	      =  _tData.st                 or  self.nActivityOpenTime  --活动时间      		   
    self.nActivityCloseTime	      =  _tData.et                 or  self.nActivityCloseTime --活动关闭时间  		   	  
    self.nActivityEndTime      	  =  _tData.rt	              or  self.nActivityEndTime   --活动移除时间
	self.nRemainTime      	      =  _tData.rs	              or  self.nRemainTime       --剩余时间     			    
  
    self.nOrder	         	      =  _tData.order	          or  self.nOrder	         --排序      		
    self.nUiVer	 				  =  _tData.uiVer 			  or  self.nUiVer		      --UI版本，0为旧UI,1为新UI,默认为0
    self.nParamVer 				  =  _tData.parVer 			  or self.nParamVer 		 --参数版本


    --记录刷新活动时间的时间
    if _tData.et then
    	self.nRefreshLoginTime        =      getSystemTime()
    end

    if self.nParamVer then
	    local tActTemp = getActivityByIdAndVer(self.nId, self.nParamVer)
	    self:refreshActParam(tActTemp)
	end


    -- self.nHaveGet 				  =  _tData.haveGet            or  self.nHaveGet          --红点数
    --这个是前端在新增活动中添加的状态
    -- self.nLoginState              =  _tData.loginState            or  self.nLoginState

    --如果时间更改就从本地数据中获取是否存在的标记
    if self.nPrevOpenTime ~= self.nActivityOpenTime then
    	self.nPrevOpenTime = self.nActivityOpenTime
    	self:initNewLocal()
    end
end

--获取活动开启时间段字符串
function Activity:getStrActTime()
	local sStrOpenTime = formatTimeMDM(self.nActivityOpenTime,true)  --活动内时间
	local sStrCloseTime = formatTimeMDM(self.nActivityCloseTime,true)
	local sActDate = sStrOpenTime.." - "..sStrCloseTime

	local sActLeftTime = ""
	local sActTime =  getConvertedStr(5, 10192) --活动时间


	sActTime = sActTime..sActDate

	return sActTime
end

--获取活动开启时间段字符串 bCn 是否中文字符
-- true 2017年12月2日 至 2017年12月10日
-- false 2017.12.2 - 2017.12.10
function Activity:getStrActTimeYear(_bCn)
	local bCn = false
	local strBt = " - "
	if _bCn then
		bCn = _bCn
		strBt = getConvertedStr(5, 10197)
	end
	local sStrOpenTime = formatTimeYMD(self.nActivityOpenTime,bCn)  --活动内时间
	local sStrCloseTime = formatTimeYMD(self.nActivityCloseTime,bCn)
	local sActDate = sStrOpenTime..strBt..sStrCloseTime

	return sActDate
end

--获取活动剩余时间
function Activity:getRemainTime()
	local sTime = ""
	sTime = getConvertedStr(5, 10210)
	if self.nId == e_id_activity.newgrowthfound then
		sTime = getConvertedStr(7, 10295) 	--限购时间:
		if self:getIsDuringCd() then
			sTime = sTime..getTimeLongStr(self:getGrowFoundLimitCd(),false,true)
		end
	else
		if self.nType == 3 then
			sTime = getConvertedStr(5, 10199)
		else
			local nNowTime = getSystemTime()
			local nTime  = self.nRemainTime - (nNowTime-self.nRefreshLoginTime)
			sTime = "(".. sTime..getTimeLongStr(nTime,false,true)..")"
		end
	end
	return sTime
end

--获取活动剩余时间
function Activity:getRemainCd()
	if self.nRemainTime and self.nRefreshLoginTime then
		local nNowTime = getSystemTime()
		local nTime = self.nRemainTime - (nNowTime-self.nRefreshLoginTime)
		if nTime < 0 then
			nTime = 0
		end
		return nTime
	end
	return nil
end

--获取活动剩余时间(缩减版)
function Activity:getSortRemainTime()
	local sTime = ""
	local nNowTime = getSystemTime()
	local nTime  = self.nRemainTime - (nNowTime-self.nRefreshLoginTime)
	sTime = getConvertedStr(5, 10210)..formatTimeToDHM(nTime)

	return sTime
end
--获取活动剩余时间2   活动剩余时间：1D:12:24:22
function Activity:getRemainTime2()
	local sTime = ""
	sTime = getConvertedStr(9, 10130)
	if self.nId == e_id_activity.newgrowthfound then
		sTime = getConvertedStr(7, 10295) 	--限购时间:
		if self:getIsDuringCd() then
			sTime = sTime..getTimeLongStr(self:getGrowFoundLimitCd(),false,true)
		end
	else
		if self.nType == 3 then
			sTime = getConvertedStr(5, 10199)
		else
			local nNowTime = getSystemTime()
			local nTime  = self.nRemainTime - (nNowTime-self.nRefreshLoginTime)
			sTime = sTime..getTimeLongStr(nTime,true,false,true)
		end
	end
	return sTime
end




--活动结束时间
function Activity:getCloseTime()

  local nNowTime = getSystemTime()
  local nTime  = self.nActivityCloseTime - (nNowTime-self.nRefreshLoginTime)
  
  if nTime < -1 then
    nTime = -1
  end
  return nTime
end

--活动移除时间
function Activity:getRemoveTime()

  local nNowTime = getSystemTime()
  local nTime  = self.nActivityEndTime - (nNowTime-self.nRefreshLoginTime)
  
  if nTime< -1 then
    nTime = -1
  end

  return nTime
end


--活动是否在开启状态
function Activity:isOpen()
	local bOpen = false
	if self:getCloseTime() > 0 then
		bOpen = true
	end
	return bOpen
end

--解析副标题 _str
function Activity:anlaysisSubtitle(_str)
	local tStr = {}
	if luaSplit(_str,"&") then
		tStr = luaSplit(_str,"&") or {}
	end
	return tStr
end

--从本地数据查找新的标识
function Activity:initNewLocal(  )
	if not self.nId then
		return
	end

	--key:玩家id_活动id_new：value:起始时间
	local sLocal = getLocalInfo(string.format("%s_%s_new",Player:getPlayerInfo().pid, self.nId), "")
	--空错
	if not sLocal then
		self.bIsNew = true
		return
	end

	--没有值
	if sLocal == "" then
		self.bIsNew = true
		return
	end

	--与记录的时间比较
	local nStartTime = tonumber(sLocal)
	if nStartTime == self.nActivityOpenTime then
		self.bIsNew = false
	else
		self.bIsNew = true
	end
end

--获取是否新的标识
function Activity:getIsNew( )
	return self.bIsNew
end

--将新的标识记录本地
function Activity:setNewLocal( )
	if self.bIsNew == true then
		self.bIsNew = false
		--记录本地数据
		if self.nActivityOpenTime then
			--Player:addActivityNew(string.format("%s_%s_new", Player:getPlayerInfo().pid, self.nId), tostring(self.nActivityOpenTime))
			saveLocalInfo(string.format("%s_%s_new",Player:getPlayerInfo().pid, self.nId), tostring(self.nActivityOpenTime))
		end
	end
end

--获取时间显示格式状态
function Activity:getTimeShowType(  )
	if self.nId == e_id_activity.newgrowthfound then
		if self:getIsDuringCd() then
			return e_ac_time_type.limit
		end
	end
	if self.nType == 3 then
		return e_ac_time_type.forerver
	end
	return e_ac_time_type.normal
end

return Activity
