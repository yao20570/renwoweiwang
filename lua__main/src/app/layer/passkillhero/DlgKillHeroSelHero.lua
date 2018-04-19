-----------------------------------------------------
-- author: dshulan
-- Date: 2018-03-16 18:24:47
-- Description: 过关斩将选择上阵武将界面
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroArmy = require("app.layer.hero.ItemHeroArmy")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")


local DlgKillHeroSelHero = class("DlgKillHeroSelHero", function()
	return DlgCommon.new(e_dlg_index.killheroselhero)
end)

function DlgKillHeroSelHero:ctor(_tData,_nPos)
	-- body
	self:myInit()
	self.tData = _tData
	self.nPos = _nPos
	self:setTitle(getConvertedStr(5, 10030))
	parseView("dlg_hero_army_list_sort", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgKillHeroSelHero:myInit(  )
	-- body
	self.tData = {} --英雄数据

	self.tHeroListData = {} --英雄列表
	self.tShowHeroList = {} --展示英雄列表

	self.tTitles 	   = {
		getConvertedStr(5,10031),
		getConvertedStr(5,10033),
	  	getConvertedStr(5,10032),
	  	getConvertedStr(5,10034)
	}
end

--初始化数据
function DlgKillHeroSelHero:initData()
	local tHeroList = copyTab(Player:getHeroInfo():getHeroList())
	local pKillHeroData = Player:getPassKillHeroData()
	local tHeroOnlineList = pKillHeroData:getOnlineHero() --已上阵的英雄列表
	for i = #tHeroList, 1, -1 do
		tHeroList[i].bOnline = 0
		for _, hero in pairs(tHeroOnlineList) do
			if tHeroList[i].nId == hero.nId then
				table.remove(tHeroList, i)
				break
			end
		end
	end
	if type(self.tData) == "table" then
		self.tData.bOnline = 1
		table.insert(tHeroList, self.tData)
	end
	self.tHeroListData = tHeroList
	self.tShowHeroList = self.tHeroListData --展示英雄列表
end

--解析布局回调事件
function DlgKillHeroSelHero:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView,false) --加入内容层

	self:initData()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgKillHeroSelHero",handler(self, self.onDestroy))
end

--下标选择回调事件
function DlgKillHeroSelHero:onIndexSelected( _index )
	self.nSelectIdx = _index

	if _index == 1 then --全部
		self.tShowHeroList = self.tHeroListData
	elseif _index == 2 then --步将
		self.tShowHeroList = {}
		for k,v in pairs(self.tHeroListData) do
			if v.nKind == en_soldier_type.infantry then
				table.insert(self.tShowHeroList,v)
			end
		end
	elseif _index == 3 then --骑将
		self.tShowHeroList = {}
		for k,v in pairs(self.tHeroListData) do
			if v.nKind == en_soldier_type.sowar then
				table.insert(self.tShowHeroList,v)
			end
		end
	elseif _index == 4 then --弓将
		self.tShowHeroList = {}
		for k,v in pairs(self.tHeroListData) do
			if v.nKind == en_soldier_type.archer then
				table.insert(self.tShowHeroList,v)
			end
		end
	end

	self:sortHeroList(self.tShowHeroList)

	if self.pListView then
		local nCurrCount = table.nums(self.tShowHeroList)
		self.pListView:notifyDataSetChange(true, nCurrCount)

		if #self.tShowHeroList > 0 then
			self.pNullUi:setVisible(false)
		else
			self.pNullUi:setVisible(true)
		end
	end

end

--对显示的英雄进行排位
function DlgKillHeroSelHero:sortHeroList(_heroList)
	-- body
	local pKillHeroData = Player:getPassKillHeroData()
	if _heroList and table.nums(_heroList)> 0 then
		table.sort( _heroList, function (a,b)
			local aDeadType = pKillHeroData:getDeadType(a.nId)
			local bDeadType = pKillHeroData:getDeadType(b.nId)
			local aNSc = a.nSc*(pKillHeroData:getHeroProById(a.nId))
			local bNSc = b.nSc*(pKillHeroData:getHeroProById(b.nId))
			if a.bOnline == b.bOnline then
				if aDeadType == bDeadType then --阵亡状态
					if aNSc == bNSc then 		--战力
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
						return aNSc > bNSc
					end
				else
					return aDeadType > bDeadType
				end
			else
				return a.bOnline > b.bOnline
			end

		end )
	end
end

--创建listView
function DlgKillHeroSelHero:createListView()
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
end

-- 没帧回调 _index 下标 _pView 视图
function DlgKillHeroSelHero:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tShowHeroList[_index] then
			local nType = 2
			pView = ItemHeroArmy.new(_index,self.tShowHeroList[_index], nType)
			pView:setHandler(handler(self, self.onBtnClick))
		end
	else
		if _index and self.tShowHeroList[_index] then
			pView:setCurData(self.tShowHeroList[_index])	
		end
	end

	return pView
end

--item按钮回调
function DlgKillHeroSelHero:onBtnClick(pData)
	-- body
	local pViewData = pData
 
	self.pViewData = pData --记录需要上阵的武将
	if pViewData and pViewData.nId then
		local bHasOnline = Player:getPassKillHeroData():getIsOnlineById(pViewData.nId)
		--如果已上阵就下阵, 否则就上阵
		if bHasOnline then
			Player:getPassKillHeroData():saveOfflineHero(pViewData.nId)
			TOAST(getConvertedStr(7,10392))
		else
			Player:getPassKillHeroData():saveOnlineHero(pViewData.nId, self.nPos)
			TOAST(getConvertedStr(7,10391))
		end
	end
	self:closeCommonDlg()
end

-- 修改控件内容或者是刷新控件数据
function DlgKillHeroSelHero:updateViews(  )
	--切换卡
	--内容层
	if not self.pLyContent then
		self.pLyContent 	  = 		self.pSelectView:findViewByName("ly_content")
		self.pTComTabHost = TCommonTabHost.new(self.pLyContent,1,1,self.tTitles,handler(self, self.onIndexSelected))
		self.pLyContent:addView(self.pTComTabHost,10)
		self.pTComTabHost:removeLayTmp1()
		--默认选中第一项
		self.pTComTabHost:setDefaultIndex(1)
		self.nSelectIdx = 1
		--创建武将队列
		self:createListView()
	end
end

-- 析构方法
function DlgKillHeroSelHero:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgKillHeroSelHero:regMsgs( )
	-- body
	--过关斩将武将上下阵刷新消息
	-- regMsg(self, gud_refresh_pass_kill_online_hero_msg, handler(self, ))
end

-- 注销消息
function DlgKillHeroSelHero:unregMsgs(  )
	-- body
	--销毁过关斩将武将上下阵刷新消息
	-- unregMsg(self, gud_refresh_pass_kill_online_hero_msg)
end


--暂停方法
function DlgKillHeroSelHero:onPause( )
	-- body
	self:unregMsgs()
	self.nTarPos = nil
end

--继续方法
function DlgKillHeroSelHero:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgKillHeroSelHero