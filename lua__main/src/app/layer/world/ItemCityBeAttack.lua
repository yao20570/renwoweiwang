----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-16 21:02:35
-- Description: 被打通知条
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemCityBeAttack = class("ItemCityBeAttack", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCityBeAttack:ctor(  )
	--解析文件
	parseView("item_city_war_notice", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCityBeAttack:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemCityBeAttack",handler(self, self.onItemCityBeAttackDestroy))
end

-- 析构方法
function ItemCityBeAttack:onItemCityBeAttackDestroy(  )
    self:onPause()
end

function ItemCityBeAttack:regMsgs(  )
end

function ItemCityBeAttack:unregMsgs(  )
end

function ItemCityBeAttack:onResume(  )
	self:regMsgs()
end

function ItemCityBeAttack:onPause(  )
	self:unregMsgs()
end

function ItemCityBeAttack:setupViews(  )
	local pLayView = self:findViewByName("view")
	pLayView:setViewTouched(true)
	pLayView:setIsPressedNeedScale(false)
	pLayView:onMViewClicked(handler(self, self.onClickedView))

	self.pTxtTip = self:findViewByName("txt_tip")

	self.pImgWarning = self:findViewByName("img_warning")
end

function ItemCityBeAttack:updateViews(  )
	if not self.tData then
		return
	end

	--减少重复刷新
	if self.nPrevType ~= self.tData.nType then
		self.nPrevType = self.tData.nType
		--设置颜色
		if self.tData.nType == e_type_citywar_act.hit then
			setTextCCColor(self.pTxtTip, _cc.red)
			self.pImgWarning:setCurrentImage("#v1_img_hongsetishi.png")
		else
			setTextCCColor(self.pTxtTip, _cc.yellow)
			self.pImgWarning:setCurrentImage("#v1_img_huangsetishi.png")
		end
	end
	
	--更新cd时间文本
	local sStr = nil
	if self.tData.nType == e_type_citywar_act.hit then
		sStr = getConvertedStr(3, 10205)
	else
		sStr = getConvertedStr(3, 10206)
	end
	local sStr2 = string.format(sStr, self.tData.sName, getWorldPosString(self.tData.nX, self.tData.nY),formatTimeToHms(self.tData:getCd()))
	self.pTxtTip:setString(sStr2, false)
end

--tData:tCityWarNotice
function ItemCityBeAttack:setData( tData )
	self.tData = tData
	self:updateViews()
end

function ItemCityBeAttack:onClickedView(  )
	if not self.tData then
		return
	end

	sendMsg(ghd_world_location_dotpos_msg, {nX = self.tData.nX, nY = self.tData.nY})
end

return ItemCityBeAttack


