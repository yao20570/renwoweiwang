----------------------------------------------
-- Author: maheng
-- Date: 2018-03-07 19:49:16
-- 编辑自顶级建造顺序
----------------------------------------------

local DlgAlert = require("app.common.dialog.DlgAlert")
local ItemCustomBuildOrder = require("app.layer.autobuild.ItemCustomBuildOrder")
local DlgCustomBuildOrder = class("DlgCustomBuildOrder", function ()
	return DlgAlert.new(e_dlg_index.custombuildorder)
end)

--构造
function DlgCustomBuildOrder:ctor(_pBuild)
	-- body
	self:myInit()
	self.pBuild = _pBuild

	local pView = MUI.MLayer.new()
	pView:setContentSize(cc.size(400, 380))
	pView:setName("DlgCustomBuildOrder_Root")
	self.pLayRoot = pView
	self:addContentView(pView, true)
	self:setupViews()
	self:onResume()
	--注册析构方法
    self:setDestroyHandler("DlgCustomBuildOrder",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgCustomBuildOrder:myInit()
	-- body
	self.pBuild = nil
	self.nSelect = nil
	self.nCurOrder = nil
end

--初始化控件
function DlgCustomBuildOrder:setupViews()
	-- body
	self:setTitle(getConvertedStr(7, 10451))
	self:setLeftHandler(handler(self, self.closeAlertDlg))
	self:setRightHandler(handler(self, self.onSureBtnClicked))
end


-- 修改控件内容或者是刷新控件数据
function DlgCustomBuildOrder:updateViews()
	-- body	
	local pData = Player:getBuildData()
	if not pData or not self.pBuild then
		return
	end
	local pBuild = self.pBuild
	if not self.nSelect then
		self.nSelect = pData:getBuildOrderById(pBuild.sTid)	
		-- dump(self.nSelect, "self.nSelect", 100)
	end		
	local nCnt = pData:getMyOrdersCnt()
	if not self.pListView then
		local pSize = self.pLayRoot:getContentSize()
		self.pListView = MUI.MListView.new {
			viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
			direction  = MUI.MScrollView.DIRECTION_VERTICAL,
			itemMargin = {left =  0,
	            right =  0,
	            top =  10,
	            bottom =  5},
	    }
	    self.pLayRoot:addView(self.pListView)
		self.pListView:setItemCallback(function ( _index, _pView ) 
		    local pTempView = _pView
		    if pTempView == nil then
		    	pTempView   = ItemCustomBuildOrder.new()
		    	pTempView:setItemClickedHandler(handler(self, self.onItemClicked))
			end
			pTempView:setData(_index, self.nSelect, self.pBuild)
		    return pTempView
		end)
		self.pListView:setItemCount(nCnt)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:reload(false)
	else
		self.pListView:setItemCount(nCnt) 
		self.pListView:notifyDataSetChange(false)
	end
end

function DlgCustomBuildOrder:onItemClicked( _index )
	-- body
	self.nSelect = _index or self.nSelect
	self.pListView:notifyDataSetChange(false)
end

function DlgCustomBuildOrder:onSureBtnClicked(  )
	-- body
	local buildData = Player:getBuildData()
	if not self.pBuild or not self.nSelect then
		return
	end
		
	local nBuildId = self.pBuild.sTid
	local nOrgOrder = buildData:getBuildOrderById(nBuildId)
	local nSelect = self.nSelect
	if nOrgOrder == nSelect then
		return
	end
	local bBig = nSelect > nOrgOrder --
	local tOrders = buildData:getCustomOrders()
	table.sort(tOrders, function ( a, b)
		-- body
		return a.v < b.v
	end)
	-- dump(tOrders, "tOrders --1", 100)
	for idx, v in pairs(tOrders) do 
		if bBig then
			if v.v == nOrgOrder then
				v.v = nSelect
			elseif v.v > nOrgOrder and v.v <= nSelect then
				v.v = idx - 1
			end
		else
			if v.v == nOrgOrder then
				v.v = nSelect
			elseif v.v < nOrgOrder and v.v >= nSelect then
				v.v = idx + 1
			end
		end
	end
	-- dump(tOrders, "tOrders --2", 100)
	local tParams = ""
	for idx, v in pairs(tOrders) do
		tParams = tParams..v.k..":"..v.v..";"
	end
	SocketManager:sendMsg("reqCustomPriority", {tParams})
	self:closeAlertDlg()
end
function DlgCustomBuildOrder:setData( _pBuild )
	-- body
	self.pBuild = _pBuild or self.pBuild	
	self:updateViews()
end

--析构方法
function DlgCustomBuildOrder:onDestroy()
	self:onPause()	   	
end

-- 注册消息
function DlgCustomBuildOrder:regMsgs( )
	-- body
end

-- 注销消息
function DlgCustomBuildOrder:unregMsgs(  )
	-- body
end


--暂停方法
function DlgCustomBuildOrder:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgCustomBuildOrder:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgCustomBuildOrder
