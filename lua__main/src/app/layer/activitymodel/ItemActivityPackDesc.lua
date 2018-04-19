-- Author: liangzhaowei
-- Date: 2017-08-10 13:55:21
-- 活动标题模板描述语 

local MCommonView = require("app.common.MCommonView")
local ItemActivityPackDesc = class("ItemActivityPackDesc", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local nItemH = 95
--创建函数
function ItemActivityPackDesc:ctor(_data)
	-- body
	self:myInit()
	parseView("item_activity_pack_desc", handler(self, self.onParseViewCallback))

	if _data then
		self:setCurData(_data)
	end



	--注册析构方法
	self:setDestroyHandler("ItemActivityPackDesc",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActivityPackDesc:myInit()
	self.pData = {} --数据
end

--解析布局回调事件
function ItemActivityPackDesc:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	

end


-- 修改控件内容或者是刷新控件数据
function ItemActivityPackDesc:updateViews(  )

	if not self.pLbDesc then
		self.pLayDesc = self:findViewByName("ly_desc")
		local pLbDesc = self:findViewByName("lb_desc")
		self.pLbDesc = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 0),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(400, 0),
		})
		self.pLbDesc:setPosition(13, 5)
		self.pLayDesc:addView(self.pLbDesc, 10)
	end
	if self.pData and self.pData.sDesc then
		self.pLbDesc:setString(self.pData.sDesc)
		local nHeight = nItemH 
		if nItemH < self.pLbDesc:getHeight() then
			nHeight = self.pLbDesc:getHeight()
		end
		--print("nHeight--------", nHeight)
		self.pLayDesc:setContentSize(self.pLayDesc:getWidth(), nHeight + 10)
		self.pLayDesc:setBackgroundImage("#v1_img_black50.png",{scale9 = true,capInsets=cc.rect(10,10, 1, 1)})	
	end
end

--析构方法
function ItemActivityPackDesc:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActivityPackDesc:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--self.pLbN:setString(self.pData.sName or "")
	
	self:updateViews()

end


return ItemActivityPackDesc