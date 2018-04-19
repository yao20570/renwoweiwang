--
-- Author: liangzhaowei
-- Date: 2017-05-24 16:13:33
-- 英雄上阵界面


local DlgBase = require("app.common.dialog.DlgBase")
local ItemOnlineHero = require("app.layer.hero.ItemOnlineHero")
local HeroLineUpList = require("app.layer.hero.HeroLineUpList")
local HeroLineUpListCollect = require("app.layer.hero.HeroLineUpListCollect")
local HeroLineUpListWalldef = require("app.layer.hero.HeroLineUpListWalldef")
local FCommonTabHost = require("app.common.tabhost.FCommonTabHost")

local DlgHeroLineUp = class("DlgHeroLineUp", function()
	return DlgBase.new(e_dlg_index.dlgherolineup)
end)

function DlgHeroLineUp:ctor( nTeamType )
	self.nTeamType = nTeamType or e_hero_team_type.normal
	-- body
	self:myInit()
	self:setTitle(getConvertedStr(5, 10052))
	parseView("dlg_hero_line_up", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroLineUp:myInit()
	self.nIdx = nil
	--切换列表
	self.tTitles = {getConvertedStr(9,10049),getConvertedStr(9,10050),getConvertedStr(9,10051)}	
	self.tCommonTabs = {}
	-- self.tHeroListData = {} --英雄队列数据

	-- self.tHeroListItem = {} --英雄队列item
end

--更新数据
function DlgHeroLineUp:refreshData()

		--武将队列
	-- self.tHeroListData = {} --英雄队列数据
	local tHeroOnlineList = Player:getHeroInfo():getOnlineHeroList() --上阵队列
	self.tHeroOnlineList = tHeroOnlineList

	-- for i=1,4 do

	-- 	if tHeroOnlineList[i] then
	-- 		self.tHeroListData[i] = tHeroOnlineList[i]
	-- 	else
	-- 		--锁住类型待添加
	-- 		if i> Player:getHeroInfo().nOnlineNums then
	-- 			self.tHeroListData[i] = TypeIconHero.LOCK
	-- 		else
	-- 			self.tHeroListData[i] = TypeIconHero.ADD
	-- 		end
	-- 	end
	-- end


end

--解析布局回调事件
function DlgHeroLineUp:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace(7)
	
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroLineUp",handler(self, self.onDestroy))

end


-- 修改控件内容或者是刷新控件数据
function DlgHeroLineUp:updateViews()
		-- 刷新数据
		self:refreshData()



		--顶部按钮层
		if(not self.pLyTop) then
			self.pLyTop = self.pView:findViewByName("lay_top")
		end
		if(not self.pLyList) then
			self.pLyList = self.pView:findViewByName("ly_list")
		end
		--lb
		if(not self.pLbAddSoldierTips) then
			self.pLbAddSoldierTips = self.pView:findViewByName("lb_talent_tips")
			self.pLbAddSoldierTips:setString(getConvertedStr(5, 10095))
		end
		if(not self.pLbBuNums) then
			self.pLbBuNums = self.pView:findViewByName("lb_bu_nums")
			self.pLbGongNums = self.pView:findViewByName("lb_gong_nums")
			self.pLbQiNums = self.pView:findViewByName("lb_qi_nums")

			--头顶横条(banner)
			local pBannerImage 			= 		self:findViewByName("lay_banner_bg")
			local pBanner=setMBannerImage(pBannerImage,TypeBannerUsed.jjf)
			pBanner:setMBannerOpacity(255*0.5)

			--耐力消耗提示
			self.pTxtNailiCostTip = MUI.MLabel.new({
	            text = "",
	            size = 20,
	            anchorpoint = cc.p(0, 0),
	            align = cc.ui.TEXT_ALIGN_LEFT,
	            valign = cc.ui.TEXT_VALIGN_TOP,
	            -- color = cc.c3b(255, 255, 255),
	            dimensions = cc.size(300, 100),
	        })
	        self.pTxtNailiCostTip:setString(getTextColorByConfigure(getTipsByIndex(20091)))
	        self.pTxtNailiCostTip:setPosition(17, 50)
	        pBannerImage:addView(self.pTxtNailiCostTip, 11)
	        self.pTxtNailiCostTip:setVisible(false)
		end
		self.pLbBuNums:setString(formatCountToStr(Player:getPlayerInfo().nInfantry))   
		self.pLbGongNums:setString(formatCountToStr(Player:getPlayerInfo().nArcher))
		self.pLbQiNums:setString(formatCountToStr(Player:getPlayerInfo().nSowar))

		if(not self.pLyAddSoldier) then
			self.pLyAddSoldier = self.pView:findViewByName("ly_talent_switch")--补兵按钮
			--根据现在开启的补兵状态设置按钮状态
			self.pOvalSw =  getOvalSwOfContainer(self.pLyAddSoldier,
				handler(self, self.onOvalSw),Player:getHeroInfo().nAuto)
			--耐力
			self.pLyAddNaili = MUI.MLayer.new()
			local pParent = self.pLyAddSoldier:getParent()
			local pSize = self.pLyAddSoldier:getContentSize()
			local nX, nY = self.pLyAddSoldier:getPosition()
			local nZorder = self.pLyAddSoldier:getLocalZOrder()
			pParent:addView(self.pLyAddNaili, nZorder)
			self.pLyAddNaili:setContentSize(pSize)
			self.pLyAddNaili:setPosition(nX, nY)
			self.pLyAddNaili:setVisible(false)
			--根据现在开启的补耐力状态设置按钮状态
			local nAuto = 1
    		if getIsOpenNailiFill() then
    			nAuto = 1
    		else
    			nAuto = 0
    		end
			self.pOvalSwNaili =  getOvalSwOfContainer(self.pLyAddNaili,
				handler(self, self.onOvalSwNaili),nAuto)
		end
		if(not self.pLbBingli) then
			self.pLyTalent = self.pView:findViewByName("ly_talent")
			self.pLbBingli = MUI.MLabel.new({text = "", size = 20})
			self.pLyTalent:addView(self.pLbBingli, 2)
			self.pLbBingli:setAnchorPoint(cc.p(0, 0.5))
			self.pLbBingli:setPosition(20, self.pLyTalent:getHeight()/2)
			--耐力
			self.pLbNaili = MUI.MLabel.new({text = "", size = 20})
			self.pLyTalent:addView(self.pLbNaili, 2)
			self.pLbNaili:setAnchorPoint(cc.p(0, 0.5))
			self.pLbNaili:setPosition(20, self.pLyTalent:getHeight()/2)
			self.pLbNaili:setVisible(false)
			--更新粮草显示
			self:updateFood()
		end
		local nCurLt, nTotoalLt = 0, 0
		for k, v in pairs(self.tHeroOnlineList) do
			nCurLt = nCurLt + v.nLt
			nTotoalLt = nTotoalLt + v:getProperty(e_id_hero_att.bingli)
		end
		local sTip = {
			{text = getConvertedStr(7, 10222), color = _cc.pwhite},
			{text = nCurLt, color = _cc.green},
			{text = "/", color = _cc.pwhite},
			{text = nTotoalLt, color = _cc.pwhite},
		}
		self.pLbBingli:setString(sTip)
		--切换卡层
		if not self.pLayTable then
			self.pLayTable = self.pView:findViewByName("lay_tab")
			self.pTabHost = FCommonTabHost.new(self.pLayTable,1,1,self.tTitles, handler(self, self.getLayerByKey))
			self.pTabHost:setLayoutSize(self.pLayTable:getLayoutSize())
			self.pTabHost:removeLayTmp1()
			self.pTabHost:removeLayTmp2()
			self.pLayTable:addView(self.pTabHost, 10)
			centerInView(self.pLayTable, self.nTabHost)
			self.pTabHost:setTabChangedHandler(handler(self, self.onTabChanged))								
			self:tabLockUpdate()
			if not Player:getHeroInfo():isOpenQuenceByType(self.nTeamType) then
				self.nTeamType = e_hero_team_type.normal
			end
			self.pTabHost:setDefaultIndex(self.nTeamType)

			self.pLbTip = MUI.MLabel.new({
				    text = getConvertedStr(6, 10842),
				    size = 20,
				    anchorpoint = cc.p(0.5, 0.5),
				    align = cc.ui.TEXT_ALIGN_CENTER,
		    		valign = cc.ui.TEXT_VALIGN_CENTER,
				    color = cc.c3b(255, 255, 255),
				    })	
			self.pLayTable:addView(self.pLbTip, 10)
			setTextCCColor(self.pLbTip, _cc.pwhite) 
			self.pLbTip:setPosition(self.pLayTable:getWidth()/2, 20 + self.pLbTip:getHeight()/2)			
		else
			--刷新在分页内部
			if self.sCurKeys then
				local pLayer = self.tCommonTabs[self.sCurKeys]--当前页
				if pLayer then
					pLayer:updateViews()
				end
			end
		end
		self:updateTabRed()

end

--椭圆形开关
function DlgHeroLineUp:onOvalSw()

	if Player:getHeroInfo().nAuto == 0 then  --在没有开启的状态，判断防御自动补兵科技是否开启
		local pTech = Player:getTnolyData():getTnolyByIdFromAll(3019)  --3019 防御自动补兵科技id
		if pTech and pTech:checkisLocked() then
			self:showTechDlg(pTech)
			return 
		end
	end
	local nType = 0
	if Player:getHeroInfo().nAuto == 0 then
		nType = 1
	elseif Player:getHeroInfo().nAuto == 1 then
		nType = 0
	end

	SocketManager:sendMsg("autoAddSoldier", {nType}, handler(self, self.onGetDataFunc))
end

--椭圆形开关
function DlgHeroLineUp:onOvalSwNaili()
	local nAuto = 1
	if getIsOpenNailiFill() then
		nAuto = 0
	else
		nAuto = 1
	end
	SocketManager:sendMsg("autoAddHeroNaili", {nAuto}, handler(self, self.onGetDataFunc))
end

--科技未解锁，提示框
--_tData 未解锁的科技数据
function DlgHeroLineUp:showTechDlg(_tData)
	if not _tData then 
		return 
	end
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg, bNew = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    pDlg:setRightBtnText(getConvertedStr(8, 10019))
    pDlg:setRightBtnType(TypeCommonBtn.L_BLUE)

   	local pView = parseView("lay_vip_good_tip",function (pView)
   		pDlg:addContentView(pView,true)
		local pLayRoot 	= pView:findViewByName("lay_def")
		local pLayIcon 	= pView:findViewByName("lay_icon")
		local pLbTip = pLayRoot:findViewByName("tip")
		if not pLbTip then
			pLbTip = MUI.MLabel.new({
			    text = "",
			    size = 20,
			    anchorpoint = cc.p(0.5, 0.5),
			    align = cc.ui.TEXT_ALIGN_CENTER,
	    		valign = cc.ui.TEXT_VALIGN_CENTER,
			    color = cc.c3b(255, 255, 255),
			    dimensions = cc.size(350, 60),
			})
			pLbTip:setPosition(200, 53)
			pLbTip:setName("tip")
			pLayRoot:addView(pLbTip, 10)
		end
		local str = getTextColorByConfigure(getTipsByIndex(10073))
		pLbTip:setString(str, false)
		getIconGoodsByType(pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, _tData)

	end)

 	pDlg:setRightHandler(function (  )            
        --跳转到科技树界面
		local tObject = {}
		tObject.nType = e_dlg_index.tnolytree --dlg类型
		tObject.tData = _tData
		sendMsg(ghd_show_dlg_by_type,tObject)
		closeDlgByType(e_dlg_index.alert)
    end)
    pDlg:showDlg(bNew) 
end


--接收服务端发回的登录回调
function DlgHeroLineUp:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.autoAddSoldier.id then
        	if not tolua.isnull(self.pOvalSw) then
        		self.pOvalSw:setState(Player:getHeroInfo().nAuto)        	
        	end
        elseif __msg.head.type == MsgType.autoAddHeroNaili.id then
        	if not tolua.isnull(self.pOvalSwNaili) then
        		local nAuto = 1
        		if getIsOpenNailiFill() then
        			nAuto = 1
        		else
        			nAuto = 0
        		end
        		self.pOvalSwNaili:setState(nAuto)        	
        	end
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


-- 析构方法
function DlgHeroLineUp:onDestroy(  )
	-- body
	self:onPause()

end

-- 注册消息
function DlgHeroLineUp:regMsgs( )
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))
	-- 注册装备发生改变消息
	regMsg(self, gud_equip_hero_equip_change, handler(self, self.updateViews))
	-- 注册粮草更新
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateFood))
	-- 注册武将进阶状态刷新消息
	regMsg(self, ghd_advance_hero_rednum_update_msg, handler(self, self.updateTabRed))
end

-- 注销消息
function DlgHeroLineUp:unregMsgs(  )
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
	-- 注销装备发生改变消息
	unregMsg(self, gud_equip_hero_equip_change)
	-- 注销粮草更新
	unregMsg(self, gud_refresh_playerinfo)
	-- 注销武将进阶状态刷新消息
	unregMsg(self, ghd_advance_hero_rednum_update_msg)
end


--暂停方法
function DlgHeroLineUp:onPause( )
	-- body
	nCollectCnt = 2
	self:unregMsgs()
	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgHeroLineUp:onResume( _bReshow )
	-- body
	if _bReshow and self.pOvalSw then
		if self.pOvalSw.nState ~= Player:getHeroInfo().nAuto then
			self.pOvalSw:setState(Player:getHeroInfo().nAuto)
		end
	end
    -- TestProfile:printTime(121)
	self:updateViews()
    -- TestProfile:printTime(122)
	self:regMsgs()
	
end

--指引位置
function DlgHeroLineUp:setGuidePos( _nIdx )
	-- body
	self.nIdx = _nIdx or nil
end

--通过key值获取内容层的layer
function DlgHeroLineUp:getLayerByKey( _sKey, _tKeyTabLt )
	-- body
	local pLayer = nil
	if( _sKey == _tKeyTabLt[1] ) then		
		pLayer = HeroLineUpList.new(1)			
	elseif ( _sKey == _tKeyTabLt[2] ) then		
		pLayer = HeroLineUpListCollect.new(2)	
	elseif ( _sKey == _tKeyTabLt[3] ) then				
		pLayer = HeroLineUpListWalldef.new(3)
	end
	if not self.tCommonTabs[_sKey] then
		self.tCommonTabs[_sKey] = pLayer
	end
	return pLayer
end

--清理对应页面红点
function DlgHeroLineUp:clearItemRedNumByKey( _sKey )
	-- body
	if not _sKey then
		return 
	end
	if _sKey == "tabhost_key_1" then	
		Player:getBagInfo():clearItemRedNum(e_item_types.consum)				
	elseif _sKey == "tabhost_key_2" then
		Player:getEquipData():setIdleEquipNoNew()			
	elseif _sKey == "tabhost_key_3" then
		Player:getBagInfo():clearItemRedNum(e_item_types.material)			
	elseif _sKey == "tabhost_key_4" then
		Player:getBagInfo():clearItemRedNum(e_item_types.other)				
	end	
end

--分页切换
function DlgHeroLineUp:onTabChanged(_sKey)
	-- body
	if _sKey then			
		--清理前一页的红点
		if self.sCurKeys then			
			self:clearItemRedNumByKey(self.sCurKeys)
			local pPrevLayer = self.tCommonTabs[self.sCurKeys]
			pPrevLayer:updateViews()			
		end
		--刷新在分页内部显示物品是否为新
		local pLayer = self.tCommonTabs[_sKey]--当前页
		if pLayer then
			pLayer:updateViews()
			self.sCurKeys = _sKey
			self.nTeamType = _sKey
		end
	end

	--切换显示
	if self.sCurKeys == "tabhost_key_3" then
		--补兵力按钮
		if self.pLyAddSoldier then
			self.pLyAddSoldier:setVisible(false)
		end
		--补耐力按钮
		if self.pLyAddNaili then
			self.pLyAddNaili:setVisible(true)
		end
		--补兵力标签
		if self.pLbBingli then
			self.pLbBingli:setVisible(false)
		end
		--补耐力标签
		if self.pLbNaili then
			self.pLbNaili:setVisible(true)
		end
		--补耐力按钮名字
		self.pLbAddSoldierTips:setString(getConvertedStr(3, 10577))
		--补耐力提示
		self.pTxtNailiCostTip:setVisible(true)
	else
		--补兵力按钮
		if self.pLyAddSoldier then
			self.pLyAddSoldier:setVisible(true)
		end
		--补耐力按钮
		if self.pLyAddNaili then
			self.pLyAddNaili:setVisible(false)
		end
		--补兵力标签
		if self.pLbBingli then
			self.pLbBingli:setVisible(true)
		end
		--补耐力标签
		if self.pLbNaili then
			self.pLbNaili:setVisible(false)
		end
		--补兵力按钮名字
		self.pLbAddSoldierTips:setString(getConvertedStr(5, 10095))
		--补耐力提示
		self.pTxtNailiCostTip:setVisible(false)
	end
end

--消耗粮草
function DlgHeroLineUp:updateFood(  )
	if self.pLbNaili then
		local nFood = getMyGoodsCnt(e_type_resdata.food)
		local sColor = _cc.red
		if nFood > 0 then
			sColor = _cc.green
		end
		local tStr = {
		    {color=_cc.white,text=getConvertedStr(3, 10578)},
		    {color=sColor,text=getResourcesStr(nFood)},
		}
		self.pLbNaili:setString(tStr)
	end
end

--切换片上锁设置
function DlgHeroLineUp:tabLockUpdate( )
	if not self.pTabHost then
		return
	end
	
	local bIsLock = true
	local tBuildData=Player:getBuildData():getBuildById(e_build_ids.tcf)
	if tBuildData then
		bIsLock = false
	end

	--采集
	local pTabItem = self.pTabHost.tTabItems[2]
	if pTabItem then
		if bIsLock then
			pTabItem:showTabLock()
			pTabItem:setViewEnabled(false)
			pTabItem:onMViewDisabledClicked(handler(self, function (  )
			    -- body
			    local nNeedLv = 0
			    local tBuild = getBuildDatasByTid(e_build_ids.tcf)
			    if tBuild then
			    	local tData = luaSplit(tBuild.open, ":") 
			    	if tData[2] and tonumber(tData[2]) then
			    		nNeedLv = tonumber(tData[2])
			    	end
			    end
			    TOAST(string.format(getTipsByIndex(20086), nNeedLv))
			end))
		else
			pTabItem:setViewEnabled(true)             
			pTabItem:hideTabLock()
		end
	end

	local bIsLock = true
	if tBuildData and tBuildData.nLv >= tsf_open_citydef_team_lv then
		bIsLock = false
	end
	--城防队列
	local pTabItem = self.pTabHost.tTabItems[3]
	if pTabItem then
		if bIsLock then
			pTabItem:showTabLock()
			pTabItem:setViewEnabled(false)
			pTabItem:onMViewDisabledClicked(handler(self, function (  )
			    -- body
			    TOAST(getTipsByIndex(20087))
			end))
		else
			pTabItem:setViewEnabled(true)             
			pTabItem:hideTabLock()
		end
	end
end

function DlgHeroLineUp:updateTabRed( ... )
	-- body
	local tTabItems = self.pTabHost:getTabItems()
	for k, v in pairs(tTabItems) do
		showRedTips(v:getRedNumLayer(), 0, Player:getHeroInfo():getTabHeroRedNum(k)) 
	end
end

return DlgHeroLineUp