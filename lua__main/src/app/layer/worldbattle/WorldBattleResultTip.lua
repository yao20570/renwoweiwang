----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-11-24 14:09:48
-- Description: 世界战斗结果提示
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MailFunc = require("app.layer.mail.MailFunc")
local WorldBattleResultTip = class("WorldBattleResultTip", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldBattleResultTip:ctor(  )
	self:myInit()
	parseView("battle_result_tip", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function WorldBattleResultTip:myInit(  )
	-- body
	self.tData = nil
	self.pIcons = {}
end

--解析界面回调
function WorldBattleResultTip:onParseViewCallback( pView )
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldBattleResultTip",handler(self, self.onWorldBattleResultTipDestroy))
end

-- 析构方法
function WorldBattleResultTip:onWorldBattleResultTipDestroy(  )
    self:onPause()
end

function WorldBattleResultTip:regMsgs(  )
end

function WorldBattleResultTip:unregMsgs(  )
end

function WorldBattleResultTip:onResume(  )
	self:regMsgs()
end

function WorldBattleResultTip:onPause(  )
	self:unregMsgs()
end

function WorldBattleResultTip:setupViews(  )
	self.pLayRoot 			= self:findViewByName("default")
	--显示物品奖励层
	self.pLayIcon 			= self:findViewByName("lay_icon")
	--img
	--城池图片层
	self.pLayTarget 		= self:findViewByName("lay_target")
	self.nTargetPosX = self.pLayTarget:getPositionX()
	--胜利失败字体图片
	self.pImgFont 			= self:findViewByName("img_font")
	
	--关闭图片
	self.pImgClose 			= self:findViewByName("img_close")
	self.pImgClose:setViewTouched(true)
	self.pImgClose:onMViewClicked(handler(self, self.onCloseClicked))

	--lb 攻打描述
	self.pLbDesc 			= self:findViewByName("lb_desc")
	

	self.pLayRoot:setViewTouched(true)
	self.pLayRoot:setIsPressedNeedScale(false)
	self.pLayRoot:setIsPressedNeedColor(false)
	self.pLayRoot:onMViewClicked(handler(self, self.onEnterMail))
	
	for i = 1, 3 do
		self.pIcons[i] = self:findViewByName("lay_icon_"..i)
	end

end

function WorldBattleResultTip:updateViews()
	-- body
	if self.tData == nil then return end
	local pImgBg, pImgFont
	if self.tData.nResult == 1 then 		-- 1胜利, 2失败
		pImgBg = "#v2_fonts_zhandshengli02.png"
		pImgFont = "#v2_fonts_zhandshengli01.png"
	else
		pImgBg = "#v2_fonts_jdsbfb02.png"
		pImgFont = "#v2_fonts_zhandsbfb01.png"
	end
	self.pLayRoot:setBackgroundImage(pImgBg)
	self.pImgFont:setCurrentImage(pImgFont)
	--奖励物品显示列表
	local tAwards = self.tData.tRandomItems
	if tAwards and table.nums(tAwards) > 0 then
		for k, v in pairs(tAwards) do
			local tItem = getGoodsByTidFromDB(v.k)
			if tItem then
				local pIcon = getIconGoodsByType(self.pIcons[k], TypeIconGoods.NORMAL, type_icongoods_show.item, tItem, 0.5)
				pIcon:setIconIsCanTouched(false)
			end
		end
	end
	local tStr = MailFunc.analysisMailMsg(self.tData, self.tMailCof.content2)
	if tStr then
		self.pLbDesc:setString(tStr)
	end

	local sImgPath = MailFunc.getMailDetailIcon(self.tData, true)
	if sImgPath then
		if not self.pTargetImg then
			self.pTargetImg = MUI.MImage.new(sImgPath)
			self.pLayTarget:addView(self.pTargetImg)
			centerInView(self.pLayTarget, self.pTargetImg)
		else
			self.pTargetImg:setCurrentImage(sImgPath)
		end
		WorldFunc.fixScaleToContent(self.pLayTarget, self.pTargetImg)
	end

	--横条UI移动进入动画
	local action = cc.Spawn:create({
		cc.FadeTo:create(0.25, 255),
		cc.MoveTo:create(0.25, cc.p(0, self:getPositionY())),
		cc.DelayTime:create(2)
	})
	self:runAction(action)

	--胜利才播放下面的特效
	if self.tData.nResult == 1 then
		self.pLayIcon:setOpacity(0)
		self.pLbDesc:setOpacity(0)
		self.pImgFont:setOpacity(0)
		--目标图片
		self.pLayTarget:setOpacity(0)
		self.pLayTarget:setPositionX(self.nTargetPosX - 168)

		--城池进入动画
		local action_1 = cc.FadeTo:create(0.30, 255)
		local action_2 = cc.MoveTo:create(0.30, cc.p(self.nTargetPosX, self.pLayTarget:getPositionY()))
		local action   = cc.Spawn:create(action_1, action_2)
		self.pLayTarget:runAction(action)

		--战斗胜利字体动画
		local pSequence = cc.Sequence:create({
			cc.DelayTime:create(0.25),
			cc.FadeTo:create(0.01, 255*0.44),
			cc.FadeTo:create(0.15, 255)
		})
		self.pImgFont:runAction(pSequence)

		--攻击忘记系统字+获得奖励图标
		local pSequence = cc.Sequence:create({
			cc.DelayTime:create(0.3),
			cc.FadeTo:create(0.25, 255)
		})
		self.pLbDesc:runAction(pSequence)
		local pSequence = cc.Sequence:create({
			cc.DelayTime:create(0.3),
			cc.FadeTo:create(0.25, 255)
		})
		self.pLayIcon:runAction(pSequence)

		--战斗胜利字体上的光晕效果
		local pImgLight = MUI.MImage.new("#sg_sjdt_zdsl_ht_gy_01.png")
		self.pLayRoot:addView(pImgLight, 10)
		pImgLight:setScale(2)
		pImgLight:setOpacity(0)
		pImgLight:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		local posX = self.pImgFont:getPositionX()
		local posY = self.pImgFont:getPositionY() + self.pImgFont:getHeight() - 9
		pImgLight:setPosition(posX, posY)
		local pSequence = cc.Sequence:create({
			cc.DelayTime:create(0.4),
			cc.FadeTo:create(0.01, 255*45),
			cc.Spawn:create({
				cc.FadeTo:create(0.1, 255),
				cc.MoveTo:create(0.1, cc.p(posX + 3, posY)),
				cc.ScaleTo:create(0.1, 2, 1.5)
			}),
			cc.Spawn:create({
				cc.FadeTo:create(0.35, 0),
				cc.MoveTo:create(0.35, cc.p(posX + 13, posY)),
				cc.ScaleTo:create(0.35, 2, 0.13)
			})
		})
		pImgLight:runAction(pSequence)

		--扫光
		local pSaoImg = MUI.MImage.new("#sg_sjdt_zdsl_ht_gy_02.png")
		if not pSaoImg then return end
		pSaoImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pSaoImg:setScale(2)
		-- pSaoImg:setOpacity(0)
		-- local pSize = self.pLayRoot:getContentSize()
		-- local pClip = display.newClippingRegionNode(cc.rect(0,0,pSize.width,pSize.height))
		self.pLayRoot:addView(pSaoImg, 999)
		
		-- local pLayTmp = MUI.MLayer.new()
		-- pLayTmp:setContentSize(pSize)
		-- pClip:addChild(pLayTmp)
		-- pLayTmp:addView(pSaoImg)
		local nPosY = self.pLayRoot:getHeight()/2
		pSaoImg:setPosition(-230, nPosY)
		local pSequence = cc.Sequence:create({
			cc.Spawn:create({
				cc.MoveTo:create(0.3, cc.p(80, nPosY)),
				cc.ScaleTo:create(0.3, 4, 2)
			}),
			cc.Spawn:create({
				cc.MoveTo:create(0.25, cc.p(334, nPosY)),
				cc.ScaleTo:create(0.25, 3, 2)
			}),
			cc.Spawn:create({
				cc.FadeTo:create(0.28, 0),
				cc.MoveTo:create(0.28, cc.p(640, nPosY)),
				cc.ScaleTo:create(0.28, 2, 2)
			})
		})
		pSaoImg:runAction(pSequence)

		
	end

	--再加一张背景图片(横条UI移动进入动画)
	local pImgSelf = MUI.MImage.new(pImgBg)
	self.pLayRoot:addView(pImgSelf)
	pImgSelf:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	pImgSelf:setPosition(-420, self.pLayRoot:getHeight()/2)
	pImgSelf:setAnchorPoint(0, 0.5)
	pImgSelf:setOpacity(0)
	local action1_1 = cc.FadeTo:create(0.25, 255*0.1)
	local action1_2 = cc.MoveTo:create(0.25, cc.p(0, self.pLayRoot:getHeight()/2))
	local action1   = cc.Spawn:create(action1_1, action1_2)
	local action2 = cc.FadeTo:create(0.37, 0)
	pImgSelf:runAction(cc.Sequence:create(action1, action2))

	doDelayForSomething(self, function( )
		local action = cc.Sequence:create({
			cc.FadeTo:create(0.2, 0),
			cc.CallFunc:create(function (  )
				self:setVisible(false)
				local tObj = {}
				tObj.sPid = self.tData.sPid
				sendMsg(ghd_refresh_battle_tip, tObj)
			end)
		})
		self:runAction(action)
		
	end, 2.45)

end

--设置数据
function WorldBattleResultTip:setData(_data, _mailCof)
	-- body
	self.tData = _data
	self.tMailCof = _mailCof
	self:updateViews()
end

function WorldBattleResultTip:getData()
	-- body
	return self.tData
end

--关闭显示
function WorldBattleResultTip:onCloseClicked()
	-- body
	local tObj = {}
	tObj.sPid = self.tData.sPid
	sendMsg(ghd_refresh_battle_tip, tObj)
end

--打开邮件
function WorldBattleResultTip:onEnterMail( _pView )
	-- body
	local tObject = {
	    nType = e_dlg_index.maildetail, --dlg类型
	    tMailMsg = self.tData,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end



return WorldBattleResultTip