----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-05 14:49:43
-- Description: 转盘
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local SnatchturnLayer = class("SnatchturnLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function SnatchturnLayer:ctor(  )
	self.pParitcles = {}
	self.tGoodsList = {}
	self.tGoodsCnt = {}
	--解析文件
	parseView("layout_turntable", handler(self, self.onParseViewCallback))
end

--解析界面回调
function SnatchturnLayer:onParseViewCallback( pView )
	self.pCCSView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("SnatchturnLayer", handler(self, self.onSnatchturnLayerDestroy))
end

-- 析构方法
function SnatchturnLayer:onSnatchturnLayerDestroy(  )
    self:onPause()
    self:stopCircleAnim()
end

function SnatchturnLayer:regMsgs(  )
end

function SnatchturnLayer:unregMsgs(  )
end

function SnatchturnLayer:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function SnatchturnLayer:onPause(  )
	self:unregMsgs()
end

function SnatchturnLayer:setupViews(  )
	self.pLayGoodsList = {}
	for i=1,8 do
		table.insert(self.pLayGoodsList, self:findViewByName("lay_goods"..i))
	end
	self.nGoodsMax = #self.pLayGoodsList

	self.pTxtCenter1 = self:findViewByName("txt_center1")
	self.pTxtCenter2 = self:findViewByName("txt_center2")
	self.pTxtCenter3 = self:findViewByName("txt_center3")
	self.pTxtCenter4 = self:findViewByName("txt_center4")
	self.pLayCenterTxt = self:findViewByName("lay_center_text")

	self.pLayCenterGoods = self:findViewByName("lay_center_goods")

	--层1
	local pParitcle =  createParitcle("tx/other/lizi_haotieyl_d_002.plist")
   	self.pCCSView:addView(pParitcle, 1)
   	centerInView(self.pCCSView, pParitcle)
   	self.pBlueParitcle1 = pParitcle

   	--层2
   	local pImgBg2 =  MUI.MImage.new("ui/sg_gzbg_bgg_01.png")
	self.pCCSView:addView(pImgBg2, 2)
	centerInView(self.pCCSView, pImgBg2)

	--层3
	local pParitcle2 =  createParitcle("tx/other/lizi_haotieyl_d_002.plist")
	pParitcle2:setScale(0.45)
   	self.pCCSView:addView(pParitcle2, 3)
   	centerInView(self.pCCSView, pParitcle2)
   	self.pBlueParitcle2 = pParitcle2

   	--层4
   	local pLayCirclLight = MUI.MLayer.new()
   	pLayCirclLight:setLayoutSize(100, 100)
   	self.pCCSView:addView(pLayCirclLight, 4)
   	centerInView(self.pCCSView, pLayCirclLight)
  	self.pLayCirclLight = pLayCirclLight
   	--层4
   	local tArmData1  = 
	{
		nFrame = 36, -- 总帧数
		pos = {0, 0}, -- 特效的x,y轴位置（相对中心锚点的偏移）
		fScale = 1.15,-- 初始的缩放值
		nBlend = 1, -- 需要加亮
	    nPerFrameTime = 1/30, -- 每帧播放时间（30帧每秒）
		tActions = {
				{
					nType = 2, -- 透明度
					sImgName = "sg_gzbg_bgg_0002",
					nSFrame = 1,
					nEFrame = 18,
					tValues = {-- 参数列表
						{25, 255}, -- 开始, 结束透明度值
					},
				},
				{
					nType = 2, -- 透明度
					sImgName = "sg_gzbg_bgg_0002",
					nSFrame = 19,
					nEFrame = 36,
					tValues = {-- 参数列表
						{255, 25}, -- 开始, 结束透明度值
					},
				},
		}
	}
	local pCirclLightArm = MArmatureUtils:createMArmature(
		tArmData1, 
		pLayCirclLight, 
		0, 
		cc.p(50, 50),
	    function ( _pArm )
	    end, Scene_arm_type.normal)
	if pCirclLightArm then
		pCirclLightArm:play(-1)
	end
   	

	--发亮的边框
	self.pImgBorder =  MUI.MImage.new("#v1_img_truqrjfi.png")
	self.pCCSView:addView(self.pImgBorder, 10)
	self.pImgBorder:setVisible(false)
	self.pImgBorder:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

	--默认显示
	self.pBlueParitcle1:setVisible(false)
	self.pBlueParitcle2:setVisible(false)
	self.pLayCirclLight:setVisible(false)
end

function SnatchturnLayer:updateViews(  )
	
end

function SnatchturnLayer:setGoodsData( nIndex, nGoodsId, nNum )
	local pLayGoods = self.pLayGoodsList[nIndex]
	if pLayGoods then
		local tGoods = getGoodsByTidFromDB(nGoodsId)
		if tGoods then
			local pIcon = getIconGoodsByType(pLayGoods, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods, TypeIconGoodsSize.M)
			if pIcon then
				pIcon:setNumber(nNum)
				if tGoods.nQuality == 5 then  --橙色特殊处理
					
					setBgQuality(pIcon.pLayBgQuality,tGoods.nQuality,false)
				end
			end

			self.tGoodsList[nIndex] = tGoods
			self.tGoodsCnt[nIndex] = nNum
		end
	end
end

function SnatchturnLayer:setGoodsLight( nIndex, bIsLight )
	if bIsLight then
		local pLayGoods = self.pLayGoodsList[nIndex]
		if pLayGoods then
			local pIconGoods = pLayGoods:findViewByName("p_icon_goods_name")
			if pIconGoods then
				pIconGoods:setTurntableSelectedImg(true)
			end
		end
	else
		local pLayGoods = self.pLayGoodsList[nIndex]
		if pLayGoods then
			local pIconGoods = pLayGoods:findViewByName("p_icon_goods_name")
			if pIconGoods then
				pIconGoods:setTurntableSelectedImg(false)
			end
		end
	end
end

function SnatchturnLayer:setCenterTxt( tStr )
	self.pTxtCenter1:setString(tStr[1] or "")
	self.pTxtCenter2:setString(tStr[2] or "")
	self.pTxtCenter3:setString(tStr[3] or "")
	self.pTxtCenter4:setString(tStr[4] or "")
end

--播放圆形动画
function SnatchturnLayer:playCircleAnim( nTargetIndex, nFunc, nUnableTouchFunc )
	--开屏蔽
	if not self.bIsOpenUnableTouch then
		self.bIsOpenUnableTouch = true
		showUnableTouchDlg(nUnableTouchFunc)
	end
	

	self.nOverCallBackFunc = nFunc
	--设置隐藏
	self.pLayCenterTxt:setVisible(false)
	self.pLayCenterGoods:setVisible(true)
	self.pBlueParitcle1:setVisible(true)
	self.pBlueParitcle2:setVisible(true)
	self.pLayCirclLight:setVisible(true)

	-- self.nBeginTime = getSystemTime()
	--当前显示的下标
	self.nLightIndex = 0
	self.nEndLightIndex = nTargetIndex + self.nGoodsMax * 3
	self:runAct(0)
end

function SnatchturnLayer:runAct( nT )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	--自增1
	self.nLightIndex = self.nLightIndex + 1
	if self.nLightIndex <= self.nEndLightIndex then
		--显示特效
		local nGoodsIndex = self.nLightIndex%self.nGoodsMax
		if self.nLightIndex % self.nGoodsMax == 0 then
			nGoodsIndex = self.nGoodsMax
		end
		local bIsPlayParticle = self.nLightIndex <= self.nGoodsMax
		self:showChangeEffect(nGoodsIndex, bIsPlayParticle)
	end

	--给多一帧结束时间
	if self.nLightIndex > self.nEndLightIndex then
		--显示动画
		self:stopAndShowResult()
		-- print("subTime===",getSystemTime() - self.nBeginTime )
	else
		--最后面倒数6(一圈)明显示减速
		local nNextT = 0
		if self.nLightIndex >= self.nEndLightIndex - 6 then
			nNextT = nT + self.nLightIndex * 0.006/3
			if nNextT > 1 then				
				nNextT = 1
			end
			-- print("1nT,nNextT==",nT, nNextT)
		else
			nNextT = nT +  self.nLightIndex * 0.0001/3
			if nNextT > 0.075/3 then				
				nNextT = 0.075/3
			end
			-- --第一圈
			-- if self.nLightIndex <= self.nGoodsMax * 1 then
			-- 	nNextT = nT + self.nLightIndex * 0.0001
			-- --第二圈
			-- elseif self.nLightIndex <= self.nGoodsMax * 2 then
			-- 	nNextT = nT + self.nLightIndex * 0.0002
			-- --第三圈之后
			-- else
			-- 	nNextT = nT + self.nLightIndex * 0.0003
			-- end
			-- print("2nT,nNextT==",nT, nNextT)
		end
		--设置下一个时间循环
		self.nUpdateScheduler = MUI.scheduler.scheduleGlobal(handler(self, self.runAct), nNextT)
	end
end

--停止圆形动画
function SnatchturnLayer:stopCircleAnim( )
	if self.nUpdateScheduler then
	    MUI.scheduler.unscheduleGlobal(self.nUpdateScheduler)
	    self.nUpdateScheduler = nil
	end
	for i=1,#self.pParitcles do
		self.pParitcles[i]:removeFromParent(true)
	end
	self.pParitcles = {}

	--关闭不可点击
	if self.bIsOpenUnableTouch then
		self.bIsOpenUnableTouch = false
		hideUnableTouchDlg()
	end
end

--设置切换的动画特效
function SnatchturnLayer:showChangeEffect( nIndex, bIsPlayParticle)
	local pLayGoods = self.pLayGoodsList[nIndex]
	if pLayGoods then
		local nOffsetX, nOffsetY = 43, 75

		--边框动画
		local sName = createAnimationBackName("tx/exportjson/", "sg_htyl_sl_gks_001")
	    local pLightArm = ccs.Armature:create(sName)
	   	pLayGoods:addView(pLightArm)
	    pLightArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
			if (eventType == MovementEventType.COMPLETE) then
				pLightArm:removeSelf()
			end
		end)
		pLightArm:getAnimation():play("Animation1", 1)
		pLightArm:setPosition(nOffsetX, nOffsetY)
	    
	    --显示边框
	    local nX, nY = pLayGoods:getPosition()
		self.pImgBorder:setPosition(cc.p(nX + nOffsetX, nY + nOffsetY))
		self.pImgBorder:setVisible(true)

		--播放粒子
		if bIsPlayParticle then
			local pParitcle =  createParitcle("tx/other/lizi_haotieyl_d_001.plist")
			pParitcle:setPosition(nX + nOffsetX, nY + nOffsetY)
			self.pCCSView:addView(pParitcle, 11)
			table.insert(self.pParitcles, pParitcle)
		end

		--切换图片
		local tGoods = self.tGoodsList[nIndex]
		if tGoods then
			local pIcon = getIconGoodsByType(self.pLayCenterGoods, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
			local nNum = self.tGoodsCnt[nIndex]
			if pIcon then
				pIcon:setNumber(nNum)
			end
		end
	end
end

--显示中间动画
function SnatchturnLayer:showCenterGoods( nIndex )
	self.pLayCenterGoods:setVisible(true)
	self.pBlueParitcle1:setVisible(true)
	self.pBlueParitcle2:setVisible(true)
	--切换图片
	local tGoods = self.tGoodsList[nIndex]
	if tGoods then
		local pIcon = getIconGoodsByType(self.pLayCenterGoods, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
		local nNum = self.tGoodsCnt[nIndex]
		if pIcon then
			pIcon:setNumber(nNum)
		end
	end
end

--强制结束和显示结果
function SnatchturnLayer:stopAndShowResult( )
	--停止动画
	self:stopCircleAnim()
	--恢复显示
	self.pLayCenterTxt:setVisible(true)
	self.pLayCenterGoods:setVisible(false)
	self.pImgBorder:setVisible(false)
	self.pBlueParitcle1:setVisible(false)
	self.pBlueParitcle2:setVisible(false)
	self.pLayCirclLight:setVisible(false)
	--抽奖结束回调
	if self.nOverCallBackFunc then
		self.nOverCallBackFunc()
	end
end


return SnatchturnLayer


