-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-04-25 16:24:47
-- Description: 选择上阵武将界面
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local ItemHeroArmy = require("app.layer.hero.ItemHeroArmy")

local MRichLabel = require("app.common.richview.MRichLabel")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")


local DlgSelectHero = class("DlgSelectHero", function()
	return DlgCommon.new(e_dlg_index.selecthero)
end)

function DlgSelectHero:ctor(_tData, nTeamType, nSelfP)
	-- body
	self:myInit()
	self.tData = _tData
	self.nTeamType = nTeamType
	self.nTarHeroId = nil
	self.nSelfP = nSelfP
	self:setTitle(getConvertedStr(5, 10030))
	if self.tData then
		parseView("dlg_hero_army_list", handler(self, self.onParseViewCallback))
	else
		parseView("dlg_hero_army_list_sort", handler(self, self.onParseViewCallback))
	end
end

--初始化成员变量
function DlgSelectHero:myInit(  )
	-- body
	self.tData = {} --英雄数据

	self.pRichViewTips1  = nil --富文本1

	self.tFreeHeroListData = {} --英雄列表
	self.tShowHeroList     = {} --展示英雄列表

	self.tTitles 		=	{getConvertedStr(5,10031),getConvertedStr(5,10033),
	  getConvertedStr(5,10032),getConvertedStr(5,10034)}
end

--初始化数据
function DlgSelectHero:initData()
	if self.nTeamType == e_hero_team_type.selfchoose then
		self.tFreeHeroListData = Player:getHeroInfo():getChooseSelfFreeHeroList()
	elseif self.nTeamType == e_hero_team_type.arena then
		self.tFreeHeroListData = Player:getArenaData():getArenaFreeHeroList()		
	else
		self.tFreeHeroListData = Player:getHeroInfo():getFreeHeroList() --英雄列表
	end
	
	self.tShowHeroList     = self.tFreeHeroListData --展示英雄列表
end

--解析布局回调事件
function DlgSelectHero:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView,false) --加入内容层

	self:initData()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgSelectHero",handler(self, self.onDestroy))
end


-- function DlgSelectHero:__nShowHandler( )
-- 	sendMsg(ghd_guide_finger_show_or_hide, true)
-- 	--新手引导选择骑兵武将
-- 	Player:getNewGuideMgr():setNewGuideFinger(self.pTComTabHost:getTabItems()[3], e_guide_finer.sowar_hero_type)
-- end


--下标选择回调事件
function DlgSelectHero:onIndexSelected( _index )
	self.nSelectIdx = _index

	if _index == 1 then --全部
		self.tShowHeroList = self.tFreeHeroListData
	elseif _index == 2 then --步将
		self.tShowHeroList = {}
		for k,v in pairs(self.tFreeHeroListData) do
			if v.nKind == en_soldier_type.infantry then
				table.insert(self.tShowHeroList,v)
			end
		end
	elseif _index == 3 then --骑将
		self.tShowHeroList = {}
		for k,v in pairs(self.tFreeHeroListData) do
			if v.nKind == en_soldier_type.sowar then
				table.insert(self.tShowHeroList,v)
			end
		end
		-- Player:getNewGuideMgr():onClickedNewGuideFinger(self.pTComTabHost:getTabItems()[_index])
	elseif _index == 4 then --弓将
		self.tShowHeroList = {}
		for k,v in pairs(self.tFreeHeroListData) do
			if v.nKind == en_soldier_type.archer then
				table.insert(self.tShowHeroList,v)
			end
		end
	end

	self:sortHeroList(self.tShowHeroList)


	if self.pListView then
		-- self.pListView:setItemCount(table.nums(self.tShowHeroList))
		-- self.pListView:notifyDataSetChange(false) --刷新武将队列
		
		local nCurrCount = table.nums(self.tShowHeroList)
		self.pListView:notifyDataSetChange(true, nCurrCount)

		self:scrollToTarHeroPos()


		if #self.tShowHeroList > 0 then
			self.pNullUi:setVisible(false)
		else
			self.pNullUi:setVisible(true)
		end
	end

