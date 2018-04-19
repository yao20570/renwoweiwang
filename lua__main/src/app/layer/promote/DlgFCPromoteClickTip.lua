----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-05 14:54:38
-- Description: 战力提升背景 点击
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local DlgFCPromoteClickTip = class("DlgFCPromoteClickTip", function()
	-- body
	return MDialog.new(e_dlg_index.fcpromoteclicktip)
end)

--nCombatUpId:战力提升途径表id
function DlgFCPromoteClickTip:ctor( nCombatUpId )
	self.nCombatUpId = nCombatUpId
	parseView("dlg_fc_promote_click_tip", handler(self, self.onParseViewCallback))
end

--解析布局回调事件
function DlgFCPromoteClickTip:onParseViewCallback( pView )
	-- body
	self:setContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgFCPromoteClickTip",handler(self, self.onDlgDlgFCPromoteClickTipDestroy))
end

--初始化控件
function DlgFCPromoteClickTip:setupViews(  )
	self.pLbTip = self:findViewByName("txt_tip")
	self.pLayBg = self:findViewByName("lay_bg")
	self.nOriginBgWidth = self.pLayBg:getContentSize().width
	self.nOriginBgHeight = self.pLayBg:getContentSize().height
	self.nOriginBgPosY = self.pLayBg:getPositionY()

	-- self.pLbTip = MUI.MLabel.new({
	-- 		text = "",
	-- 		size = 20,
	-- 		anchorPoint = cc.p(0.5, 0.5),
	-- 		align = cc.ui.TEXT_ALIGN_CENTER,
	-- 		valign = cc.ui.TEXT_VALIGN_TOP,
	-- 		color = cc.c3b(255,255,255),
	-- 		dimensions = cc.size(500, 0),
	-- 	})
	-- self:addView(self.pLbTip, 10)
	-- self.pLbTip:setPosition(self:getContentSize().width/2, self:getContentSize().height/2)
end

--控件刷新
function DlgFCPromoteClickTip:updateViews(  )
	if not self.nCombatUpId then
		return
	end

	local tCombatUpData = getCombatUpData(self.nCombatUpId)
	if not tCombatUpData then
		return
	end

	local sStr = tCombatUpData.clicktips
	self.pLbTip:setString(sStr, false)

	local nHeight = math.max(self.nOriginBgHeight, self.pLbTip:getHeight() + 40)
	self.pLayBg:setLayoutSize(self.nOriginBgWidth, nHeight)
	if nHeight > self.nOriginBgHeight then
		local nY = self.nOriginBgPosY - (nHeight - self.nOriginBgHeight)/2
		self.pLayBg:setPositionY(nY)
	else
		self.pLayBg:setPositionY(self.nOriginBgPosY)
	end
end

--析构方法
function DlgFCPromoteClickTip:onDlgDlgFCPromoteClickTipDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgFCPromoteClickTip:regMsgs(  )
	-- body

end
--注销消息
function DlgFCPromoteClickTip:unregMsgs(  )
	-- body

end

--暂停方法
function DlgFCPromoteClickTip:onPause( )
	-- body
	self:unregMsgs()	
end

--继续方法
function DlgFCPromoteClickTip:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end

return DlgFCPromoteClickTip