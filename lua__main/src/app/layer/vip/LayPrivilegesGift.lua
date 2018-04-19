-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-2-26 20:17:23 星期一
-- Description: 特权页面礼包界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemPrivilegesLayer = require("app.layer.vip.ItemPrivilegesLayer")
local LayPrivilegesGift = class("LayVipPrivileges", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayPrivilegesGift:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()

	self:setupViews()
	self:onResume()	
	--注册析构方法
	self:setDestroyHandler("LayPrivilegesGift",handler(self, self.onDestroy))	
end

--初始化参数
function LayPrivilegesGift:myInit()
	-- body
	self.tVips = getAvatarVIPData()
	-- dump(self.tVips, "self.tVips", 100)
end

--初始化控件
function LayPrivilegesGift:setupViews( )
	--body
	
end

-- 修改控件内容或者是刷新控件数据
function LayPrivilegesGift:updateViews()
	-- body		
	local nItemCnt = #self.tVips
	if not self.pListView then		
	    self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, 640, self:getHeight()),
            itemMargin = {left = 0,
            right = 0,
            top = 10 ,
            bottom = 5 },
            direction = MUI.MScrollView.DIRECTION_VERTICAL ,--listView方向
        }
        self.pListView:setBounceable(true) --是否回弹        
        self:addView(self.pListView, 10)
        --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		self.pListView:setItemCount(nItemCnt)
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))
		self.pListView:reload(false)	
	else		
		self.pListView:notifyDataSetChange(false, nItemCnt)
	end	
end

function LayPrivilegesGift:onEveryCallback( _index, _pView )
	-- body
    local pView = _pView
	if not pView then
		pView = ItemPrivilegesLayer.new()
		pView:setViewTouched(false)
		pView:setIsPressedNeedScale(false)					
	end
	pView:setCurData(self.tVips[_index - 1])	
	return pView	
end

--析构方法
function LayPrivilegesGift:onDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function LayPrivilegesGift:regMsgs(  )
	-- body
	--注册玩家数据刷新消息
	regMsg(self, gud_refresh_playerinfo, handler(self, self.updateViews))	
	--vip礼包购买刷新
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))	
end
--注销消息
function LayPrivilegesGift:unregMsgs( )
	-- body
	--注销玩家数据刷新消息
	unregMsg(self, gud_refresh_playerinfo)	
	unregMsg(self, gud_vip_gift_bought_update_msg)	
end


--暂停方法
function LayPrivilegesGift:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function LayPrivilegesGift:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return LayPrivilegesGift