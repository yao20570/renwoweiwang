-----------------------------------------------------
-- author: xst
-- Date: 2018-03-07 17:01:23
-- Description: 扫荡队列
-----------------------------------------------------
local SWEEPTIME = 5
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroWipeExp = require("app.layer.fuben.ItemHeroWipeExp")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")

local DlgFubenWipe = class("DlgFubenWipe", function()
	-- body
	return DlgCommon.new(e_dlg_index.fubenwipeteam)
end)

function DlgFubenWipe:ctor( tData )
	-- body
	self:myInit()
	self.nExpendEnargy = tData.nExpendEnargy or self.nExpendEnargy 
	self.tFubenData = tData.tFubenData or self.tFubenData 

	self:setTitle(getConvertedStr(1, 10383))
	parseView("dlg_fuben_wipe", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgFubenWipe:myInit(  )
	self.nExpendEnargy = 0
	self.nTimes = 0
	self.tFubenData = {}
	self.tIcons = {}
	self.tBtns = {}
	self.tTitles = {getConvertedStr(9,10049), getConvertedStr(9,10050), getConvertedStr(9,10051), getConvertedStr(1,10386)}
end

--解析布局回调事件
function DlgFubenWipe:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView,true) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFubenWipe",handler(self, self.onDestroy))
end


-- 修改控件内容或者是刷新控件数据
function DlgFubenWipe:updateViews()
	--  Player:getHeroInfo():getOnlineHeroListByTeam
	self:refreshEnergy()
	self:updateHeros()
end

function DlgFubenWipe:setupViews()
	self.pLbTips =  self.pView:findViewByName("lb_tips")
	self.pLbTips:setString(getTextColorByConfigure(getTipsByIndex(20132)), false)
	for i=1, 4 do
		local pLyIcon = self.pView:findViewByName("ly_icon_"..i)
		local item = ItemHeroWipeExp.new()
		item:setIconClickedCallBack(handler(self, self.onIconClicked))
		pLyIcon:addView(item)
		table.insert(self.tIcons, item)

		local pLyBtn = self.pView:findViewByName("ly_btn_"..i)
		local pBtn = getCommonButtonOfContainer(pLyBtn,TypeCommonBtn.M_BLUE,getConvertedStr(7,10314))
		pBtn:setScale(0.8)
		pLyBtn:setPosition(pLyBtn:getPositionX()+15,pLyBtn:getPositionY()+5)
		pBtn:setCallBackParam(i)
		pBtn:onCommonBtnClicked(handler(self, self.btnClick))
		table.insert(self.tBtns, pBtn)
	end

	self:setOnlyConfirm()
	self:setRightBtnType(TypeCommonBtn.L_YELLOW)
	self:setRightHandler(handler(self, self.onTitleBtnRClicked))

	local nPlayerEngy = Player:getPlayerInfo().nEnergy
	self.nTimes = math.floor(nPlayerEngy/ self.nExpendEnargy)
	if self.nTimes == 0 or self.nTimes > SWEEPTIME then
		self.nTimes = SWEEPTIME
	end

	local tBtnRTable = {}
	--文本
	local tRLabel = {
		{getConvertedStr(5,10040),getC3B(_cc.pwhite)},
		{nPlayerEngy,getC3B(_cc.green)},
		{"/",getC3B(_cc.pwhite)},
		{tostring(self.nExpendEnargy*self.nTimes),getC3B(_cc.pwhite)},

	}
	tBtnRTable.tLabel = tRLabel
	self.pRightExText = self.pBtnRight:setBtnExText(tBtnRTable)
	self:updateTabHost()
end

--更新切换卡
function DlgFubenWipe:updateTabHost()
	--创建类表中的英雄
	if not self.pTabHost then
		self.pLyContent   = self.pView:findViewByName("ly_tab")
		self.pTabHost = TCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.onIndexSelected),handler(self, self.onNotOpenSelected))
		self.pTabItems = self.pTabHost:getTabItems()
		self.pLyContent:addView(self.pTabHost,10)
		self.pTabHost:setPositionX(2)
		self.pTabHost:removeLayTmp1()
		self.pTabHost:setImgBag("#v1_btn_selected_biaoqian.png", "#v1_btn_biaoqian.png")
		local index = getLocalInfo("wipeTeam", "1")
		self.pTabHost:setDefaultIndex(tonumber(index))
		self:tabLockUpdate()
	end

end

function DlgFubenWipe:updateHeros()
	local nType = e_hero_team_type.normal
	if self.nSelect == 1 then
		nType = e_hero_team_type.normal
	elseif self.nSelect == 2 then
		nType = e_hero_team_type.collect
	elseif self.nSelect == 3 then
		nType = e_hero_team_type.walldef
	elseif self.nSelect == 4 then
		nType = e_hero_team_type.selfchoose
	end

	local tHeros = Player:getHeroInfo():getHeroOnlineQueueByTeam(nType)
	if tHeros then
		for i=1, 4 do
			self.tIcons[i]:setCurData(tHeros[i])
		end
	end

	if self.nSelect == 4 then
		for i=1, #self.tBtns do
			if type(tHeros[i]) == "table" then
				self.tBtns[i]:setVisible(true)
			else	
				self.tBtns[i]:setVisible(false)
			end
		end
	else
		for i=1, #self.tBtns do
			self.tBtns[i]:setVisible(false)
		end
	end

	local nCount = 0
	for k, v in ipairs(tHeros) do
		if type(v) == "table" then
			nCount = nCount + 1
		end
	end
	--有武将
	if nCount > 0 then
		self.pBtnRight:setBtnEnable(true)
	else
		self.pBtnRight:setBtnEnable(false)
	end
end


