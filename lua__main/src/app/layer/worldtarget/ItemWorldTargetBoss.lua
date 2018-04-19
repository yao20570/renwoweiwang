----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-11 09:39:07
-- Description: 世界目标Boss
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemWorldTargetBoss = class("ItemWorldTargetBoss", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWorldTargetBoss:ctor(  )
	--解析文件
	parseView("item_world_target_boss", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWorldTargetBoss:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemWorldTargetBoss", handler(self, self.onItemWorldTargetBossDestroy))
end

-- 析构方法
function ItemWorldTargetBoss:onItemWorldTargetBossDestroy(  )
    self:onPause()
end

function ItemWorldTargetBoss:regMsgs(  )
end

function ItemWorldTargetBoss:unregMsgs(  )
end

function ItemWorldTargetBoss:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemWorldTargetBoss:onPause(  )
	self:unregMsgs()
end

function ItemWorldTargetBoss:setupViews(  )
	self.pLayContent = self:findViewByName("lay_content")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtLv = self:findViewByName("txt_lv")

	self.pImgTroops = self:findViewByName("img_troops")
	self.pTxtTroopsTitle = self:findViewByName("txt_troops_title")
	self.pTxtTroopsTitle:setString(getConvertedStr(3, 10392))
	self.pTxtTroops = self:findViewByName("txt_troops")
	self.pImgBossBg = self:findViewByName("img_boss_bg")--世界boss背景图

	self.pImgFaild = self:findViewByName("img_faild")
end

function ItemWorldTargetBoss:updateViews(  )
	if not self.tSingleBossVO then
		return
	end

	local tNpcData = getNPCData(self.tSingleBossVO.nNpcId)
	if tNpcData then
		self.pTxtName:setString(tNpcData.sName)
		self.pTxtLv:setString(getLvString(tNpcData.nLevel))
		--设置boss形象背景图片
		if tNpcData.sBossImg then
			self.pImgBossBg:setCurrentImage(tNpcData.sBossImg)
		end
		--设置boss兵种
		self.pImgTroops:setCurrentImage(getSoldierTypeImg(tNpcData.nKind))
		
		if self.tSingleBossVO:getIsKilled() then --已被杀
			self.pImgBossBg:setToGray(true)
			self.pLayContent:setToGray(true)
			self.pImgFaild:setVisible(true)
			self.pImgTroops:setVisible(false)
			self.pTxtTroopsTitle:setVisible(false)
			self.pTxtTroops:setVisible(false)
		else
			self.pImgBossBg:setToGray(false)
			self.pLayContent:setToGray(false)
			self.pImgFaild:setVisible(false)
			self.pImgTroops:setVisible(true)
			self.pTxtTroopsTitle:setVisible(true)
			self.pTxtTroops:setVisible(true)
			local nCurrTroops = self.tSingleBossVO:getCurrTroops()
			local nTroopsMax = self.tSingleBossVO:getTotalTroops()
			self.pTxtTroops:setString(string.format("%s/%s", getResourcesStr(nCurrTroops), getResourcesStr(nTroopsMax)))
		end
	end
end

--tSingleBossVO
function ItemWorldTargetBoss:setData( tSingleBossVO )
	self.tSingleBossVO = tSingleBossVO
	self:updateViews()
end

return ItemWorldTargetBoss