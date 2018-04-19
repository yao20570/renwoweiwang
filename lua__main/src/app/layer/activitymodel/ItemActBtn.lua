-----------------------------------------------------
-- author: luwenjing
-- updatetime:  2017-11-16 14:57:19 星期四
-- Description: 活动标签按钮
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActBtn = class("ItemActBtn", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemActBtn:ctor( _nType)
	-- body
	self:myInit()
	self.nType = _nType or self.nType
	parseView("item_act_btn", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemActBtn:myInit(  )
	
end

--解析布局回调事件
function ItemActBtn:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)

	self:setupViews()
	self:updateViews()
	-- self:regMsgs()

	--注册析构方法
	self:setDestroyHandler("ItemActBtn",handler(self, self.onItemActBtnDestroy))
end
function ItemActBtn:setupViews( )
	-- body
	--背景层
	self.pItem 			= 		self:findViewByName("default")
	self.pItem:setViewTouched(true)
	self.pItem:setIsPressedNeedScale(false)
	self.pItem:onMViewClicked(handler(self, self.onItemClicked))

end

function ItemActBtn:updateViews( )
	-- body

end

function ItemActBtn:onItemClicked(pView )
	-- body
	
	if self.nType then
		--从打开活动id的前往讨伐界面
		if self.nType == e_id_activity.wuwang then
			local tObject = {}
		    tObject.nType = e_dlg_index.wuwang 	--跳到武王伐纣活动
		    sendMsg(ghd_show_dlg_by_type,tObject)
			return
		end

		local tObject = {}
		tObject.nType = e_dlg_index.dlgactivitydesc --dlg类型
		tObject.nActId = self.nType or 0 --活动id
		sendMsg(ghd_show_dlg_by_type,tObject)

	end
end

function ItemActBtn:onItemActBtnDestroy()

end



return ItemActBtn