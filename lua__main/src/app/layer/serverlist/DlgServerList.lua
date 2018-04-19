-----------------------------------------------------
-- author: xiesite
-- Date: 2018-02-28 18:30:56
-- Description: 服务器列表
-----------------------------------------------------

local MDialog = require("app.common.dialog.MDialog")
local TCommonTabHost = require("app.common.tabhost.TCommonTabHost")
local ItemServerView = require("app.layer.serverlist.ItemServerView")
-- local ItemDoubleServer = require("app.layer.serverlist.ItemDoubleServer")
-- local ItemDoubleMyServer = require("app.layer.serverlist.ItemDoubleMyServer")

-- local SERVERLISTMAXNUM = 50 --服务器列表中单页最大个数
local DlgServerList = class("DlgServerList", function()
	-- body
	return MDialog.new(e_dlg_index.serverlist)
end)

function DlgServerList:ctor(  )
	-- body
	self:myInit()
	self:refreshData() --刷新数据
	parseView("dlg_login_serverlist", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgServerList:myInit()
	self.tServerStrList = {}	--所有服务器列表
	self.tMyServerList = {} --我的服务器列表
	self.tShowServerList = {} --显示列表
	self.nSelectTab = 1 --当前所选择的引导服务器列表
	-- self.tShowListServer = {}--显示服务器列表
	self.tTitles = {getConvertedStr(1,10365),getConvertedStr(1,10366)}
end

--刷新数据
function DlgServerList:refreshData()
    --获取服务器引导列表
    self:getServerStrList()
end

--获取服务器引导列表
function DlgServerList:getServerStrList()
	--所有服务器
	local tAllServers = {}
	if AccountCenter.allServer and table.nums(AccountCenter.allServer) > 0 then
		tAllServers = copyTab(AccountCenter.allServer)
	end
	-- dump(tAllServers, "tAllServers")

	self:dealEnterList()
	--最近服务器
	local tEnterServers = {}
	if AccountCenter.enterServerList and table.nums(AccountCenter.enterServerList) > 0 then
		tEnterServers = copyTab(AccountCenter.enterServerList)
	end
	-- dump(tEnterServers, "tEnterServers")

	--选中的服务器
	local tNowServers ={}
	if AccountCenter.nowServer and table.nums(AccountCenter.nowServer) > 0 then
		tNowServers = copyTab(AccountCenter.nowServer)
	end
	-- dump(tNowServers, "tNowServers")
 
	--所有服务器处理
	for k, v in ipairs(tAllServers) do
		if v and v.id then
			for key, value in ipairs(tEnterServers) do
				if v.id == value.id then
					v.lv = value.lv
					v.nRecent = value.nRecent
					v.name = value.name
					v.vip = value.vip
					break
				end
			end
		end
	end
	self.tServerStrList = tAllServers
	self:sortServerList(self.tServerStrList)
 
	--我的服务器处理
	if table.nums(tEnterServers) == 0 and table.nums(tNowServers) > 0 then
		self.tMyServerList[1] = tNowServers
	else
		self.tMyServerList = tEnterServers
	end
	self:sortServerList(self.tMyServerList, true)
end


--解析布局回调事件
function DlgServerList:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:setContentView(self.pView)
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgServerList",handler(self, self.onDestroy))

end

--更新切换卡
function DlgServerList:updateTabHost()
	--创建类表中的英雄
	if not self.pTComTabHost then
		self.pLyContent   = self.pView:findViewByName("ly_content")
		self.pTComTabHost = TCommonTabHost.new(self.pLyContent,3,1,self.tTitles,handler(self, self.onIndexSelected),handler(self, self.onNotOpenSelected))
		self.pTabItems = self.pTComTabHost:getTabItems()
		self.pLyContent:addView(self.pTComTabHost,10)
		self.pTComTabHost:removeLayTmp1()
		self.pTComTabHost:setDefaultIndex(1)
	end

	self.tShowServerList = {}
	if self.nSelect == 1 then
		self.tShowServerList = copyTab(self.tMyServerList)
	else
	 	self.tShowServerList = copyTab(self.tServerStrList)
	end

	local nMailCnt = #self.tShowServerList
	if not self.pListView then
		self:createListView(nMailCnt)
	else
		self.pListView:notifyDataSetChange(true, nMailCnt)
	end

end



--下标选择回调事件
function DlgServerList:onIndexSelected( _index )
	self.nSelect = _index
	--刷新列表
	self:updateTabHost()
end

--未开启tab回调事件
function DlgServerList:onNotOpenSelected(_index)
	getIsReachOpenCon(18)
end


--初始化控件
function DlgServerList:setupViews( )
	--ly
	self.pLyServerList	    		= 		self.pView:findViewByName("ly_list")
 	self.pImgClose = self:findViewByName("img_close")
	self.pImgClose:setViewTouched(true)
	self.pImgClose:onMViewClicked(handler(self, self.onClose))

	self:updateTabHost()	
end


function DlgServerList:onClose()
	self:closeDialog()
end

--创建listView
function DlgServerList:createListView(_count)
--创建listView
	self.pListView = createNewListView(self.pLyServerList)
	-- self.pListView = createNewListView(self.pLayTabHost)
	--上下箭头
	self.pListView:setItemCount(_count)
	self.pListView:setItemCallback(function ( _index, _pView ) 
	    local pView = _pView
		if not pView then
			if self.tShowServerList[_index] then
				pView = ItemServerView.new()
			end
		end
		if _index and self.tShowServerList[_index] then
			pView:setCurData(self.tShowServerList[_index] )	
		end
		return pView
	end)
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)	
	self.pListView:reload()
