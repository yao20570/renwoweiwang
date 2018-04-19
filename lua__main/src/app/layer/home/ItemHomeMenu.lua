-----------------------------------------------------
-- author: wangxs
-- updatetime:  
-- Description: 
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemHomeMenu = class("ItemHomeMenu", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemHomeMenu:ctor(  )
	-- body
	self:myInit()
	parseView("item_home_menu", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemHomeMenu:myInit(  )
	-- body
	self.nIndex 		=		 nil     --标志功能类型
end

--解析布局回调事件
function ItemHomeMenu:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("ItemHomeMenu",handler(self, self.onItemHomeMenuDestroy))
end

--初始化控件
function ItemHomeMenu:setupViews( )
	-- body

	--点击层
	self.pLayClick 			= 		self:findViewByName("lay_item")
	self.pLayClick:setViewTouched(true)
	self.pLayClick:setIsPressedNeedScale(false)
	self.pLayClick:onMViewClicked(handler(self, self.onMenuClicked))
	--图片
	self.pImg 				= 		self:findViewByName("img_menu")
	--名字
	-- self.pLbName 			= 		self:findViewByName("lb_menu")
	-- setTextCCColor(self.pLbName,_cc.dblue)
	--红点层
	self.pLyRed         =       self:findViewByName("ly_red") 
end

function ItemHomeMenu:onResume(  )
	self:regMsgs()
end

function ItemHomeMenu:onPause(  )
	self:unregMsgs()
end

function ItemHomeMenu:regMsgs( )
	regMsg(self, ghd_refresh_playerinfo_country, handler(self, self.updateCountry))
	--通用红点消息
	regMsg(self, ghd_item_home_menu_red_msg, handler(self, self.updateRedNum))
	--任务红点消息
	regMsg(self, ghd_task_home_menu_red_msg, handler(self, self.updateRedNum))
	--国家红点消息
	regMsg(self, ghd_country_home_menu_red_msg, handler(self, self.updateRedNum))
	--装备变化消息
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.updateRedNum))
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateRedNum))
	--背包物品变化消息
	regMsg(self, gud_refresh_baginfo, handler(self, self.updateRedNum))	
	--玩家资源变化
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateRedNum))
	--膜拜红点
	regMsg(self, ghd_mobai_red_msg,handler(self, self.updateRedNum))
	--神兵信息变化
	regMsg(self, gud_refresh_weaponInfo, handler(self, self.updateRedNum))
	--国家互助数据变化
	regMsg(self, gud_refresh_countryhelp, handler(self, self.updateRedNum))
	--国家任务数据变化
	regMsg(self, gud_refresh_countrytask, handler(self, self.updateRedNum))
	--国家宝藏数据变化
	regMsg(self, ghd_refresh_country_treasure, handler(self, self.updateRedNum))
end

function ItemHomeMenu:unregMsgs( )
	unregMsg(self, ghd_refresh_playerinfo_country)		
	unregMsg(self, ghd_item_home_menu_red_msg)
	unregMsg(self, ghd_task_home_menu_red_msg)
	unregMsg(self, ghd_country_home_menu_red_msg)	
	unregMsg(self, gud_equip_hero_equip_change)	
	unregMsg(self, gud_refresh_hero)
	unregMsg(self, gud_refresh_baginfo)				
	unregMsg(self, gud_refresh_playerinfo)	
	unregMsg(self, ghd_mobai_red_msg)
	unregMsg(self, gud_refresh_weaponInfo)
	unregMsg(self, gud_refresh_countryhelp)
	unregMsg(self, gud_refresh_countrytask)
	unregMsg(self, ghd_refresh_country_treasure)
end