-- 更换武将按钮点击响应
function DlgFubenWipe:onIconClicked()
	local nType = e_hero_team_type.normal
	if self.nSelect == 1 then
		nType = e_hero_team_type.normal
	elseif self.nSelect == 2 then
		nType = e_hero_team_type.collect
	elseif self.nSelect == 3 then
		nType = e_hero_team_type.walldef
	elseif self.nSelect == 4 then
		nType = e_hero_team_type.selfchoose
	end

	--选择武将界面
	local tObject = {}
	tObject.nType = e_dlg_index.selecthero --dlg类型
	tObject.nTeamType = nType
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--切换片上锁设置
function DlgFubenWipe:tabLockUpdate( )
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
			pTabItem:showTabLock(nil,10)
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
			pTabItem:showTabLock(nil,10)
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


--下标选择回调事件
function DlgFubenWipe:onIndexSelected( _index )
	self.nSelect = _index
	--刷新列表
	self:updateHeros()
end

--未开启tab回调事件
function DlgFubenWipe:onNotOpenSelected(_index)
	TOAST(getConvertedStr(10, 10004))
end


function DlgFubenWipe:btnClick( _pView , _index)
	--选择武将界面
	local tObject = {}
	tObject.nType = e_dlg_index.selecthero --dlg类型
	tObject.nTeamType = e_hero_team_type.selfchoose
	tObject.nSelfP = _index
	sendMsg(ghd_show_dlg_by_type,tObject)
end


--右边按钮
function DlgFubenWipe:onTitleBtnRClicked(pView)
	if not self.bIsClicking then
		--能量不足是弹出能量购买对话框
			if  Player:getPlayerInfo().nEnergy < self.nExpendEnargy*self.nTimes then
				gotoBuyEnergy()
				doDelayForSomething(self, function( )
					self.bIsClicking = false
				end, 0.2)
			else
				--不允许提示
	      		setToastNCState(1)
	      		local strOnlineList = self:getOnlineListStr()
	      		
				SocketManager:sendMsg("sweepFubenLevel", {self.tFubenData.nId, self.nTimes, strOnlineList}, handler(self, self.onGetDataFunc))
				Player:getHeroInfo():saveLocalHeroOrder(luaSplit(strOnlineList, ";"))
			end
		
			self.bIsClicking = true
	end

end

function DlgFubenWipe:getOnlineListStr()
	local tList = self:getOnlineList()
	return table.concat(tList, ";")
end

function DlgFubenWipe:getOnlineList()
	local nType = e_hero_team_type.normal
	if self.nSelect == 1 then
		nType = e_hero_team_type.normal
	elseif self.nSelect == 2 then
		nType = e_hero_team_type.collect
	elseif self.nSelect == 3 then
		nType = e_hero_team_type.walldef
	elseif self.nSelect == 4 then
		nType = e_hero_team_type.selfchoose
	end

	local tHeros = Player:getHeroInfo():getHeroOnlineQueueByTeam(nType)
	local tList = {}
	if tHeros then
		for k, v in ipairs(tHeros) do
			if type(v) == "table" then
				table.insert(tList, v.nId)
			end
		end 
	end
	return tList
end

--接收服务端发回的登录回调
function DlgFubenWipe:onGetDataFunc( __msg , __oldmsg)

    if  __msg.head.state == SocketErrorType.success then 
 		if __msg.head.type == MsgType.sweepFubenLevel.id  then
        	--todo        
        	--打开战斗结果界面
        	local pData = __msg.body
        	pData.nResult = 1
        	showFightRst(pData)
        	if self then
        		sendMsg(gud_refresh_fuben) --通知刷新界面
        	end
        	closeDlgByType(e_dlg_index.fubenwipeteam,false)
        	closeDlgByType(e_dlg_index.armylayer,false)     	
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
        --打开弹窗类提示信息
		setToastNCState(2)
		--允许提示弹框
		showNextSequenceFunc(e_show_seq.fight)
    end
	self.bIsClicking = false
end


--设置数据
function DlgFubenWipe:setCurData(_tData)
 
end

--刷新能量
function DlgFubenWipe:refreshEnergy()
	local nEnergy = Player:getPlayerInfo().nEnergy
	if self.pRightExText then
		local sColor = _cc.green
		if nEnergy < self.nTimes*self.nExpendEnargy then
			sColor = _cc.red

		end
		self.pRightExText:setLabelCnCr(2, nEnergy,getC3B(sColor))
		self.nTimes = math.floor(nEnergy/ self.nExpendEnargy)
		if self.nTimes == 0 or self.nTimes > SWEEPTIME then
			self.nTimes = SWEEPTIME
		end
		self.pRightExText:setLabelCnCr(4, self.nTimes*self.nExpendEnargy,getC3B(_cc.pwhite))
		self:setRightBtnText(string.format(getConvertedStr(5,10008), self.nTimes))
	end
end
 

-- 析构方法
function DlgFubenWipe:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgFubenWipe:regMsgs( )
	-- 注册英雄界面刷新
	regMsg(self, gud_refresh_hero, handler(self, self.updateViews))	
	regMsg(self, ghd_refresh_energy_msg, handler(self, self.refreshEnergy))
end

--刷新武将数据
function DlgFubenWipe:refreshHeroData( )
	self:updateViews()
end

-- 注销消息
function DlgFubenWipe:unregMsgs(  )
	-- body
	-- 注销英雄界面刷新
	unregMsg(self, gud_refresh_hero)
	unregMsg(self, ghd_refresh_energy_msg)
end


--暂停方法
function DlgFubenWipe:onPause( )
	-- body
	self:unregMsgs()
	saveLocalInfo("wipeTeam", tostring(self.nSelect))
end

--继续方法
function DlgFubenWipe:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgFubenWipe