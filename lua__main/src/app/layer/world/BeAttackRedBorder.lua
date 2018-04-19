----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-26 13:59:23
-- Description: 被攻击红框
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

-----透明度255-120-255，不停循环播放，2秒循环1次
local nFadeActTag = 1
local nGhostPlayTime = 0   --记录冥界的提示播放了多久 
local sGhostId = nil   --如果这个值跟现在的入侵的id一样的时候 就不再显示红框 

local BeAttackRedBorder = class("BeAttackRedBorder",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
    return pView
end)

function BeAttackRedBorder:ctor()

	--解析文件
	parseView("layout_city_be_attack", handler(self, self.onParseViewCallback))
end

--解析界面回调
function BeAttackRedBorder:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("BeAttackRedBorder",handler(self, self.onBeAttackRedBorderDestroy))
end

-- 析构方法
function BeAttackRedBorder:onBeAttackRedBorderDestroy(  )
    self:onPause()
end

function BeAttackRedBorder:regMsgs(  )
	regMsg(self, gud_world_my_city_be_attack_msg, handler(self, self.onMyCityBeAttack))

	regMsg(self, gud_world_my_city_pos_change_msg, handler(self, self.onMyCityBeAttack))
end

function BeAttackRedBorder:unregMsgs(  )
	unregMsg(self, gud_world_my_city_be_attack_msg)

	unregMsg(self, gud_world_my_city_pos_change_msg)
end

function BeAttackRedBorder:onResume(  )
	self:regMsgs()
	regUpdateControl(self, handler(self, self.updateViews))
	self:updateViews()
end

function BeAttackRedBorder:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function BeAttackRedBorder:setupViews(  )
	--是否在动作中
	self.bIsFade = false

	local pTxtTip = self:findViewByName("lay_tip")
    pTxtTip:setIgnoreOtherHeight(true)
	pTxtTip:setViewTouched(true)
	pTxtTip:setIsPressedNeedScale(false)
	pTxtTip:setIsPressedNeedColor(false)
	pTxtTip:onMViewClicked(function ( _pView )
	    if not self.tCityWarNotice and not self.tGhostWarNotices then
			return
		end
		closeAllDlg(true)
		sendMsg(ghd_home_show_base_or_world, 2)

		sendMsg(ghd_world_locaction_my_city_msg, {bIsOpenWar = true})
	end)

	self.pTxtCd = self:findViewByName("txt_cd")
end

function BeAttackRedBorder:updateViews(  )
	--找出是否有打我的消息
	self.tCityWarNotice = nil
	local bIsShortCdHitNotice = false
	local tCityWarNotices = Player:getWorldData():getCityWarNotices()
	self.tGhostWarNotices = Player:getWorldData():getGhostWarVo()
	for i=1,#tCityWarNotices do
		local tNotice = tCityWarNotices[i]
		if tNotice:getCd() > 0 and tNotice:checkTargetIsMe() then --只显示cd大于0的
			if tNotice.nType == e_type_citywar_act.hit then  --最短cd打我消息
				self.tCityWarNotice = tNotice
				bIsShortCdHitNotice = true
				break
			end
		end
	end

	if not bIsShortCdHitNotice then
		if self.tGhostWarNotices and self.tGhostWarNotices:getCd() > 0 and nGhostPlayTime <= 20 then
			nGhostPlayTime = nGhostPlayTime + 1

			if sGhostId ~= self.tGhostWarNotices.sGid then
				bIsShortCdHitNotice = true
			end
			-- sGhostId = self.tGhostWarNotices.sGid
			
		end
	end
	


	--隐藏或显示红框
	if bIsShortCdHitNotice then
		local nCd1 = 0
		local nCd2 = 0
		if self.tCityWarNotice  then
			nCd1 = self.tCityWarNotice:getCd()
		end
		if self.tGhostWarNotices  then
			nCd2 = self.tGhostWarNotices:getCd()
		end
		local tTemp = {nCd1,nCd2}
		table.sort(tTemp,function ( a,b )
			-- body
			return a>b
		end)
		local nCd = tTemp[1]
		if nCd == 0 then
			nCd = tTemp[2]
		end
		self:playFadeToAnim()

		self.pTxtCd:setString(formatTimeToMs(nCd))
		self:setVisible(true)
	else
		if self.tGhostWarNotices then
			sGhostId = self.tGhostWarNotices.sGid
		end
		nGhostPlayTime =0
		self:stopFadeReset()
		self:setVisible(false)
		unregUpdateControl(self)
	end
end

--我的城市受到攻击
function BeAttackRedBorder:onMyCityBeAttack(  )
	regUpdateControl(self, handler(self, self.updateViews))
	self:updateViews()
end

--停止刷新
function BeAttackRedBorder:stopFadeReset(  )
	if self.bIsFade == false then
		return
	end
	self:stopActionByTag(nFadeActTag)
	self:setOpacity(255)
	self.bIsFade = false
	--停止音效
	Sounds.stopEffect(Sounds.Effect.notice)
end

--播放动画
function BeAttackRedBorder:playFadeToAnim(  )
	if self.bIsFade then
		return
	end
	self:stopFadeReset()
	local pAct = cc.RepeatForever:create(cc.Sequence:create(
	cc.FadeTo:create(1,120),
	cc.FadeTo:create(1,255)))
	pAct:setTag(nFadeActTag)
	self:runAction(pAct)
	self.bIsFade = true
	--播放音效
	Sounds.playEffect(Sounds.Effect.notice)
end

return BeAttackRedBorder