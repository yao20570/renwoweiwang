----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-03-31 10:18:23
-- Description: 地图上的乱军
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DotLabel = require("app.layer.world.DotLabel")
local nShowYAdd = 6
local nNameZorder = 109

local WildArmyDot = class("WildArmyDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

--pWorldLayer：世界层
--pImgDot 视图点图片（减少drawcall）
function WildArmyDot:ctor( pWorldLayer, pImgDot, pClickNode)
	self.pWorldLayer= pWorldLayer
	self.pImgDot = pImgDot
	self.pClickNode = pClickNode
	WorldFunc.setCameraMaskForView(self.pImgDot)
	--解析文件
	parseView("layout_world_other_dot", handler(self, self.onParseViewCallback))
end

--解析界面回调
function WildArmyDot:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView, 1)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
    self:setDestroyHandler("WildArmyDot",handler(self, self.onWildArmyDotDestroy))
end

function WildArmyDot:onWildArmyDotDestroy(  )
	self:onPause()
end

function WildArmyDot:onResume(  )
	self:regMsgs()
end

function WildArmyDot:onPause(  )
	self:unregMsgs()
end

function WildArmyDot:regMsgs( )
end

function WildArmyDot:unregMsgs( )
end

function WildArmyDot:setupViews(  )
	-- self.pLayIcon = self:findViewByName("lay_icon")
	-- self.pLayIcon:setPositionY(self.pLayIcon:getPositionY() + nShowYAdd)
	-- local pTxtName  = self:findViewByName("txt_name")

	-- pTxtName:setVisible(false) --隐藏起来 只拿来获取texture

	--创建名字
	local pTxtName = MUI.MLabel.new({text = "1", size = 22})
	pTxtName:setVisible(false) --隐藏起来 只拿来获取texture
	self:addChild(pTxtName, nNameZorder)

	--创建等级
	local pTxtLv = MUI.MLabel.new({text = "1", size = 22})
	pTxtLv:setVisible(false) --隐藏起来 只拿来获取texture
	self:addChild(pTxtLv, nNameZorder)

	self.pLayLvBg = self:findViewByName("lay_lv_bg")

	--乱军坐标和位置
	self.tWArmyLvBgPos = {x = 61, y = 16}

	--创建一个等级背景框
	self.pBbLvBg = createCCBillBorad("#v1_img_dengjidi3c.png")
	self.pBbLvBg:setPosition3D(cc.vec3(61, 16, 1))
	self.pLayLvBg:addChild(self.pBbLvBg,100)
	
	--标签
	self.pBbLv = DotLabel.new(pTxtLv)
	self.pBbLv:setPosition3D(cc.vec3(18, 18, 2))
	self.pBbLvBg:addChild(self.pBbLv,22)

	--魔兵名字面板
	self.pBbNameBg = createCCBillBorad("ui/daitu.png")
	self.pBbNameBg:setPosition3D(cc.vec3(self.pBbNameBg:getContentSize().width / 2 + 20, 14,0))
	self.pLayLvBg:addChild(self.pBbNameBg,100)

	--魔兵名字
	self.pBbName = DotLabel.new(pTxtName)
	self.pBbNameBg:addChild(self.pBbName,22)
	setTextCCColor(self.pBbName, _cc.lwhite)

	--设置层大小
	self.pClickNode:setLayoutSize(self:getContentSize())

	--初始化特效
	self.pArrowTx = getArrowAction()
	local pImg = self.pArrowTx:getChildByTag(201708101504)
	if pImg then
		WorldFunc.setCameraMaskForView(pImg)
	end
	self:addView(self.pArrowTx, 10)
	self.pArrowTx:setPosition3D(cc.vec3(self:getWidth()/2 - 30, self:getHeight()/2 + 10, 20))
	self.pArrowTx:setVisible(false)
	
	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--设置服务器数据
--tData:ViewDotMsg
function WildArmyDot:setData( tData )
	self.tData = tData
	self.tArmyData = nil
	if self.tData then
		if self.tData.bIsMoBing then
			self.tArmyData = getAwakeArmyData(self.tData.nRebelId)
		else
			self.tArmyData = getWorldEnemyData(self.tData.nRebelId)
		end
	end
	self:updateViews()
end

--获取数据
function WildArmyDot:getData(  )
	return self.tData
end

function WildArmyDot:getDotKey()
	if not self.tData then
		return
	end
	return self.tData.sDotKey
end

