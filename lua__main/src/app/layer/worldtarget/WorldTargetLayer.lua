----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-17 19:58:06
-- Description: 世界目标层
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local WorldTargetLayer = class("WorldTargetLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function WorldTargetLayer:ctor(  )
	-- addTextureToCache("tx/other/sg_sjdt_sjboss", 1, true)	
	parseView("layout_world_target", handler(self, self.onParseViewCallback))
end

--解析界面回调
function WorldTargetLayer:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("WorldTargetLayer", handler(self, self.onWorldTargetLayerDestroy))
end

-- 析构方法
function WorldTargetLayer:onWorldTargetLayerDestroy(  )
    self:onPause()
    -- removeTextureFromCache("tx/other/sg_sjdt_sjboss")
end

function WorldTargetLayer:regMsgs(  )
	regMsg(self, gud_my_world_target_refresh, handler(self, self.updateViews))
	regMsg(self, gud_world_target_wild_amry_kill_refresh, handler(self, self.updateWildAmryKill))
	regMsg(self, gud_world_target_top_refresh, handler(self, self.updateRedPoint))
	regMsg(self, gud_world_target_boss_refresh, handler(self, self.updateViews))
end

function WorldTargetLayer:unregMsgs(  )
	unregMsg(self, gud_my_world_target_refresh)
	unregMsg(self, gud_world_target_wild_amry_kill_refresh)
	unregMsg(self, gud_world_target_top_refresh)
	unregMsg(self, gud_world_target_boss_refresh)
end

function WorldTargetLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function WorldTargetLayer:onPause(  )
	self:unregMsgs()
end

function WorldTargetLayer:setupViews(  )
	self:setIsPressedNeedScale(false)
	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onEnterClicked))

	self.pImgIcon = self:findViewByName("img_icon")
	self.fDefIconScale = 0.8
	self.pImgIcon:setScale(self.fDefIconScale)
	self.pTxtName = self:findViewByName("txt_name")
	self.pLayArm = self:findViewByName("lay_arm")

	self.pLayRed = self:findViewByName("lay_red")
end

function WorldTargetLayer:updateViews(  )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end

	--更新底部居中文字
	self:updateBottomTxt()

	--更新红点
	self:updateRedPoint()
end

--更新底部居中文字
function WorldTargetLayer:updateBottomTxt(  )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end
	
	self.pImgIcon:setCurrentImage(tWorldTargetData.sIcon)

	local sDesc = tWorldTargetData.desc
	-- if tWorldTargetData.nTargetType == e_type_world_target.wildArmy then
	-- 	local nCurrKill = Player:getWorldData():getWildArmyKill()
	-- 	local nNeedKill = tWorldTargetData.nTargetValue
	-- 	sDesc = sDesc.. string.format("(%s/%s)", nCurrKill, nNeedKill)
	-- end
	self.pTxtName:setString(sDesc)
end

--红点刷新 
function WorldTargetLayer:updateRedPoint( )
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if not nMyTargetId then
		return
	end

	local tWorldTargetData = getWorldTargetData(nMyTargetId)
	if not tWorldTargetData then
		return
	end
	
	local bIsShow = false
	local nRedNum = 0
	local bIsUnLock = getIsReachOpenCon(8, false)
	if bIsUnLock then
		if tWorldTargetData.nTargetType == e_type_world_target.wildArmy then
			bIsShow = Player:getWorldData():getIsCanGetWTWildArmyReward()

			local nCurrKill = Player:getWorldData():getWildArmyKill()
			local nNeedKill = tWorldTargetData.nTargetValue
			nRedNum = math.max(nNeedKill - nCurrKill, 0)
		elseif tWorldTargetData.nTargetType == e_type_world_target.sysCity then
			bIsShow = Player:getWorldData():getIsCanGetWTSysCityReward()
		elseif tWorldTargetData.nTargetType == e_type_world_target.worldBoss then
			bIsShow = not Player:getWorldData():getIsAttackedBoss()
		elseif tWorldTargetData.nTargetType == e_type_world_target.capital then
			bIsShow = Player:getWorldData():getIsCanGetWTCapitalReward()
		end
	end

	showRedTips(self.pLayRed, 1, nRedNum)

	if bIsShow then
		self:stopNoRewardEffect()
		self:playRewardEffect()
	else
		self:stopRewardEffect()
		self:playNoRewardEffect()
	end
end

--播放可以奖励的特效
function WorldTargetLayer:playRewardEffect( )
	--位置
	local nX, nY = 0, 0--self.pImgIcon:getPosition()
	--层次
	local nZorder = 1

	--旋转光（自循环）
	if not self.pRotateArm then
		
		local tArmData = {
            sPlist = "tx/other/sg_sjdt_sjboss",
            nImgType = 1,
			nFrame = 12, -- 总帧数
			pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
			fScale = 1.25,-- 初始的缩放值
			nBlend = 1, -- 需要加亮
		   	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
			tActions = {
				 {
					nType = 1, -- 序列帧播放
					sImgName = "sg_sjdt_sjboss_",
					nSFrame = 1, -- 开始帧下标
					nEFrame = 12, -- 结束帧下标
					tValues = nil, -- 参数列表
				},
			},
		}

		local pArmAction = MArmatureUtils:createMArmature(
		tArmData, 
		self.pLayArm, 
		nZorder, 
		cc.p(nX, nY),
	    nil, Scene_arm_type.normal)
		pArmAction:play(-1)
		self.pRotateArm = pArmAction
	else
		self.pRotateArm:setVisible(true)
		self.pRotateArm:play(-1)
	end

	--图片呼吸效果（自循环）
	local nMyTargetId = Player:getWorldData():getMyWorldTargetId()
	if nMyTargetId then
		local tWorldTargetData = getWorldTargetData(nMyTargetId)
		if tWorldTargetData then
			local tArmData  =  {
				nFrame = 24, -- 总帧数
				pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
				fScale = 1,-- 初始的缩放值
				nBlend = 1, -- 需要加亮
			  	nPerFrameTime = 1/18, -- 每帧播放时间（18帧每秒）
				tActions = {
					{
						nType = 2, -- 透明度
						sImgName = tWorldTargetData.icon,--"替换世界BOSS图标的图片例如文件中的“v1_btn_uddo”",
						nSFrame = 1,
						nEFrame = 12,
						tValues = {-- 参数列表
							{0, 80}, -- 开始, 结束透明度值
						}, 
					},
					{
						nType = 2, -- 透明度
						sImgName = tWorldTargetData.icon,--"替换世界BOSS图标的图片例如文件中的“v1_btn_uddo”",
						nSFrame = 13,
						nEFrame = 24,
						tValues = {-- 参数列表
							{80, 0}, -- 开始, 结束透明度值
						}, 
					},
				},
			}
			if not self.pBreahthArm then
				local pArmAction = MArmatureUtils:createMArmature(
				tArmData, 
				self.pLayArm, 
				nZorder, 
				cc.p(nX, nY),
			    nil, Scene_arm_type.normal)
				pArmAction:play(-1)
				self.pBreahthArm = pArmAction
			else
				self.pBreahthArm:setVisible(true)
				self.pBreahthArm:play(-1)
			end
		end
	end
end

--停止可以奖励特效
function WorldTargetLayer:stopRewardEffect( )
	if self.pRotateArm then
		self.pRotateArm:setVisible(false)
		self.pRotateArm:stop()
	end
	if self.pBreahthArm then
		self.pBreahthArm:setVisible(false)
		self.pBreahthArm:stop()
	end
end

--播放没有奖励特效
function WorldTargetLayer:playNoRewardEffect( )
	if self.bIsNoRewardEffect then
		return
	end
	--时间      缩放值
	-- 0秒         93%
	-- 0.7秒       100%
	-- 1.4秒       93%
	-- local pSeqAct = cc.Sequence:create({
	-- 	cc.ScaleTo:create(0, 0.93),
	-- 	cc.ScaleTo:create(0.7, 1),
	-- 	cc.ScaleTo:create(1.4 - 0.7, 0.93),
	-- })
	-- self.pImgIcon:runAction(cc.RepeatForever:create(pSeqAct))

	--粒子
	if self.pNoRewardParitcle then
		self.pNoRewardParitcle:setVisible(true)
	else
		local pNoRewardParitcle =  createParitcle("tx/other/lizi_remw_003.plist")
		self.pImgIcon:getParent():addView(pNoRewardParitcle, 3)
		local nX, nY = self.pImgIcon:getPosition()
		pNoRewardParitcle:setPosition(nX, nY)
		self.pNoRewardParitcle = pNoRewardParitcle
	end

	self.bIsNoRewardEffect = true
end

--停止没有奖励特效
function WorldTargetLayer:stopNoRewardEffect( )
	if self.bIsNoRewardEffect then
		self.pImgIcon:stopAllActions()
		self.pImgIcon:setScale(self.fDefIconScale)

		if self.pNoRewardParitcle then
			self.pNoRewardParitcle:setVisible(false)
		end

		self.bIsNoRewardEffect = false
	end
end

--乱军杀数量更新
function WorldTargetLayer:updateWildAmryKill( )
	self:updateBottomTxt()
	self:updateRedPoint()
end

--进入
function WorldTargetLayer:onEnterClicked( pView )
	local tObject = {
    	nType = e_dlg_index.worldtarget, --dlg类型
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

return WorldTargetLayer


