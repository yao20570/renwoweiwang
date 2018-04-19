-- Author: liangzhaowei
-- Date: 2017-06-07 20:31:41
-- 显示聊天未展示条数item
local MCommonView = require("app.common.MCommonView")
local ItemShowChatNums = class("ItemShowChatNums", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemShowChatNums:ctor()
	-- body
	self:myInit()

	parseView("item_show_chat_nums", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemShowChatNums",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemShowChatNums:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemShowChatNums:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemShowChatNums:setupViews( )
	--ly
	self.pLyMain = self:findViewByName("item_show_chat_nums")         	

	--lb
	self.pLbNums = self:findViewByName("lb_nums")
	self.pLbNums:setZOrder(11)

end

-- 修改控件内容或者是刷新控件数据
function ItemShowChatNums:updateViews(  )
	-- body
end

--析构方法
function ItemShowChatNums:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemShowChatNums:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self.pLbNums:setString("+"..self.pData)

	--self.pLbN:setString(self.pData.sName or "")
	

end


return ItemShowChatNums