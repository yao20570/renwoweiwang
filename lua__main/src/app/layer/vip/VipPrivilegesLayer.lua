-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-27 11:38:23 星期六
-- Description: vip特权展示层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemPrivilegesLayer = require("app.layer.vip.ItemPrivilegesLayer")
local ItemPrivilegesDetail = require("app.layer.vip.ItemPrivilegesDetail")
local VipPrivilegesLayer = class("VipPrivilegesLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function VipPrivilegesLayer:ctor(_nvipLv, _tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit(_nvipLv)
	parseView("vip_privileges_layer", handler(self, self.onParseViewCallback))
	--注册析构方法
	self:setDestroyHandler("VipPrivilegesLayer",handler(self, self.onDestroy))	
end

--初始化参数
function VipPrivilegesLayer:myInit(_nvipLv)
	-- body
	self.nVipLv = _nvipLv or 1
	self.tVip = nil 	
	self.tItemGroup = {}	
	self.tPrivilegesGroup = {}	
end

--解析布局回调事件
function VipPrivilegesLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function VipPrivilegesLayer:setupViews( )
	--body
	self.pLayRoot = self:findViewByName("root")
	self.pLayBot = self:findViewByName("lay_bot")
	self.pLayCont = self:findViewByName("lay_cont")	
	self.pLayList = self:findViewByName("lay_list")
	self.pLbTitle = self:findViewByName("lb_title")
	setTextCCColor(self.pLbTitle, _cc.yellow)

	self.pItemPrivilege = ItemPrivilegesLayer.new()
	self.pItemPrivilege:setPosition(0, 0)
	self.pItemPrivilege:setViewTouched(false)
	self.pItemPrivilege:setIsPressedNeedScale(false)	
	self.pLayBot:addView(self.pItemPrivilege, 10)
end

-- 修改控件内容或者是刷新控件数据
function VipPrivilegesLayer:updateViews(  )
	-- body	
	local tVip = getAvatarVIPByLevel(self.nVipLv)
	if not tVip then
		return
	end	
	self.pLbTitle:setString(getVipLvString(tVip.lv or 0), false)

	--说明列表
	self.tListData = {}
	if tVip.describe2 then
		local tDatas = luaSplit(tVip.describe2, '|')		
		for k, v in pairs(tDatas) do
			if v and v ~= "" then
				table.insert(self.tListData, v) 
			end
		end		
	end		
	
	local nItemCnt = #self.tListData
	if not self.pListView then		
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 0 ,
            bottom = 0 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹        
        self.pLayList:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:reload(false)	
	else		
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end	
	self.pItemPrivilege:setCurData(tVip)

end

function VipPrivilegesLayer:onEveryCallback( _index, _pView )
	-- body
    local pView = _pView
	if not pView then
		pView = ItemPrivilegesDetail.new()
		pView:setViewTouched(false)
		pView:setIsPressedNeedScale(false)					
	end
	pView:setCurData(self.tListData[_index])	
	return pView	
end
--析构方法
function VipPrivilegesLayer:onDestroy(  )
	-- body
end

--设置VIP等级
function VipPrivilegesLayer:setVipLevel( _viplevel )
	-- body
	self.nVipLv = _viplevel or self.nVipLv
	self:updateViews()
end


return VipPrivilegesLayer