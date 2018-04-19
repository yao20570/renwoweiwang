-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-12-21 19:40:23 星期四
-- Description: 统帅府
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")

local DlgChiefHouse = class("DlgChiefHouse", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgchiefhouse)
end)

function DlgChiefHouse:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_chief_house", handler(self, self.onParseViewCallback))
end

function DlgChiefHouse:myInit(  )
	-- body

end

--解析布局回调事件
function DlgChiefHouse:onParseViewCallback( pView )
	-- body
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
	--设置标题
	self:setTitle(getConvertedStr(6,10653))
	self:setupView()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgChiefHouse",handler(self, self.onDestroy))
end
function DlgChiefHouse:setupView(  )
	-- body
	self.pLayRoot = self:findViewByName("dlg_chief_house")
	--采集队列
	self.pLayCollect = self:findViewByName("lay_collect")
	self.pLbTitle1 = self:findViewByName("lb_title_1")
	self.pLbTitle1:setString(getTipsByIndex(20080), false)
	self.pLayCollect:setIsPressedNeedScale(false)
	self.pLayCollect:onMViewClicked(handler(self, self.onCollectCallBack))
	--新手教程
	sendMsg(ghd_guide_finger_show_or_hide, true)
	Player:getNewGuideMgr():setNewGuideFinger(self.pLayCollect, e_guide_finer.tcf_collect_tab)

	--城防队列
	self.pLayDefense = self:findViewByName("lay_defense")
	self.pLayRole2 = self:findViewByName("img_role_2")
	self.pLayRole2:setFlippedX(true)
	self.pLbTitle2 = self:findViewByName("lb_title_2")
	self.pLbTitle2:setString(getTipsByIndex(20081), false)
	self.pLayTip2 = self:findViewByName("lay_tip_2") 
	self.pLbTip2 = self:findViewByName("lb_tip_2")
	self.pImgLock = self:findViewByName("img_lock")
	setTextCCColor(self.pLbTip2, _cc.red)		
	self.pLayDefense:setIsPressedNeedScale(false)
	self.pLayDefense:onMViewClicked(handler(self, self.onDefenseCallBack))
	--高级御兵术	
	self.pLayOperation = self:findViewByName("lay_operation")
	self.pLbTitle3 = self:findViewByName("lb_title_3")
	self.pLbTitle3:setString(getTipsByIndex(20082), false)
	self.pLayTip3 = self:findViewByName("lay_tip_3")
	self.pLbTip3 = self:findViewByName("lb_tip_3")
	self.pImgLock3 = self:findViewByName("img_lock_3")
	self.pLayOperation:setIsPressedNeedScale(false)
	self.pLayOperation:onMViewClicked(handler(self, self.onOperationCallBack))
end

--控件刷新
function DlgChiefHouse:updateViews(  )
	local pBChiefData = Player:getBuildData():getBuildById(e_build_ids.tcf)
	if pBChiefData then
		self.pLayCollect:setViewTouched(true)
		self.pLayDefense:setViewTouched(pBChiefData.nLv >= 2)
		self.pLayTip2:setVisible(pBChiefData.nLv < 2)
		self.pLayOperation:setViewTouched(pBChiefData.nLv >= 3)		
		if pBChiefData.nLv < 3 then
			self.pLbTip3:setString(string.format(getConvertedStr(6, 10654), 3))
			setTextCCColor(self.pLbTip3, _cc.red)	
			self.pImgLock3:setPositionX(self.pLbTip3:getPositionX() - self.pLbTip3:getWidth()/2 - self.pImgLock3:getWidth()/2 - 5)
			self.pImgLock3:setVisible(true)
		else
			local pBaseTroop = getTroopsVoById(pBChiefData.nStage)			
			-- dump(pBaseTroop, "pBaseTroop", 100)
			local sStr = ""
			if pBaseTroop then				
				local pTroop = pBChiefData:getCurTroopVo(pBaseTroop.type)
				sStr = {
					{color=_cc.yellow, text= getConvertedStr(6, 10655)},
					{color=_cc.yellow, text= pBaseTroop.name},
					{color=_cc.yellow, text= getLvString(pTroop.nLv)},
					{color=_cc.white, text= getSpaceStr(2)},
					{color=_cc.green, text= pTroop.nStage},
					{color=_cc.green, text= getConvertedStr(6, 10170)},
				}
			else
				sStr = getConvertedStr(6, 10673)
				setTextCCColor(self.pLbTip3, _cc.green)	
			end
			-- dump(sStr, "sStr", 100)
			self.pLbTip3:setString(sStr, false)
			self.pImgLock3:setVisible(false)
		end
	else
		self.pLayCollect:setViewTouched(false)
		self.pLayDefense:setViewTouched(false)
		self.pLayTip2:setVisible(true)
		self.pLayOperation:setViewTouched(false)
		self.pLbTip3:setString(string.format(getConvertedStr(6, 10654), 3))
		setTextCCColor(self.pLbTip3, _cc.red)
		self.pImgLock3:setPositionX(self.pLbTip3:getPositionX() - self.pLbTip3:getWidth()/2 - self.pImgLock3:getWidth()/2 - 5)
		self.pImgLock3:setVisible(true)
	end	
	self.pLbTip2:setString(string.format(getConvertedStr(6, 10654), 2))
	self.pImgLock:setPositionX(self.pLbTip2:getPositionX() - self.pLbTip2:getWidth()/2 - self.pImgLock:getWidth()/2 - 5)
end

--析构方法
function DlgChiefHouse:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgChiefHouse:regMsgs(  )
	-- body
	-- 注册统帅府数据刷新
	regMsg(self, ghd_refresh_chiefhouse_msg, handler(self, self.updateViews))	
end
--注销消息
function DlgChiefHouse:unregMsgs(  )
	-- body
	-- 注销统帅府数据刷新
	unregMsg(self, ghd_refresh_chiefhouse_msg)	
end

--暂停方法
function DlgChiefHouse:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgChiefHouse:onResume( _bReshow )
	-- body	
	self:updateViews()
	self:regMsgs()
end

--征收队列
function DlgChiefHouse:onCollectCallBack( pView )
	-- body
	--print("采集队列")
    local tObject = {}
    tObject.nType = e_dlg_index.dlgherolineup --dlg类型
    tObject.nTeamType = e_hero_team_type.collect
    sendMsg(ghd_show_dlg_by_type,tObject)	
    --新手教程
    Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.tcf_collect_tab)
end
--防守队列
function DlgChiefHouse:onDefenseCallBack( pView )
	-- body
	--print("城防队列")
    local tObject = {}
    tObject.nType = e_dlg_index.dlgherolineup --dlg类型
    tObject.nTeamType = e_hero_team_type.walldef
    sendMsg(ghd_show_dlg_by_type,tObject)		
end
--高级御兵术
function DlgChiefHouse:onOperationCallBack( pView )
	-- body
	--print("高级御兵术")
	local tObject = {}
    tObject.nType = e_dlg_index.troopsdetail --dlg类型
    sendMsg(ghd_show_dlg_by_type,tObject)	
end


return DlgChiefHouse