--更新
function WildArmyDot:updateViews(  )
	if not self.tData then
		return
	end

	--防止重复刷新
	if self.nRebelId ~= self.tData.nRebelId then
		self.nRebelId = self.tData.nRebelId
		local tArmyData = self.tArmyData
		self.pImgDot:setScale(0.7)
		if tArmyData then
			--等级
			self.pBbLv:setString(tArmyData.level)

			if self.tData.bIsMoBing then
				--魔君图标
				-- local pImg = WorldFunc.getMoBingIconOfContainer(self.pLayIcon, self.nRebelId)
				-- if pImg then
				-- 	if not pImg.bIsAddCarema then
				-- 		pImg.bIsAddCarema = true
				-- 		WorldFunc.setCameraMaskForView(pImg)
				-- 	end
				-- end
				self.pImgDot:setCurrentImage(tArmyData.sIcon)
				-- self.pImgDot:setScale(0.7)


				self.pBbName:setString(tArmyData.name)
				self.pBbName:setVisible(true)

				WorldFunc.updateBbNameBgByStrWidth(self.pBbNameBg, self.pBbName:getContentSize().width)
				self.pBbNameBg:setVisible(true)

				--位置居中
				local nNameBgW = self.pBbNameBg:getContentSize().width
				local nNameBgH = self.pBbNameBg:getContentSize().height
				local nLvBgW = self.pBbLvBg:getContentSize().width

				self.pBbNameBg:setPosition(self.tWArmyLvBgPos.x + nLvBgW/2 - 30 + 5, self.tWArmyLvBgPos.y-25)
				-- self.pBbName:setPosition(nNameBgW/2+11, nNameBgH/2 - 1)
				self.pBbName:setPosition3D(cc.vec3(nNameBgW/2+11, nNameBgH/2, -30))
				self.pBbLvBg:setPosition(self.pBbNameBg:getPositionX() - nNameBgW/2 - nLvBgW/2 + 32, self.tWArmyLvBgPos.y - 20)
			else
				--乱军图标
				-- local pImg = WorldFunc.getWildArmyIconOfContainer(self.pLayIcon, self.nRebelId)
				-- if pImg then
				-- 	if not pImg.bIsAddCarema then
				-- 		pImg.bIsAddCarema = true
				-- 		WorldFunc.setCameraMaskForView(pImg)
				-- 	end
				-- end

				self.pImgDot:setCurrentImage(tArmyData.sIcon)
				-- if tArmyData.level == 1 or tArmyData.level == 2 then  --等级为1,2级的图要缩小到70%
				-- 	self.pImgDot:setScale(0.7)
				-- end

				--乱军动画
				-- if self.nPrevGitId ~= tArmyData.gif then
				-- 	self.nPrevGitId = tArmyData.gif
				-- 	self.pArmyArm = WorldFunc.getWildArmyArmOfContainer(self.pLayIcon, self.nRebelId)
				-- end

				self.pBbLvBg:setPosition(self.tWArmyLvBgPos.x, self.tWArmyLvBgPos.y-16)
				self.pBbNameBg:setVisible(false)
				self.pBbName:setVisible(false)

			end
		end
	end

	--防止重复刷新
	if self.nX ~= self.tData.nX or self.nY ~= self.tData.nY then
		self.nX = self.tData.nX
		self.nY = self.tData.nY

		--更新坐标
		local fX, fY = self.tData:getWorldMapPos( )
		self:setPosition(fX, fY)

		self.pImgDot:setPosition(fX, fY + nShowYAdd)

		self.pClickNode:setPosition(fX, fY)
	end

	--更新底座特效
	self:updateCircleEffect()

	--更新是否显示进攻特效
	self:updateAtkEffect()	

	--更新是否可以进攻
	self:updateCanAtkLv()

	--更新是否动画隐藏
	self:updateVisibleFightArm()
end

--是否可杀
function WildArmyDot:updateCanAtkLv( )
	local tArmyData = self.tArmyData
	if not tArmyData then
		return
	end

	local bIsCanAtk = false
	if tArmyData.level <= Player:getWorldData():getCanAtkWildArmyLv() then
		bIsCanAtk = true
	end
	if self.bIsCanAtk == bIsCanAtk then
		return
	end
	self.bIsCanAtk = bIsCanAtk

	--判断是否是可以打的，不可以打显示红色
	if self.bIsCanAtk then
		setTextCCColor(self.pBbLv, _cc.lwhite)
	else
		setTextCCColor(self.pBbLv, _cc.red)
	end
end

