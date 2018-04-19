----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-24 11:39:27
-- Description: 城池首杀 奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local LayCityFirstBloodReward = class("LayCityFirstBloodReward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function LayCityFirstBloodReward:ctor(  )
	--解析文件
	parseView("lay_city_first_blood_reward", handler(self, self.onParseViewCallback))
end

--解析界面回调
function LayCityFirstBloodReward:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("LayCityFirstBloodReward", handler(self, self.onLayCityFirstBloodRewardDestroy))
end

-- 析构方法
function LayCityFirstBloodReward:onLayCityFirstBloodRewardDestroy(  )
    self:onPause()
end

function LayCityFirstBloodReward:regMsgs(  )
end

function LayCityFirstBloodReward:unregMsgs(  )
end

function LayCityFirstBloodReward:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function LayCityFirstBloodReward:onPause(  )
	self:unregMsgs()
end

function LayCityFirstBloodReward:setupViews(  )
	local nX, nY = 70, 20
	local nOffsetX = 86 + 65
	self.pLayIconList = {}
	for i=1,4 do
		local pLayIcon = MUI.MLayer.new()
		pLayIcon:setContentSize(86, 86)
		pLayIcon:setPosition(nX, nY)
		self:addView(pLayIcon, 1)
		nX = nX + nOffsetX
		table.insert(self.pLayIconList, pLayIcon)
	end
end

function LayCityFirstBloodReward:updateViews(  )
	if not self.nKind then
		return
	end

	local tReward = getWorldInitData("firstBlood")
	local tGoodsList = tReward[self.nKind]
	if not tGoodsList then
		return
	end
	for i=1,#self.pLayIconList do
		local pLayIcon = self.pLayIconList[i]
		local tGoods = tGoodsList[i]
		if tGoods then
			pLayIcon:setVisible(true)
			local pIcon = getIconGoodsByType(pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods, TypeIconGoodsSize.M)
			if pIcon then
				pIcon:setNumber(tGoods.nCt)
			end
		else
			pLayIcon:setVisible(false)
		end
	end
end

--nKind:城池类型
function LayCityFirstBloodReward:setData( nKind )
	self.nKind = nKind
	self:updateViews()
end

return LayCityFirstBloodReward


