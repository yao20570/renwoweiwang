------------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-6 11:40:0
-- Description: 有限Boss 次数榜单
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local TLBossHitNumSRank = class("TLBossHitNumSRank", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function TLBossHitNumSRank:ctor(  )
	--解析文件
	parseView("layout_tlboss_rank_small", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossHitNumSRank:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("TLBossHitNumSRank", handler(self, self.onTLBossHitNumSRankDestroy))
end

-- 析构方法
function TLBossHitNumSRank:onTLBossHitNumSRankDestroy(  )
    self:onPause()
end

function TLBossHitNumSRank:regMsgs(  )
	regMsg(self, gud_tlboss_data_refresh, handler(self, self.updateViews))
end

function TLBossHitNumSRank:unregMsgs(  )
	unregMsg(self, gud_tlboss_data_refresh)
end

function TLBossHitNumSRank:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TLBossHitNumSRank:onPause(  )
	self:unregMsgs()
end

function TLBossHitNumSRank:setupViews(  )
	local pImgTitle = self:findViewByName("img_title")
	local pLayRank = self:findViewByName("lay_rank") 
	pImgTitle:setCurrentImage("#v2_fonts_cishupaihang.png")
	pImgTitle:setPosition(pImgTitle:getPositionX(), pImgTitle:getPositionY() + 20)

	--生成文本
	self.tTextList = {}
	local pSize = pLayRank:getContentSize()
	local nWidth, nHeight = pSize.width, pSize.height - 5
	local nY = nHeight
	local nOffsetY = nHeight/11
	local nBeginX, nEndX = -15, nWidth+13
	self.pTextMyInfo = nil
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

	        local pTxtHitNum = MUI.MLabel.new({
	            text = "",
	            size = 16,
	            anchorpoint = cc.p(1, 0.5),})
	        pTxtHitNum:setPosition(nEndX, nY - nOffsetY/2)
	        pLayRank:addView(pTxtHitNum)

	       	table.insert(self.tTextList, {pTxtName = pTxtName, pTxtHitNum = pTxtHitNum})
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

function TLBossHitNumSRank:updateViews(  )
	local tHarmRankList = Player:getTLBossData():getHitNumRankList()
	for i=1,#self.tTextList do
		local pTxtName = self.tTextList[i].pTxtName
		local pTxtHitNum = self.tTextList[i].pTxtHitNum
		local tBossRankVo = tHarmRankList[i]
		if tBossRankVo then
			pTxtName:setVisible(true)
			pTxtHitNum:setVisible(true)
			if tBossRankVo:getPlayerId() == Player:getPlayerInfo().pid then
				setTextCCColor(pTxtName, _cc.yellow)
				setTextCCColor(pTxtHitNum, _cc.yellow)
			else
				setTextCCColor(pTxtName, _cc.white)
				setTextCCColor(pTxtHitNum, _cc.white)
			end
			pTxtName:setString(tostring(i).."."..tBossRankVo:getName())
			pTxtHitNum:setString(getResourcesStr(tBossRankVo:getHitNum()))
		else
			pTxtName:setVisible(false)
			pTxtHitNum:setVisible(false)
		end
	end

	local nHitNum = Player:getTLBossData():getMyHitNum()
	self.pTextMyInfo:setString(getConvertedStr(3, 10819) .. getResourcesStr(nHitNum))
end

return TLBossHitNumSRank


