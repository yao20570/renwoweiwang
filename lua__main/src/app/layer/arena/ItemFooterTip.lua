-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-22 10:20:23 星期四
-- Description: 纣王试炼主页奖励项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemFooterTip = class("ItemFooterTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemFooterTip:ctor()
	-- body	
	self:myInit()
	parseView("item_footer_tip", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function ItemFooterTip:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)

	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("ItemFooterTip",handler(self, self.onDestroy))
end

-- --初始化参数
function ItemFooterTip:myInit()
	-- body
	self.nHandler = nil
end

--初始化控件
function ItemFooterTip:setupViews( )
	-- body		
	self.pLayRoot = self:findViewByName('default')
	self.pLayBg = self:findViewByName("lay_bg")
	self.pLbTip = self:findViewByName("lb_tip")

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onClicked))

end

-- 修改控件内容或者是刷新控件数据
function ItemFooterTip:updateViews(  )
	-- body

end

function ItemFooterTip:setItemClickHandler( _nHandler )
	-- body
	if not _nHandler then
		return
	end
	self.nHandler = _nHandler
end

function ItemFooterTip:onClicked()
	if self.nHandler then
		self.nHandler()
	end
end

function ItemFooterTip:setData(_tParam)
	-- body
	if not _tParam then
		return 
	end
	if _tParam.text then
		self.pLbTip:setString(_tParam.text, false)
	end
	if _tParam.color then
		setTextCCColor(self.pLbTip, _tParam.color)
	end
end

--析构方法
function ItemFooterTip:onDestroy(  )
	self:onPause()
end

-- 注册消息
function ItemFooterTip:regMsgs( )
	-- body	   
end

-- 注销消息
function ItemFooterTip:unregMsgs(  )
	-- body

end
--暂停方法
function ItemFooterTip:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemFooterTip:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return ItemFooterTip
