--
-- Author: maihuahao
-- Date: 2017-03-28 16:57:13
-- Description: 最近账号显示框


local MCommonBase = require("app.common.MCommonView")

local ItemAccoutList = class("ItemAccoutList", function ()
	return MCommonBase.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建
function ItemAccoutList:ctor()
	self:myInit()

	--添加控件后并初始化
	self:initViews()
	self:updateViews()
end

--读入控件后,初始化参数值
function ItemAccoutList:myInit()
	self.pHandler = nil
end

--读入控件
function ItemAccoutList:initViews()
	parseView("item_registered_account", handler(self, self.onParseViewCallback))
end


--解析布局回调事件
function ItemAccoutList:onParseViewCallback( pView )
	-- body
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self.pTxtAccout = self:findViewByName("label_accout")
	self.pLayoutList = self:findViewByName("all")	
	self.pLayoutList:setViewTouched(true)
	self.pLayoutList:setIsPressedNeedScale( false)
	self.pLayoutList:onMViewClicked(handler(self, self.onClickCallBack))
end


--设置账号
--方法说明
--program1 _sAccout 账号的字符串
function ItemAccoutList:setAccoutStr(_sAccout)
	if _sAccout =="" then
		return
	end

	self._strAccout = _sAccout..""  --如果传的是数字,直接转为字符串
	self.pTxtAccout:setString(_sAccout)

end

--设置初始化控件
function ItemAccoutList:updateViews()

end

function ItemAccoutList:setHandler(_handler)
	self.pHandler = _handler
end

--设置item对应id
function ItemAccoutList:setIdNum(_nNum)
	self.nItemId = _nNum
end



--点击回调
function ItemAccoutList:onClickCallBack( )
	if self.pHandler then
		self.pHandler(self.nItemId)
	end
end


return ItemAccoutList