end

-- 没帧回调 _index 下标 _pView 视图
function DlgServerList:onTabEveryCallback( _index, _pView )
	-- local pView = _pView
	-- if not pView then
	-- 	if self.tServerStrList[_index] then
	-- 		pView = ItemServerTab.new()
	-- 		pView:setHandler(handler(self, self.clickTabItem))
	-- 	end
	-- end

	-- if _index and self.tServerStrList[_index] then
	-- 	pView:setCurData(self.tServerStrList[_index],_index,self.nSelectTab)	
	-- end

	-- return pView
end

--点击引导item回调
function DlgServerList:clickTabItem(_pData)
	-- if _pData then
	-- 	if self.nSelectTab ~= _pData then
	-- 		self.nSelectTab = _pData
	--     	--重新获取服务器列表数据
	--     	self.pTabListView:notifyDataSetChange(false)
	--     	self:resetShowServerListData()
	--     	self:refreshMoreAcc()
	-- 	end
	-- end
end


-- 没帧回调 _index 下标 _pView 视图
function DlgServerList:onPageSvEveryCallback( _index, _pView )
	-- local pView = _pView
	-- if not pView then
	-- 	if self.tShowListServer[_index] then
	-- 		pView = ItemDoubleServer.new()
	-- 	end
	-- end

	-- if _index and self.tShowListServer[_index] then
	-- 	pView:setCurData(self.tShowListServer[_index])	
	-- end

	-- return pView
end

-- 没帧回调 _index 下标 _pView 视图
function DlgServerList:onMyEveryCallback( _index, _pView )
	-- local pView = _pView
	-- if not pView then
	-- 	if self.tShowRecommentServer[_index] then
	-- 		pView = ItemDoubleMyServer.new()
	-- 	end
	-- end

	-- if _index and self.tShowRecommentServer[_index] then
	-- 	pView:setCurData(self.tShowRecommentServer[_index])	
	-- end

	-- return pView
end





--获取服务器列表数据
function DlgServerList:resetShowServerListData()
	-- self.tShowListServer = {}
	-- local tListData = {}

	-- local nServerListNums = math.ceil(table.nums(AccountCenter.allServer)/SERVERLISTMAXNUM) --余数
	-- local nTotalSer = #AccountCenter.allServer
	-- for k,v in pairs(AccountCenter.allServer) do
	-- 	if ((nTotalSer - k + 1) <= SERVERLISTMAXNUM*(nServerListNums-self.nSelectTab+1) 
	-- 			and (nTotalSer - k + 1) >= SERVERLISTMAXNUM*(nServerListNums-self.nSelectTab) + 1) then
	-- 		if #tListData == 1 then
	-- 			table.insert(tListData, v)
	-- 			table.insert(self.tShowListServer, tListData)
	-- 			tListData = {}
	-- 		else
	-- 			table.insert(tListData, v)
	-- 			if (nTotalSer - k + 1)==(SERVERLISTMAXNUM*(nServerListNums-self.nSelectTab) + 1) then
	-- 				table.insert(self.tShowListServer, tListData)
	-- 			end
	-- 		end
	-- 	end
	-- end
end

function DlgServerList:dealEnterList()
	local pDlg, bNew = getDlgByType(e_dlg_index.dlgsettingmain)
 	local pAddServer = copyTab(AccountCenter.nowServer)--需要添加的服务器

	if AccountCenter.enterServerList then
		--存在设置界面
		if not bNew then
			local bFind = false
			if pAddServer then
				for k,v in pairs(AccountCenter.enterServerList) do
					if v.id == pAddServer.id then
						bFind = true
						v.nRecent = 1 --增加最近服的排序
					else
						if v.nRecent and v.nRecent > 0 then
							v.nRecent = 0--将原有记录的最近服状态清除
						end
					end
				end
				if not bFind then
					pAddServer.nRecent = 1 --增加最近服的排序
					pAddServer.name = Player:getPlayerInfo().sName
					pAddServer.lv = Player:getPlayerInfo().nLv
					pAddServer.vip = Player:getPlayerInfo().nVip
					table.insert(AccountCenter.enterServerList ,pAddServer)
				end
			end
		end
	end
end

--获取显示最近登录服的数据
function DlgServerList:sortServerList(_list)
	if not _list then
		return
	end

	--判断现在是不是设置界面
	table.sort(_list,function (a,b)
			if (a.nRecent and a.nRecent > 0) and (b.nRecent and b.nRecent > 0) then
				return a.sort > b.sort
			elseif a.nRecent and a.nRecent > 0 then
				return true --如果是最后登录过的服则需要排在前面
			elseif b.nRecent and b.nRecent > 0 then
				return false
			else
				return a.sort > b.sort
			end
	end)
end



--刷新更多服务器列表
function DlgServerList:refreshMoreAcc()

	-- if self.pPageServerListView then
	-- 	if self.pPageServerListView:getItemCount() > 0 then
	-- 		self.pPageServerListView:removeAllItems()
	-- 	end
	-- 	if self.tShowListServer then
	-- 		self.pPageServerListView:setItemCount(table.nums(self.tShowListServer) or 0) 
	-- 		self.pPageServerListView:reload()
	-- 	end
	-- end

end


-- 修改控件内容或者是刷新控件数据
function DlgServerList:updateViews(  )
	-- body
end

-- 析构方法
function DlgServerList:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgServerList:regMsgs( )
	-- body
end

-- 注销消息
function DlgServerList:unregMsgs(  )
	-- body
end


--暂停方法
function DlgServerList:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgServerList:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgServerList