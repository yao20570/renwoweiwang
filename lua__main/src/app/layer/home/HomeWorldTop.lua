-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-17 14:36:17 星期三
-- Description: 世界顶部层
-----------------------------------------------------

local ItemHomeRes = require("app.layer.home.ItemHomeRes")
local MCommonView = require("app.common.MCommonView")

local HomeWorldTop = class("HomeWorldTop", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function HomeWorldTop:ctor(  )
	-- body
	self:myInit()
	parseView("layout_home_worldtop", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function HomeWorldTop:myInit(  )
end

--解析布局回调事件
function HomeWorldTop:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("HomeWorldTop",handler(self, self.onHomeWorldTopDestroy))
end

--初始化控件
function HomeWorldTop:setupViews( )
	-- body

	--资源层
	self.pLayTop 				= 		self:findViewByName("lay_res")
	self.pLayTop:setViewTouched(true)
	self.pLayTop:setIsPressedNeedScale(false)
	self.pLayTop:onMViewClicked(handler(self, self.onResClicked))


	local nResFlewX = 0
	local nResFlewY = 5


	--粮食
	self.pItemFood 				= 		ItemHomeRes.new(1)
	self.pLayTop:addView(self.pItemFood)
	self.pItemFood:setPosition(0+nResFlewX,nResFlewY)
	--木头
	self.pItemWood 				= 		ItemHomeRes.new(2)
	self.pLayTop:addView(self.pItemWood)
	self.pItemWood:setPosition(self.pItemWood:getWidth()+nResFlewX-10,nResFlewY)
	--铁
	self.pItemIron 				= 		ItemHomeRes.new(3)
	self.pLayTop:addView(self.pItemIron)
	self.pItemIron:setPosition(self.pItemWood:getWidth() * 2+nResFlewX-10*2,nResFlewY)
	--铜币
	self.pItemCoin 				= 		ItemHomeRes.new(4)
	self.pLayTop:addView(self.pItemCoin)
	self.pItemCoin:setPosition(self.pItemWood:getWidth() * 3+nResFlewX-10*3,nResFlewY)



	--设置获得物品资源ui
	setShowGetItemResUis(2, self.pItemFood, self.pItemWood, self.pItemIron, self.pItemCoin)

	-- --位置层
	-- self.pLayLocation 			= 		self:findViewByName("lay_location")
	-- self.pLayLocation:setViewTouched(true)
	-- self.pLayLocation:setIsPressedNeedScale(false)
	-- self.pLayLocation:onMViewClicked(handler(self, self.onLocationClicked))
	--位置
	self.pLbLocation 			= 		self:findViewByName("lb_lo")
	setTextCCColor(self.pLbLocation,_cc.dblue)

	--国际化语言文字
	local pLbText 				= 		self:findViewByName("lb_lo_tips")
	setTextCCColor(pLbText,_cc.white)
	pLbText:setString(getConvertedStr(1, 10212))

	--大地图入口
	self.pLySjdt				= 		self:findViewByName("lay_sjdt")
	self.pLySjdt:setViewTouched(true)
	self.pLySjdt:setIsPressedNeedScale(false)
	self.pLySjdt:onMViewClicked(handler(self, self.onSjdtClicked))


	self.tTopClickLy = {}--顶部点击区域
	for i=1,4 do
		self.tTopClickLy[i] = self:findViewByName("lay_item"..i)
		self.tTopClickLy[i].nType = i
		-- if i~=3 then --目前天气没有响应
			self.tTopClickLy[i]:setViewTouched(true)
			self.tTopClickLy[i]:setIsPressedNeedScale(false)
			self.tTopClickLy[i]:onMViewClicked(handler(self, self.onTopClicked))		
		-- end
	end


	--世界地图
	local pLbSj 				= 		self:findViewByName("lb_sj")
	setTextCCColor(pLbSj,_cc.white)
	pLbSj:setString(getConvertedStr(5, 10281))

	--天气图标
	self.pImgJj 				= 		self:findViewByName("img_jj")


	--城池
	local pLbCc 				= 		self:findViewByName("lb_cc")
	setTextCCColor(pLbCc,_cc.white)
	pLbCc:setString(getConvertedStr(5, 10282))

	--搜索
	local pLbSs 				= 		self:findViewByName("lb_ss")
	setTextCCColor(pLbSs,_cc.white)
	pLbSs:setString(getConvertedStr(5, 10283))
	

	--定位
	self.pLayDw              	=       self:findViewByName("lay_item4")
	local pLbDw 				= 		self:findViewByName("lb_dw")
	-- setTextCCColor(pLbDw,_cc.pwhite)
	-- pLbDw:setString(getConvertedStr(5, 10284))

	--四季日期
	self.pLbSeason 				= 		self:findViewByName("lb_jj")
	setTextCCColor(self.pLbSeason,_cc.white)

	--体力
	self.pLbTl				= 		self:findViewByName("lb_tl")
	self.pLayTl 			= 		self:findViewByName("lay_tili")
	self.pLayTl:setViewTouched(true)
	self.pLayTl:setIsPressedNeedScale(false)
	self.pLayTl:onMViewClicked(handler(self, self.onTLClicked))

	
	

	

end

-- 修改控件内容或者是刷新控件数据
function HomeWorldTop:updateViews(  )
	-- body
	self.pItemFood:updateValue()
	self.pItemWood:updateValue()
	self.pItemIron:updateValue()
	self.pItemCoin:updateValue()
	self:updateSeason()--更新四季日期
	self:refreshEnergy()--更新能量
	self:refreshCityRed()--城池红点刷新	
end

-- 更新位置
function HomeWorldTop:updateLocation(  )
	local nBlockId = Player:getWorldData():getMyCityBlockId()
	if nBlockId then
		local tMapData = getWorldMapDataById(nBlockId)
		if tMapData then
			self.pLbLocation:setString(tMapData.name)
		end
	end
end

--体力刷新
function HomeWorldTop:refreshEnergy()
	--获得体力上限值
	local nEnergyMax = tonumber(getGlobleParam("initEnergy") or 100)
	self.pLbTl:setString(
	{
	 	{text=Player:getPlayerInfo().nEnergy,color=_cc.green},
	 	{text="/",color=_cc.pwhite},
	 	{text=nEnergyMax,color=_cc.pwhite}
	})
end
--城池红点刷新
function HomeWorldTop:refreshCityRed(  )
	-- body
	if not self.pLayCCRed then
		self.pLayCCRed = self:findViewByName("lay_cc_red")
	end
	local nRedNum = Player:getCountryData():getCityRedNum()
	showRedTips(self.pLayCCRed, 0, nRedNum, 1)		
end

--世界四季变化
function HomeWorldTop:updateSeason()
	local bIsNoOpen = false
	local nSeasonDay = Player:getWorldData().nSeasonDay
	if nSeasonDay == nil or nSeasonDay == 0 then
		nSeasonDay = 2 --默认是春季，改表的话，这里要改
		bIsNoOpen = true
	end
	local tData = getWorldSeasonData(nSeasonDay)
	if tData then
		if tData.icon then
			self.pImgJj:setCurrentImage(tData.sIcon)
			self.pImgJj:setScale(0.35)
		end
		if bIsNoOpen then
			self.pLbSeason:setString(getConvertedStr(3, 10445))
		else
			self.pLbSeason:setString(tData.desc)
			self.pLbSeason:setScale(0.8)
		end
	end
end


-- 析构方法
function HomeWorldTop:onHomeWorldTopDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function HomeWorldTop:regMsgs( )
	-- body
	-- 注册玩家数据变化的消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))

	-- 注册玩家城池位置变化的消息
	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.updateLocation))	

	--世界四季变化
	regMsg(self, gud_world_season_day_change, handler(self, self.updateSeason))

	-- 注册玩家能量刷新消息
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.refreshEnergy))

	-- 注册定位按钮显示或隐藏
	regMsg(self, ghd_worldtop_lbtn_effect_show_or_hide, handler(self, self.onBreathingLamp))

	-- 国家城池数据刷新
	regMsg(self, gud_refresh_countrycity_msg, handler(self, self.refreshCityRed))
end

-- 注销消息
function HomeWorldTop:unregMsgs(  )
	-- body
	-- 销毁玩家数据变化的消息
	unregMsg(self, gud_refresh_playerinfo)
	
	-- 销毁玩家城池位置变化的消息
	unregMsg(self, gud_world_my_city_pos_change_msg)

	--世界四季变化
	unregMsg(self, gud_world_season_day_change)

	unregMsg(self, ghd_refresh_energy_msg)

	unregMsg(self, ghd_worldtop_lbtn_effect_show_or_hide)	

	-- 国家城池数据刷新
	unregMsg(self, gud_refresh_countrycity_msg)
end


--暂停方法
function HomeWorldTop:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function HomeWorldTop:onResume( )
	-- body
	self:updateViews()
	self:updateLocation()
	self:regMsgs()
	
end

-- --位置点击事件
-- function HomeWorldTop:onLocationClicked( pView )
-- 	sendMsg(ghd_world_locaction_my_city_msg)
-- end

--世界入口点击
function HomeWorldTop:onSjdtClicked(pView)
	-- body
	local tObject = {
	    nType = e_dlg_index.worldmap, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

--城池点击入口
function HomeWorldTop:onCcClicked(pView)
	-- body

end

--顶部4个标签点击点击入口
function HomeWorldTop:onTopClicked(pView)
	-- body
	if pView and pView.nType then
		--todo
		local nType = pView.nType

		if nType ==1 then --城池		
			local tObject = {
			    nType = e_dlg_index.dlgcountrycity, --dlg类型
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		elseif  nType ==2 then--搜索
			--键盘搜索
			-- local DlgFlow = require("app.common.dialog.DlgFlow")

			-- local pDlg,bNew = getDlgByType(e_dlg_index.poskeypad)
			-- if(not pDlg) then
			-- 	pDlg = DlgFlow.new(e_dlg_index.poskeypad)
			-- end
			-- local KeyBoard = require("app.layer.world.KeyBoard")
			-- local pChildView = KeyBoard.new(pDlg)
			-- pDlg:showChildView(pView, pChildView)
			-- pDlg:setToCenter()
			-- UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)


			--指定数据搜索
			--条件限制
			--开启判断
			local bIsOpen = getIsReachOpenCon(15, true)
			if not bIsOpen then
				return
			end
			local DlgFlow = require("app.common.dialog.DlgFlow")
			local pDlg,bNew = getDlgByType(e_dlg_index.worldsearch)
			if(not pDlg) then
				pDlg = DlgFlow.new(e_dlg_index.worldsearch)
			end
			local DlgWorldSearch = require("app.layer.worldsearch.DlgWorldSearch")
			local pChildView = DlgWorldSearch.new()
			pChildView:refreshData()
			pDlg:showChildView(nil, pChildView)
			pChildView:setPosition((self:getWidth() - pChildView:getWidth())/2, 0)
			UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
			pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
		elseif  nType ==3 then--天气
			local tObject = {
			    nType = e_dlg_index.season, --dlg类型
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		elseif  nType ==4 then--位置
			sendMsg(ghd_world_locaction_my_city_msg)
			TOAST(getTipsByIndex(10074))
		end
	end
end

--资源点击事件(跳转到仓库)
function HomeWorldTop:onResClicked( pView )
	-- body
	local tObject = {}
	tObject.nType = e_dlg_index.warehouse --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)
end


--体力点击事件
function HomeWorldTop:onTLClicked()
	-- body
	openDlgBuyEnergy()
end

--显示或隐藏定位呼吸特效
function HomeWorldTop:onBreathingLamp( sMsgName, pMsgObj )
	if self.bIsBreathingLamp == pMsgObj then
		return
	end
	self.bIsBreathingLamp = pMsgObj
	--显示或隐藏特效
	if self.bIsBreathingLamp then
		if not self.pBreathingLampArm then
			--创建精灵
			local pArm = MArmatureUtils:createMArmature(EffectWorldDatas["breathingLamp"], 
			self.pLayDw, 
			0, 
			cc.p(self.pLayDw:getContentSize().width/2, self.pLayDw:getContentSize().height/2),
		    function (  )
			end, Scene_arm_type.normal)
			pArm:play(-1)
			self.pBreathingLampArm = pArm
		else
			self.pBreathingLampArm:play(-1)
			self.pBreathingLampArm:setVisible(true)
		end
	else
		--隐藏精灵
		if self.pBreathingLampArm then
			self.pBreathingLampArm:stop()
			self.pBreathingLampArm:setVisible(false)
		end
	end
end

return HomeWorldTop