-- 修改控件内容或者是刷新控件数据
function ItemHomeMenu:updateViews(  )
	-- body
	if self.nIndex then
		if self.nIndex == e_home_bottom.hero then 								--武将
			-- self.pLbName:setString(getConvertedStr(1,10202))
			self.pImg:setCurrentImage("#v2_img_zjm_wujiang.png")
			--新手引导设置入口
			Player:getNewGuideMgr():setNewGuideFinger(self.pLayClick, e_guide_finer.hero_enter_btn)

		elseif self.nIndex == e_home_bottom.copy then 							--副本
			-- self.pLbName:setString(getConvertedStr(1,10203))
			self.pImg:setCurrentImage("#v2_img_zjm_fuben.png")
			--新手引导设置入口
			Player:getNewGuideMgr():setNewGuideFinger(self.pLayClick, e_guide_finer.fuben_enter_btn)
		elseif self.nIndex == e_home_bottom.country then 							--国家
			-- self.pLbName:setString(getConvertedStr(1,10205))
			self:updateCountry()
			--新手引导设置入口
			Player:getNewGuideMgr():setNewGuideFinger(self.pLayClick, e_guide_finer.country_enter_btn)
		elseif self.nIndex == e_home_bottom.mail then 							--邮件
			-- self.pLbName:setString(getConvertedStr(1,10194))
			self.pImg:setCurrentImage("#v2_img_zjm_youjian.png")	
		elseif self.nIndex == e_home_bottom.bag then 							--背包
			-- self.pLbName:setString(getConvertedStr(1,10206))
			self.pImg:setCurrentImage("#v2_img_zjm_beibao.png")		
		elseif self.nIndex == e_home_bottom.godweapon then 							--神兵
			-- self.pLbName:setString(getConvertedStr(1,10232))
			self.pImg:setCurrentImage("#v2_img_zjm_shenbing.png")					
			--新手引导设置入口
			Player:getNewGuideMgr():setNewGuideFinger(self.pLayClick, e_guide_finer.gequip_enter_btn)	
		elseif self.nIndex == e_home_bottom.task then 							--任务
			-- self.pLbName:setString(getConvertedStr(1,10204))
			self.pImg:setCurrentImage("#v2_img_zjm_renwu.png")
		elseif self.nIndex == e_home_bottom.friend then 							--好友
			--self.pLbName:setString(getConvertedStr(1,10208))
			self.pImg:setCurrentImage("#v2_img_zjm_haoyou.png")
		elseif self.nIndex == e_home_bottom.rank then 							--排行榜
			-- self.pLbName:setString(getConvertedStr(1,10209))
			self.pImg:setCurrentImage("#v2_img_zjm_paihang.png")
		elseif self.nIndex == e_home_bottom.setting then 							--设置
			-- self.pLbName:setString(getConvertedStr(1,10210))
			self.pImg:setCurrentImage("#v2_img_zjm_shezhi.png")
		-- elseif self.nIndex == 11 then 							--商队
		-- 	self.pLbName:setString(getConvertedStr(1,10243))
		-- 	self.pImg:setCurrentImage("#v1_img_zjm_wujiang.png")
		end
	end
	self:updateRedNum()
end

--更新国家图标
function ItemHomeMenu:updateCountry(  )
	if self.nIndex == e_home_bottom.country then 							--国家
		local sImg = "#v2_img_zjm_guojiachu.png"
		if Player:getPlayerInfo().nInfluence == e_type_country.wuguo then--玩家所在国家
			sImg = "#v2_img_zjm_guojiachu.png"
		elseif Player:getPlayerInfo().nInfluence == e_type_country.shuguo then
			sImg = "#v2_img_zjm_guojiahan.png"
		elseif Player:getPlayerInfo().nInfluence == e_type_country.weiguo then
			sImg = "#v2_img_zjm_guojiaqin.png"
		end
		self.pImg:setCurrentImage(sImg)
	end
end

