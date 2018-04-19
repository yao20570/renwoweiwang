----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-28 13:52:42
-- Description: 新手引导层 全屏提示界面
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MRichLabel = require("app.common.richview.MRichLabel")
local NewGuideDrama = class("NewGuideDrama", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NewGuideDrama:ctor( )
	--解析文件
	parseView("dlg_newguide_drama", handler(self, self.onParseViewCallback))
end

--解析界面回调
function NewGuideDrama:onParseViewCallback( pView )
	--颜色层（半透明层）
	self.pLayerColor = cc.LayerColor:create(GLOBAL_DIALOG_BG_COLOR_DEFAULT, display.width, display.height)
	self.pLayerColor:setPosition(cc.p(0, 0))
	self:addView(self.pLayerColor)

	self.pView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView,1)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("NewGuideDrama", handler(self, self.onNewGuideDramaDestroy))
end

-- 析构方法
function NewGuideDrama:onNewGuideDramaDestroy(  )
    self:onPause()
end

function NewGuideDrama:regMsgs(  )
	regMsg(self, ghd_guide_drama_or_tip_hide, handler(self, self.onHideMsg))
end

function NewGuideDrama:unregMsgs(  )
	unregMsg(self, ghd_guide_drama_or_tip_hide)
end

function NewGuideDrama:onResume(  )
	self:regMsgs()
end

function NewGuideDrama:onPause(  )
	self:unregMsgs()
end

function NewGuideDrama:setupViews(  )
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(function ( _pView )
	    self:onOutsideClicked()
	end)
	self.pTxtContent = self:findViewByName("txt_content")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.yellow)
end

--点击任意地方
function NewGuideDrama:onOutsideClicked(  )
	if B_GUIDE_LOG then
		myprint("B_GUIDE_LOG NewGuideDrama:onOutsideClicked")
	end
	if self.bIsCanClicked then
		self:setVisible(false)
		if self.tGuideData then
			--设置下一条事件
			Player:getNewGuideMgr():jumpToDlg(self.tGuideData.step)
			--触发完成点击跳转转个界面
			Player:getNewGuideMgr():setCurrStepId(self.tGuideData.nextstep)
		end
		if B_GUIDE_LOG then
			myprint("B_GUIDE_LOG 释放全屏控制权")
		end
		--显示下一个
		showNextSequenceFunc(e_show_seq.newguidedrama)
	end
end

--强制隐藏
function NewGuideDrama:onHideMsg( )
	self:setVisible(false)
	--显示下一个
	showNextSequenceFunc(e_show_seq.newguidedrama)
end


function NewGuideDrama:updateViews(  )
	if not self.tGuideData then
		return
	end

	--保证唯一显示
	if self.nPrevStepId == self.nStepId then
		return
	end
	self.nPrevStepId = self.nStepId

	if B_GUIDE_LOG then
		print("B_GUIDE_LOG NewGuideDrama ===================",self.nStepId)
	end

	--数据
	local tGuideData = self.tGuideData

	local tStr = getTextColorByConfigure(tGuideData.desc)
	self.pTxtContent:setString(tStr)

	local tChatNpcData = getGuideChatNpcData(tGuideData.chatnpc)
	if tChatNpcData then
		--显示npc图片
		if not self.pImgNpc then
			self.pImgNpc = MUI.MImage.new(tChatNpcData.sIcon)
			self.pImgNpc:setAnchorPoint(cc.p(0.5,0))
			self.pImgNpc:setPosition(640/2, 260)
			self.pView:addView(self.pImgNpc, -1)
		else
			self.pImgNpc:setCurrentImage(tChatNpcData.sIcon)
		end

		--显示名字
		self.pTxtName:setString(tChatNpcData.name)
	end

	--延迟出现
	self.bIsCanClicked = true
	if self.tGuideData.windelayed then
		local tData = luaSplit(self.tGuideData.windelayed, ":")
		local nType = tonumber(tData[1])
		local nDelayTime = tonumber(tData[2])
		if nType == 2 and nDelayTime then
			--一段时间显示
			self.bIsCanClicked = false
			self.pView:setVisible(false)
			self.pView:stopAllActions()
			local function func(  )
				self.bIsCanClicked = true
				self.pView:setVisible(true)
				ActionIn(self.pView, "pop", 0.15)
			end
			doDelayForSomething(self.pView, func, nDelayTime/1000)
		end
	else
		self.pView:setVisible(true)
	end
end

--nStepId：步骤id
--nGuideType: 1:美女引导教你玩
function NewGuideDrama:setData( nStepId, nGuideType )
	self.nStepId = nStepId
	if nGuideType == 1 then
		self.tGuideData = getTeachPlayStep(self.nStepId)
	else
		self.tGuideData = getGuideData(self.nStepId) 
	end
	self:updateViews()
end

return NewGuideDrama


