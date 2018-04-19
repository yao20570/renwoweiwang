----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 空的层，文字和按钮
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local NullLayerTxtAndBtn = class("NullLayerTxtAndBtn", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NullLayerTxtAndBtn:ctor(  )
	--解析文件
	parseView("lay_null_txt_and_btn", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NullLayerTxtAndBtn:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NullLayerTxtAndBtn", handler(self, self.onNullLayerTxtAndBtnDestroy))

	--请求数据 znftodo
end

-- 析构方法
function NullLayerTxtAndBtn:onNullLayerTxtAndBtnDestroy(  )
    self:onPause()
end

function NullLayerTxtAndBtn:regMsgs(  )
end

function NullLayerTxtAndBtn:unregMsgs(  )
end

function NullLayerTxtAndBtn:onResume(  )
	self:regMsgs()
end

function NullLayerTxtAndBtn:onPause(  )
	self:unregMsgs()
end

function NullLayerTxtAndBtn:setupViews(  )
	self.pTxtStr = self:findViewByName("txt_str")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE)
	setMCommonBtnScale(self.pLayBtn, self.pBtn, 0.8)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))
end

function NullLayerTxtAndBtn:updateViews(  )
	
end

function NullLayerTxtAndBtn:setStr( sStr )
	if not sStr then
		return
	end
	self.pTxtStr:setString(sStr)
end


function NullLayerTxtAndBtn:setBtnStr( sStr )
	if not sStr then
		return
	end
	self.pBtn:updateBtnText(sStr)
end

function NullLayerTxtAndBtn:setBtnHandler( nHandler )
	if not nHandler then
		return
	end
	self.nBtnHandler = nHandler
end

function NullLayerTxtAndBtn:onBtnClicked( pView )
	if self.nBtnHandler then
		self.nBtnHandler() 
	end
end


return NullLayerTxtAndBtn


