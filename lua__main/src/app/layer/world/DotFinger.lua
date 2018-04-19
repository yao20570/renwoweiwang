----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-10 16:15:32
-- Description: 视图点头顶上的手指头，点击或移动就消失
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DotFinger = class("DotFinger", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--图片样式
local e_img_type = 
{
	finger = 1,   -- 手指
	arrow  = 2    -- 箭头
}

function DotFinger:ctor(nType)
	self.nImgType = nType or e_img_type.arrow -- 默认显示箭头
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DotFinger",handler(self, self.onDotFingerDestroy))
end

-- 析构方法
function DotFinger:onDotFingerDestroy(  )
    self:onPause()
end

function DotFinger:regMsgs(  )
end

function DotFinger:unregMsgs(  )
end

function DotFinger:onResume(  )
	self:regMsgs()
end

function DotFinger:onPause(  )
	self:unregMsgs()
end

function DotFinger:setupViews(  )
	if self.nImgType == e_img_type.finger then
		self.pImgFinger = MUI.MImage.new("#v1_img_shouzhi.png")
	else
		self.pImgFinger = MUI.MImage.new("#v1_img_zhiyin_sj.png")
	end
    self:addView(self.pImgFinger)
    self:setContentSize(self.pImgFinger:getContentSize())

    local pAct1 = cc.MoveBy:create(0.3, cc.p(0,20))
    local pAct2 = pAct1:reverse()
    self.pImgFinger:runAction(cc.RepeatForever:create(cc.Sequence:create(pAct1, pAct2)))
end

function DotFinger:updateViews(  )
	if not self.pDotUi then
		return
	end

	--手指头
	local pFingerUiPoint = self.pDotUi:getAnchorPointInPoints()
	local pWorldPoint = self.pDotUi:convertToWorldSpace(pFingerUiPoint);
	local pCurrPoint = self:convertToNodeSpace(pWorldPoint)

	local nOffestX, nOffestY = 0, 40
	--如果是手指
	if self.nImgType == e_img_type.finger then
		nOffestX, nOffestY = 30, 80
	end
	pCurrPoint.x = pCurrPoint.x + nOffestX
	pCurrPoint.y = pCurrPoint.y + nOffestY
	self.pImgFinger:setPosition(pCurrPoint)
end

--pDotUi
function DotFinger:setData( pDotUi )
	self.pDotUi = pDotUi
	self:updateViews()
end

return DotFinger