--更新是否显示进攻特效
function WildArmyDot:updateAtkEffect(  )
	if not self.tData then
		return
	end

	local bIsShowAtkEffect = Player:getWorldData():getViewDotIsShowAtkEffect(self.tData.nX, self.tData.nY)
	if self.bIsShowAtkEffect ~= bIsShowAtkEffect then
		self.bIsShowAtkEffect = bIsShowAtkEffect

		if self.bIsShowAtkEffect then
			-- if not self.pArmActions then
			-- 	local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
			-- 	self.pArmActions = WorldFunc.getViewDotAtkEffect(self, fX, fY, 0)
			-- 	for i=1,#self.pArmActions do
			-- 		WorldFunc.setCameraMaskForView(self.pArmActions[i])
			-- 	end
			-- end

			if not self.pArmActions then
				self.pArmActions = WorldFunc.getViewDotAtkEffect(self.pClickNode, 0, 0, 0, 0.8)
				for i=1,#self.pArmActions do
					self.pArmActions[i]:setOpacity(0)
					WorldFunc.setCameraMaskForView(self.pArmActions[i])
				end

				--5侦后执行显示
				gRefreshViewsAsync(self, 5, function ( _bEnd, _index )
					if _bEnd then
						for i=1,#self.pArmActions do
							self.pArmActions[i]:setOpacity(255)
						end
					end
				end)
			end
			--循环动画整体缩放值
			self.pClickNode:setVisible(true)
			self.pClickNode:stopAllActions()
			self.pClickNode:setOpacity(0)
			self.pClickNode:setScale(1.5)
			--动画
			if self.pArmActions then
				for i=1,#self.pArmActions do
					self.pArmActions[i]:setVisible(true)
					self.pArmActions[i]:play(-1)
				end
			end
			--动作
			local pSeqAct = cc.Sequence:create({
				cc.Spawn:create({
					cc.FadeIn:create(0.3),
					cc.ScaleTo:create(0.3, 1),
				}),
			})
			self.pClickNode:runAction(pSeqAct)
		else
			-- if self.pArmActions then
			-- 	for i=1,#self.pArmActions do
			-- 		self.pArmActions[i]:stop()
			-- 		MArmatureUtils:removeMArmature(self.pArmActions[i])
			-- 	end
			-- 	self.pArmActions = nil
			-- end
			if self.pArmActions then
				for i=1,#self.pArmActions do
					self.pArmActions[i]:stop()
					self.pArmActions[i]:setVisible(false)
				end
			end
			self.pClickNode:setVisible(false)
		end
	end
end

--底座特效
function WildArmyDot:updateCircleEffect()
	local tArmyData = self.tArmyData
	if tArmyData then
		local nArmyLv = Player:getWorldData():getWildArmyCirEffectLv() --需要显示箭头特效的乱军等级
		if tArmyData.level == nArmyLv then
			if self.pArrowTx then
				self.pArrowTx:setVisible(true)
			end
		else
			if self.pArrowTx then
				self.pArrowTx:setVisible(false)
			end
		end
	else
		if self.pArrowTx then
			self.pArrowTx:setVisible(false)
		end
	end
end

--更新播放动画
function WildArmyDot:updateVisibleFightArm( )
	if not self.tData then
		return
	end
	local sDotKey = self.tData:getDotKey()
	local bIsPlay = Player:getWorldData():getPosIsWArmyFight(sDotKey)
	if bIsPlay then
		--隐藏所有
		-- self.pLayIcon:setVisible(false)
		self.pImgDot:setVisible(false)
		self.pBbLvBg:setVisible(false)
		self.pBbLv:setVisible(false)
		if self.tData.bIsMoBing then
			self.pBbNameBg:setVisible(false)
			self.pBbName:setVisible(false)
		end
	else
		--显示所有
		-- self.pLayIcon:setVisible(true)
		self.pImgDot:setVisible(true)
		self.pBbLvBg:setVisible(true)
		self.pBbLv:setVisible(true)
		if self.tData.bIsMoBing then
			self.pBbNameBg:setVisible(true)
			self.pBbName:setVisible(true)
		end
	end
end

--隐藏
function WildArmyDot:setVisibleEx( bIsShow )
	if bIsShow then
		if self.pArmyArm then
			self.pArmyArm:play(-1)
		end
	else
		if self.pArmyArm then
			self.pArmyArm:stop()
		end
		--清空数据
		self:delViewDotMsg()
	end
	self:setVisible(bIsShow)
	self.pImgDot:setVisible(bIsShow)
	self.pClickNode:setVisible(bIsShow)
end

function WildArmyDot:delViewDotMsg( )
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
end


return WildArmyDot