end

--移动到目标武将id
function DlgSelectHero:scrollToTarHeroPos()
	-- body
	if self.nTarHeroId == nil then
		return
	end
	if self.nSelectIdx == 1 then
		for k, v in pairs(self.tShowHeroList) do
			if self.nTarHeroId == v.sTid then
				self.nTarPos = k
			end
		end
		if self.nTarPos then
			self.pListView:scrollToPosition(self.nTarPos)
		end
	end
end

--对显示的英雄进行排位
function DlgSelectHero:sortHeroList(_heroList)
	-- body
	if _heroList and table.nums(_heroList)> 0 then
		table.sort( _heroList, function (a,b)

			if a.nStar == b.nStar then
				if a.nQuality == b.nQuality then
					if a.nLv == b.nLv then
						return a.nId > b.nId
					else
						return a.nLv > b.nLv
					end
				else
					return a.nQuality > b.nQuality
				end
			else
				return a.nStar > b.nStar
			end

		end )
	end
end

--创建listView
function DlgSelectHero:createListView()
	-- listview
	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	local pNullUi = getLayNullUiImgAndTxt(tLabel)
	self.pLyContent:addView(pNullUi)
	centerInView(self.pLyContent, pNullUi)
	self.pNullUi = pNullUi
	self.pNullUi:setVisible(false)

	self.pListView = createNewListView(self.pTComTabHost:getContentLayer(),nil,nil,nil,nil,0)

	if table.nums(self.tShowHeroList )> 0  then
		self.pListView:setItemCount(table.nums(self.tShowHeroList))
		self.pListView:setItemCallback(handler(self, self.everyCallback))
		self.pListView:reload(true)
	else
		self.pNullUi:setVisible(true)
	end

	self:scrollToTarHeroPos()
end

-- 没帧回调 _index 下标 _pView 视图
function DlgSelectHero:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tShowHeroList[_index] then
			pView = ItemHeroArmy.new(_index,self.tShowHeroList[_index])
			pView:setHandler(handler(self, self.onViewClick))
		end
	end

	if _index and self.tShowHeroList[_index] then
		pView:setCurData(self.tShowHeroList[_index], self.nTarHeroId, _index)	
	end

	return pView
end

--item回调
function DlgSelectHero:onViewClick(pData)
	-- body
	local pViewData = pData
 
	self.pViewData = pData --记录需要上阵的武将
	if pViewData and pViewData.nId then
		if self.nTeamType == e_hero_team_type.collect then
			--指定位置
			local nPos = 0
			if self.tData then
				nPos = self.tData.nCp
			end
			if nPos == 0 then
				nPos = table.nums(Player:getHeroInfo():getCollectHeroList()) +1
			end
			SocketManager:sendMsg("reqHeroAddTcfTeam", {pViewData.nId,nPos, 1},handler(self, self.onGetDataFunc))
		elseif self.nTeamType == e_hero_team_type.walldef then
			--指定位置
			local nPos = 0
			if self.tData then
				nPos = self.tData.nDp
			end
			if nPos == 0 then
				nPos = table.nums(Player:getHeroInfo():getDefenseHeroList()) +1
			end
			SocketManager:sendMsg("reqHeroAddTcfTeam", {pViewData.nId,nPos, 2},handler(self, self.onGetDataFunc))
		elseif self.nTeamType == e_hero_team_type.selfchoose then
			local nPos = 0
			if self.nSelfP then
				nPos = self.nSelfP
			end
			if nPos == 0 then
				nPos = table.nums(Player:getHeroInfo():getChooseList()) + 1
			end
			local chooselist = Player:getHeroInfo():getChooseList()
			local tIdList = {}
			if chooselist then
				for i=1 , #chooselist do
					if nPos == i then
						table.insert(tIdList, pViewData.nId)
					else
						table.insert(tIdList, chooselist[i].h)
					end
				end
			end
			if nPos > #chooselist then
				table.insert(tIdList, pViewData.nId)
			end
			local sStr = table.concat(tIdList,";")
			SocketManager:sendMsg("wipeteamset", {sStr},handler(self, self.onGetDataFunc))
		elseif self.nTeamType == e_hero_team_type.arena then
			local nPos = 0
			if self.tData then
				nPos = self.tData.nArenaIdx
			end
			if nPos == 0 then
				nPos = table.nums(Player:getArenaData():getArenaLineUp()) +1
			end
			local tObj = {}
			tObj.pHeroData = pViewData
			tObj.nIdx = nPos						
			sendMsg(ghd_adjust_arena_hero_msg, tObj)
			closeDlgByType(e_dlg_index.selecthero,false)		
		else
			--指定位置
			local nPos = 0
			if self.tData then
				nPos = self.tData.nP
			end
			if nPos == 0 then
				nPos = table.nums(Player:getHeroInfo():getOnlineHeroList()) +1
			end

			SocketManager:sendMsg("goToFight", {pViewData.nId,nPos},handler(self, self.onGetDataFunc))
		end
	end
end

function DlgSelectHero:onBtnRefreshClicked(  )
	-- body
	if not self.tData then
		return
	end	
	local tObj = {}
	tObj.pHeroData = Player:getHeroInfo():getHero(self.tData.nId)
	tObj.nIdx = self.tData.nArenaIdx						
	sendMsg(ghd_adjust_arena_hero_msg, tObj)
	closeDlgByType(e_dlg_index.selecthero,false)		
end

--接收服务端发回的登录回调
function DlgSelectHero:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
		if self.pViewData then
			local tObject = {} 
			tObject.pHero = self.pViewData --当前武将数据
			sendMsg(gud_replace_hero,tObject)
		end
		closeDlgByType(e_dlg_index.selecthero,false)
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end
end


-- 修改控件内容或者是刷新控件数据
function DlgSelectHero:updateViews(  )

	if self.tData  then
		local pData = nil			
		if self.nTeamType == e_hero_team_type.arena then--确保显示玩家的武将数据而非竞技场阵容的武将数据
			pData = Player:getHeroInfo():getHero(self.tData.nId)
		else
			pData = self.tData
		end
		if not pData then
			return
		end		
		if not self.tLyTalentInfo  then --括号内都只是初始化的
			--资质数据显示
			self.tLyTalentInfo = {}
			for i=1,3 do
				local pView = self:findViewByName("ly_talent_"..i)
				self.tLyTalentInfo[i] = ItemHeroInfoLb.new(i,2)
				pView:addView(self.tLyTalentInfo[i],10)
			end
			--icon
			local pLyIcon = self:findViewByName("ly_icon")
			self.pIcon  =  getIconHeroByType(pLyIcon,TypeIconHero.NORMAL,pData)
			self.pIcon:setHeroType()

			--资质
			self.pLbAptitude = self:findViewByName("lb_talent_4")

			self.pLyTop = self:findViewByName("ly_top")
			--武将名称,vip等级

		    --等级富文本
		    local strTips1 = {
		    	{color=getColorByQuality(pData.nQuality),text=pData.sName},
		    	{color=getColorByQuality(pData.nQuality),text=getLvString(pData.nLv)},
		    }

	    	self.pRichViewTips1 = MUI.MLabel.new({text= "",size = 22})
		    self.pRichViewTips1:setPosition(138,89)
		    self.pRichViewTips1:setString(strTips1)
		    self.pRichViewTips1:setAnchorPoint(cc.p(0,0))
		    self.pLyTop:addView(self.pRichViewTips1,10)

			--lb
			self.pLbBattle		= 		self.pSelectView:findViewByName("lb_battle")
			self.pLbBattle:setString(getConvertedStr(5, 10028))
			self.pLbBattle:setVisible(false)
			setTextCCColor(self.pLbBattle,_cc.green)

			self.pImgBattle 	=		self.pSelectView:findViewByName("img_battle")
			self.pImgBattle:setVisible(false)
			if self.nTeamType == e_hero_team_type.arena then				
				self.pLayBtnR = self:findViewByName("lay_r_btn")
				self.pBtnRefresh = getCommonButtonOfContainer(self.pLayBtnR,TypeCommonBtn.M_BLUE,getConvertedStr(6,10839),false)	
				self.pBtnRefresh:onCommonBtnClicked(handler(self, self.onBtnRefreshClicked))
				local bShow = pData:getBaseSc() > self.tData:getBaseSc()					
				self.pBtnRefresh:setBtnVisible(bShow)
				local nRedNum = 0
				if bShow then
					nRedNum = 1
				end
				showRedTips(self.pLayBtnR, 0, nRedNum, 2)
			end
		end		


		--属性值
		for k,v in pairs(self.tLyTalentInfo) do
			local tData = pData.tAttList[k]
			if tData then
				if k == 1 then
					v:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), pData:getAtkLuo())
				elseif k == 2 then
					v:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), pData:getDefLuo())
				elseif k == 3 then
					v:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), pData:getTroopsLuo())
				end
			end
		end
		--非竞技场武将显示是否上阵
		if self.nTeamType ~= e_hero_team_type.arena then
			--是否已上阵
			if pData.nP and pData.nP > 0 then
				-- self.pLbBattle:setVisible(true)
				self.pImgBattle:setVisible(true)
			else
				-- self.pLbBattle:setVisible(false)
				self.pImgBattle:setVisible(false)
			end			
		end

		--资质
		local sExText = "+"..pData:getExTotalTalent()

		local sAptitudeStr = {
			{text = getConvertedStr(5, 10036), color = _cc.pwhite},
			{text = tostring(pData:getBaseTotalTalent()), color = _cc.blue},
			{text = sExText, color = _cc.green},
		}
		self.pLbAptitude:setString(sAptitudeStr)

	end

	--目标英雄指引的id
	self.nTarHeroId = self:getTarHeroGuide()

	--切换卡
	--内容层
	if not self.pLyContent then
		self.pLyContent 	  = 		self.pSelectView:findViewByName("ly_content")
		self.pTComTabHost = TCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.onIndexSelected))
		self.pLyContent:addView(self.pTComTabHost,10)
		self.pTComTabHost:removeLayTmp1()
		if self.tData then
			self.pTComTabHost:setPositionY(10)
		end
		--默认选中第一项
		self.pTComTabHost:setDefaultIndex(1)
		self.nSelectIdx = 1
		--创建武将队列
		self:createListView()
	end

end

--获取目标武将的指引
function DlgSelectHero:getTarHeroGuide()
	-- body
	--当前任务
	local tCurTask = Player:getPlayerTaskInfo():getCurAgencyTask()
	local nTarHeroId = nil
	if tCurTask then
		local nCurTaskId = tCurTask.sTid
		if nCurTaskId == e_special_task_id.online_sun or         --上阵孙尚香
	 	nCurTaskId == e_special_task_id.online_jing or           --上阵荆轲
	 	nCurTaskId == e_special_task_id.online_gao then          --上阵高渐离
 			nTarHeroId = tonumber(tCurTask.sTarget)
	 	end
 	end
 	return nTarHeroId
end

-- 析构方法
function DlgSelectHero:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgSelectHero:regMsgs( )
	-- body
end

-- 注销消息
function DlgSelectHero:unregMsgs(  )
	-- body
end


--暂停方法
function DlgSelectHero:onPause( )
	-- body
	self:unregMsgs()
	self.nTarPos = nil
end

--继续方法
function DlgSelectHero:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgSelectHero