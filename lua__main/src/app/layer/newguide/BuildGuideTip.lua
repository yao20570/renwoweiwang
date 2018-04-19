-- BuildGuideTip.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-08-22 13:58:23 星期二
-- Description: 建筑引导
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local BuildGuideTip = class("BuildGuideTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function BuildGuideTip:ctor(  )
	--解析文件
	parseView("lay_newguide_tip", handler(self, self.onParseViewCallback))
end

--解析界面回调
function BuildGuideTip:onParseViewCallback( pView )
	self.pView = pView
	-- self:setContentSize(display.width, display.height)
	-- self:addView(pView)
	-- centerInView(self, pView)
	-- pView:setPositionY(pView:getPositionY() - 270)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BuildGuideTip", handler(self, self.onBuildGuideTipDestroy))
end

-- 析构方法
function BuildGuideTip:onBuildGuideTipDestroy(  )
    self:onPause()
end

function BuildGuideTip:regMsgs(  )
end

function BuildGuideTip:unregMsgs(  )
end

function BuildGuideTip:onResume(  )
	self:regMsgs()
end

function BuildGuideTip:onPause(  )
	self:unregMsgs()
end

function BuildGuideTip:setupViews(  )
	--颜色层（半透明层）
	self.pLayerColor = cc.LayerColor:create(GLOBAL_DIALOG_BG_COLOR_DEFAULT, display.width, display.height)
	self.pLayerColor:setPosition(cc.p(0, 0))
	-- self:setContentSize(self.pLayerColor:getContentSize())
	self:addView(self.pLayerColor)

	--设置颜色层不可点击
	self.pLayerColor:setTouchCaptureEnabled(false)
	self.pLayerColor:setTouchEnabled(false)

	--新增内容层
	self.pLayMContent = MUI.MLayer.new()
	self.pLayMContent:setLayoutSize(self:getLayoutSize())
	self:addView(self.pLayMContent, 10)
	--把引导层加到内容层
	self.pLayMContent:addView(self.pView)
	--设置位置
	self.pView:setPositionY(display.height/5)


	
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function ( _pView )
	    self:onOutsideClicked()
	end)

	self.pTxtContent = self:findViewByName("txt_content")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.yellow)
	self.pImgArrow = self:findViewByName("img_cursor")
end

--点击任意地方
function BuildGuideTip:onOutsideClicked(  )
	-- if self.bIsCanClicked then
		self:setVisible(false)
		if self.tGuideData then
			local nNextId = self.tGuideData.nextstep
			if nNextId then
				--设置下一条事件
				showBuildGuide(nNextId)
			end
		end
	-- end
end

--强制隐藏
function BuildGuideTip:onHideMsg( )
	self:setVisible(false)
end

function BuildGuideTip:updateViews(  )
	if not self.tGuideData then
		return
	end

	--保证唯一显示
	if self.nStepId == self.nPrevStepId then
		return
	end
	self.nPrevStepId = self.nStepId
	
	--数据
	local tGuideData = self.tGuideData
	local tStr = getTextColorByConfigure(tGuideData.desc)
	self.pTxtContent:setString(tStr)

	local tChatNpcData = getGuideChatNpcData(tGuideData.chatnpc)
	if tChatNpcData then
		local sIcon = tChatNpcData.sIcon
		local sName = tChatNpcData.name
		--读主公
		if tChatNpcData.id == 6 then
			local nCountry = Player:getPlayerInfo().nInfluence
			sIcon = tChatNpcData.tIcon[nCountry] or ""
			sName = tChatNpcData.tName[nCountry] or ""
		end

		--显示npc图片
		if not self.pImgNpc then
			self.pImgNpc = MUI.MImage.new(sIcon)
			self.pImgNpc:setAnchorPoint(cc.p(0,0))
			self.pView:addView(self.pImgNpc,1)
		else
			self.pImgNpc:setCurrentImage(sIcon)
		end

		--显示名字
		self.pTxtName:setString(sName)

		--npc图片在右边
		if tGuideData.chatbox == 3 then
			self.pImgNpc:setFlippedX(true)
			self.pImgNpc:setPositionX(self.pView:getContentSize().width - self.pImgNpc:getContentSize().width)
			self.pTxtName:setPositionX(20)
			self.pTxtContent:setPositionX(20)
			self.pImgArrow:setPositionX(30)
		else
			self.pImgNpc:setFlippedX(false)
			self.pImgNpc:setPositionX(0)
			self.pTxtName:setPositionX(315)
			self.pTxtContent:setPositionX(315)
			self.pImgArrow:setPositionX(603)
		end
	end
end

--nStepId：步骤id
function BuildGuideTip:setData( nStepId ) 
	self.nStepId = nStepId
	self.tGuideData = getBuildGuideDlg(self.nStepId)
	self:updateViews()
end



return BuildGuideTip