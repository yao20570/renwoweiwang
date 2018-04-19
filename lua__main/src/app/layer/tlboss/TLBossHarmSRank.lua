------------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-6 11:40:0
-- Description: 有限Boss 伤害榜单
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local TLBossHarmSRank = class("TLBossHarmSRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TLBossHarmSRank:ctor(  )
	--解析文件
	parseView("layout_tlboss_rank_small", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossHarmSRank:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TLBossHarmSRank", handler(self, self.onTLBossHarmSRankDestroy))
end

-- 析构方法
function TLBossHarmSRank:onTLBossHarmSRankDestroy(  )
    self:onPause()
end

function TLBossHarmSRank:regMsgs(  )
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.updateViews))
end

function TLBossHarmSRank:unregMsgs(  )
	unregMsg(self, gud_tlboss_data_refresh)
end

function TLBossHarmSRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TLBossHarmSRank:onPause(  )
	self:unregMsgs()
end

function TLBossHarmSRank:setupViews(  )
	local pLayRank = self:findViewByName("lay_rank") 
	local pImgTitle = self:findViewByName("img_title")
	pImgTitle:setPosition(pImgTitle:getPositionX(), pImgTitle:getPositionY() + 20)

	--生成文本
	self.tTextList = {}
	local pSize = pLayRank:getContentSize()
	local nWidth, nHeight = pSize.width, pSize.height - 5
	local nY = nHeight
	local nOffsetY = nHeight/11
	self.pTextMyInfo = nil
	local nBeginX, nEndX = -15, nWidth+13
	for i=1,11 do
		if i == 11 then
			self.pTextMyInfo = MUI.MLabel.new({
	            text = "",
	            size = 16,
	            anchorpoint = cc.p(0.5, 0.5),})
	        self.pTextMyInfo:setPosition(nWidth/2, nY - nOffsetY/2)
	        setTextCCColor(self.pTextMyInfo, _cc.green)
	        pLayRank:addView(self.pTextMyInfo)
		else
			local pTxtName = MUI.MLabel.new({
	            text = "",
	            size = 16,
	            anchorpoint = cc.p(0, 0.5),})
	        pTxtName:setPosition(nBeginX, nY - nOffsetY/2)
	        pLayRank:addView(pTxtName)

	        local pTxtHarm = MUI.MLabel.new({
	            text = "",
	            size = 16,
	            anchorpoint = cc.p(1, 0.5),})
	        pTxtHarm:setPosition(nEndX, nY - nOffsetY/2)
	        pLayRank:addView(pTxtHarm)

	       	table.insert(self.tTextList, {pTxtName = pTxtName, pTxtHarm = pTxtHarm})
	        nY = nY - nOffsetY
	    end
	end

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function ( _pView )
		sendMsg(ghd_show_tlboss_small_rank, false)
	end)
end

function TLBossHarmSRank:updateViews(  )
	local tHarmRankList = Player:getTLBossData():getHarmRankList()
	for i=1,#self.tTextList do
		local pTxtName = self.tTextList[i].pTxtName
		local pTxtHarm = self.tTextList[i].pTxtHarm
		local tBossRankVo = tHarmRankList[i]
		if tBossRankVo then
			pTxtName:setVisible(true)
			pTxtHarm:setVisible(true)
			if tBossRankVo:getPlayerId() == Player:getPlayerInfo().pid then
				setTextCCColor(pTxtName, _cc.yellow)
				setTextCCColor(pTxtHarm, _cc.yellow)
			else
				setTextCCColor(pTxtName, _cc.white)
				setTextCCColor(pTxtHarm, _cc.white)
			end
			pTxtName:setString(tostring(i).."."..tBossRankVo:getName())
			pTxtHarm:setString(getResourcesStr(tBossRankVo:getHarm()))
		else
			pTxtName:setVisible(false)
			pTxtHarm:setVisible(false)
		end
	end

	local nMyHarm = Player:getTLBossData():getMyHarm()
	self.pTextMyInfo:setString(getConvertedStr(3, 10718) .. getResourcesStr(nMyHarm))
end

return TLBossHarmSRank