--更新红点
function ItemHomeMenu:updateRedNum()
	-- body
	local nRedNum = 0
	--清理红点
	showRedTips(self.pLyRed,1,0)
	if self.nIndex == e_home_bottom.hero then 								--武将
		nRedNum = Player:getHeroInfo():getHomeMenuRedNum()
		showRedTips(self.pLyRed,0,nRedNum)		
	elseif self.nIndex == e_home_bottom.copy then 							--副本

	elseif self.nIndex == e_home_bottom.country then 							--国家
		local tCountryData = Player:getCountryData()
		if tCountryData then
			nRedNum = tCountryData:getCounrtyMenuRedNum()			
		end
		showRedTips(self.pLyRed,0,nRedNum)
	elseif self.nIndex == e_home_bottom.mail then 							--邮件
		local nRedNum = Player:getMailData():getNotReadNumsAll()
		showRedTips(self.pLyRed,1,nRedNum)
	elseif self.nIndex == e_home_bottom.bag then 							--背包
		local nRedNum = Player:getBagInfo():getBagRedNum()
		showRedTips(self.pLyRed,1,nRedNum)
	elseif self.nIndex == e_home_bottom.godweapon then 							--神器
		local nRedNum = Player:getWeaponInfo():getHomeMenuRedNum()
		showRedTips(self.pLyRed,0,nRedNum)
	elseif self.nIndex == e_home_bottom.task then 							--任务		
		nRedNum = Player:getPlayerTaskInfo():getTaskMenuRed()		
		showRedTips(self.pLyRed,1,nRedNum)		
	elseif self.nIndex == e_home_bottom.friend then 							--好友
		nRedNum = Player:getFriendsData():getHomeMenuRedNum()
		showRedTips(self.pLyRed,0,nRedNum)
	elseif self.nIndex == e_home_bottom.rank then 							--排行榜

	elseif self.nIndex == e_home_bottom.setting then 							--设置

	elseif self.nIndex == 11 then 							--商队

	end
		
end

-- 析构方法
function ItemHomeMenu:onItemHomeMenuDestroy(  )
	self:onPause()
end

--设置当前类型
function ItemHomeMenu:setCurIndex( _nIndex )
	-- body
	self.nIndex = _nIndex
	self:updateViews()
end

--点击事件
function ItemHomeMenu:onMenuClicked( pView )
	if self.nIndex == e_home_bottom.hero then --武将
		local tObject = {} 
		tObject.nType = e_dlg_index.dlgherolineup --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)

		--新手引导
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG ItemHomeMenu 武将事件点击回调")
		end
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayClick)

	elseif self.nIndex == e_home_bottom.copy then 							--副本
		-- local tObject = {}
		-- tObject.nType = e_dlg_index.fubenlayer --dlg类型
		-- sendMsg(ghd_show_dlg_by_type,tObject)
		local tObject = {}
		tObject.nType = e_dlg_index.fubenmap --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)

		--新手引导
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG ItemHomeMenu 副本点击回调")
		end
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayClick)	  
	elseif self.nIndex == e_home_bottom.country then 					--国家	
		local tObject = {}
		tObject.nType = e_dlg_index.dlgcountry --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)     
		--新手引导
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG ItemHomeMenu 副本点击回调")
		end
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayClick)	  
	elseif self.nIndex == e_home_bottom.mail then 							--邮件
    	local tObject = {}
		tObject.nType = e_dlg_index.mail --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif self.nIndex == e_home_bottom.bag then 							--背包
    	local tObject = {}
		tObject.nType = e_dlg_index.bag --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	elseif self.nIndex == e_home_bottom.godweapon then 							--神兵
		local tObject = {}
		tObject.nType = e_dlg_index.dlgweaponmain --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
		--新手引导
		if B_GUIDE_LOG then
			print("B_GUIDE_LOG ItemHomeMenu 副本点击回调")
		end
		Player:getNewGuideMgr():onClickedNewGuideFinger(self.pLayClick)	   
	elseif self.nIndex == e_home_bottom.task then 							--任务
    	local tObject = {}
		tObject.nType = e_dlg_index.dlgtask --dlg类型		
		sendMsg(ghd_show_dlg_by_type,tObject)  	
	elseif self.nIndex == e_home_bottom.friend then 							--好友
		local tObject = {}
		tObject.nType = e_dlg_index.dlgfriends --dlg类型
		--tObject.nType = e_dlg_index.dlgfriendselect --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)		
	elseif self.nIndex == e_home_bottom.rank then 							--排行榜
    	local tObject = {}
		tObject.nType = e_dlg_index.dlgrank --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)		
	elseif self.nIndex == e_home_bottom.setting then 							--设置
		local tObject = {}
		tObject.nType = e_dlg_index.dlgsettingmain --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)		
	-- elseif self.nIndex == 11 then 							--商队
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.dlgmerchants --dlg类型
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)
		-- local tObj = {}
		-- tObj.nType = 2
		-- sendMsg(ghd_refresh_homeitem_msg, tObj)
	end
end


function ItemHomeMenu:setGuideFingerUi( pFingerUi )
	self.pLayClick.__fingerUi = pFingerUi
end

return ItemHomeMenu