----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-17 19:59:21
-- Description: 空的层，图片和文字
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local NullLayerImgAndTxt = class("NullLayerImgAndTxt", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NullLayerImgAndTxt:ctor(  )
	--解析文件
	parseView("lay_null_img_and_txt", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NullLayerImgAndTxt:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NullLayerImgAndTxt", handler(self, self.onNullLayerImgAndTxtDestroy))
end

-- 析构方法
function NullLayerImgAndTxt:onNullLayerImgAndTxtDestroy(  )
    self:onPause()
end

function NullLayerImgAndTxt:regMsgs(  )
end

function NullLayerImgAndTxt:unregMsgs(  )
end

function NullLayerImgAndTxt:onResume(  )
	self:regMsgs()
end

function NullLayerImgAndTxt:onPause(  )
	self:unregMsgs()
end

function NullLayerImgAndTxt:setupViews(  )
	self.pTxtStr = self:findViewByName("txt_str")
	self.pImgIcon = self:findViewByName("img_icon")
end

function NullLayerImgAndTxt:updateViews(  )
	
end

function NullLayerImgAndTxt:setStr( sStr )
	if not sStr then
		return
	end
	self.pTxtStr:setString(sStr)
end

return NullLayerImgAndTxt


