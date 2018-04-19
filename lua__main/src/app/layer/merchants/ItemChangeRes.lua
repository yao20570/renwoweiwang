-- ItemChangeRes.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-3-9 17:28:55 星期五
-- Description: 兑换资源item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemChangeRes = class("ItemChangeRes", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
--_data：当前科技数据
function ItemChangeRes:ctor( _data )
	-- body
	self:myInit()
	self.tCurData = _data
	parseView("item_change_res", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemChangeRes:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function ItemChangeRes:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemChangeRes",handler(self, self.onItemChangeResDestroy))
end

--初始化控件
function ItemChangeRes:setupViews( )
	-- body
	--名字背景
	self.pImgNameBg 	= self:findViewByName("img_nm_bg")
	--资源图片
	self.pImgIcon 		= self:findViewByName("img_icon")
	self.pImgIcon:setScale(1.4)
	--数量文本
	self.pLbNum 		= self:findViewByName("lb_num")
	--名字
	self.pLbName 		= self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.blue)
end


-- 修改控件内容或者是刷新控件数据
function ItemChangeRes:updateViews(  )
	-- body
	if not self.tCurData then
		return
	end
	self.pImgIcon:setCurrentImage(self.tCurData.sIcon)
	self.pLbName:setString(self.tCurData.sName)
end

--设置数量文本
function ItemChangeRes:setNumTx(_str)
	self.pLbNum:setString(_str)
	self.pImgNameBg:setLayoutSize(self.pLbNum:getWidth() + 10, self.pImgNameBg:getHeight())
end

-- 析构方法
function ItemChangeRes:onItemChangeResDestroy(  )
	-- body
end

--设置当前数据
function ItemChangeRes:setResData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end


return ItemChangeRes