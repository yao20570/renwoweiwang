----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-05-03 18:32:15
-- Description: 系统城主候选人界面 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemCityOwnerCandidate = class("ItemCityOwnerCandidate", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCityOwnerCandidate:ctor( )
	--解析文件
	parseView("item_city_owner_candidate", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCityOwnerCandidate:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCityOwnerCandidate",handler(self, self.onItemCityOwnerCandidateDestroy))
end

-- 析构方法
function ItemCityOwnerCandidate:onItemCityOwnerCandidateDestroy(  )
    self:onPause()
end

function ItemCityOwnerCandidate:regMsgs(  )
end

function ItemCityOwnerCandidate:unregMsgs(  )
end

function ItemCityOwnerCandidate:onResume(  )
	self:regMsgs()
end

function ItemCityOwnerCandidate:onPause(  )
	self:unregMsgs()
end

function ItemCityOwnerCandidate:setupViews(  )
	self.pTxtTitle = self:findViewByName("txt_title")

	local pLayGroupName = self:findViewByName("lay_group_name")
    local tConTable = {}
    local tLabel = {
     {"0"},
     {"0",getC3B(_cc.blue)},
    }
    tConTable.tLabel = tLabel
    self.pGroupName =  createGroupText(tConTable)
    pLayGroupName:addView(self.pGroupName)
end

function ItemCityOwnerCandidate:updateViews(  )
end

--tData:  Elector类型
function ItemCityOwnerCandidate:setData( tData)
	if not tData then
		return
	end
	self.pGroupName:setLabelCnCr(1, tData.sName) 
	self.pGroupName:setLabelCnCr(2, getLvString(tData.nLv))
	local tBanneret = getCountryBanneretByLv(tData.nTitle)
	if tBanneret then
		self.pTxtTitle:setString(tBanneret.name)
	end

	self:updateViews()
end

return ItemCityOwnerCandidate


