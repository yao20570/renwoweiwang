----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-25 16:20:30
-- Description: 地图上的Boss
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local DotLabel = require("app.layer.world.DotLabel")
local nShowYAdd = 6
local nWarZorder = 2
local nPosZ = 1
local nSwordArmZorder = 10
local nNameZorder = 109
local GhostdomDot = class("GhostdomDot",function ( )
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	pView:setAnchorPoint(0.5,0.5)
    return pView
end)

--pWorldLayer：世界层
--pImgDot 视图点图片（减少drawcall）
function GhostdomDot:ctor( pWorldLayer, pImgDot, pClickNode)
	self.pWorldLayer= pWorldLayer

	self.pImgDot = pImgDot
	self.pClickNode = pClickNode
	WorldFunc.setCameraMaskForView(self.pImgDot)
	--解析文件
	parseView("layout_world_other_dot", handler(self, self.onParseViewCallback))
end

--解析界面回调
function GhostdomDot:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView, 1)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
    self:setDestroyHandler("GhostdomDot",handler(self, self.onBossDotDestroy))
end

function GhostdomDot:onBossDotDestroy(  )
	self:onPause()
end

function GhostdomDot:onResume(  )
	self:regMsgs()
end

function GhostdomDot:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function GhostdomDot:regMsgs( )
end

function GhostdomDot:unregMsgs( )
end

function GhostdomDot:setupViews(  )
	-- self.pLayIcon = self:findViewByName("lay_icon")
	-- self.pLayIcon:setPositionY(self.pLayIcon:getPositionY() + nShowYAdd)
	--创建等级
	-- local pTxtLv = MUI.MLabel.new({text = "1", size = 22})
	-- pTxtLv:setVisible(false) --隐藏起来 只拿来获取texture
	-- self:addChild(pTxtLv, nNameZorder)

	local pTxtName = self:findViewByName("txt_name")
	pTxtName:setVisible(false) --隐藏起来 只拿来获取texture
	self.pLayLvBg = self:findViewByName("lay_lv_bg")

	--乱军坐标和位置
	self.tWArmyLvBgPos = {x = 61, y = 16}

	--创建一个等级背景框
	-- self.pBbLvBg = createCCBillBorad("#v1_img_dengjidi2.png")
	-- self.pBbLvBg:setPosition3D(cc.vec3(61, 16, 1))
	-- self.pLayLvBg:addChild(self.pBbLvBg,100)

	--标签
	-- self.pBbLv = DotLabel.new(pTxtLv)
	-- self.pBbLv:setPosition3D(cc.vec3(22, 22, 2))
	-- self.pBbLvBg:addChild(self.pBbLv,22)

	-- self.nBbScale = 0.5
	-- self.pBbLvBg:setScale(self.nBbScale)


	---Boss名字面板
	self.pBbNameBg = createCCBillBorad("ui/daitu.png")
	self.pBbNameBg:setPosition3D(cc.vec3(self.pBbNameBg:getContentSize().width / 2 + 15, 14, 0))
	self.pLayLvBg:addChild(self.pBbNameBg,100)

	--Boss名字
	self.pBbName = DotLabel.new(pTxtName)
	self.pBbNameBg:addChild(self.pBbName,20)

	--设置层大小
	self.pClickNode:setLayoutSize(self:getContentSize())

	-- --城战
	-- self.pImgWar = createCCBillBorad("#v1_img_zjm_wzqph.png")
	-- self.pImgWar:setScale(0.5)
	-- self:addChild(self.pImgWar, nWarZorder)
	-- self.pImgWarIcon = createCCBillBorad("#v1_btn_guozhan2.png")
	-- self.pImgWarIcon:setScale(0.5)
	-- self:addChild(self.pImgWarIcon, nWarZorder)
	--城战位置
	-- local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2 + 50
	-- self.pImgWar:setPosition3D(cc.vec3(fX, fY - 2, nPosZ))
	-- self.pImgWarIcon:setPosition3D(cc.vec3(fX, fY - 3, nPosZ + 1))

	--设置相机类型
	WorldFunc.setCameraMaskForView(self)
end

--设置服务器数据
--tData:ViewDotMsg
function GhostdomDot:setData( tData )
	self.tData = tData
	
	self.tArmyData = getWorldGhostdomData(self.tData.nGId)
	self:updateViews()
end

--获取数据
function GhostdomDot:getData(  )
	return self.tData
end

function GhostdomDot:getDotKey()
	if not self.tData then
		return
	end
	return self.tData.sDotKey
end

--更新
function GhostdomDot:updateViews(  )
	if not self.tData then
		return
	end

	--防止重复刷新
	--防止重复刷新
	if self.nGId ~= self.tData.nGId then
		self.nGId = self.tData.nGId
		local tArmyData = self.tArmyData
		self.pImgDot:setScale(0.7)
		if tArmyData then
			-- self.pBbLv:setString(tArmyData.level2)
			--图标
			-- WorldFunc.setWorldBossBBFlag(self.pBbLvBg, self.nBossLv)

			--名字
			self.pBbName:setString(tArmyData.name)

			--名字面板
			WorldFunc.updateBbNameBgByStrWidth(self.pBbNameBg, self.pBbName:getContentSize().width)

			--位置居中
			local nNameBgW = self.pBbNameBg:getContentSize().width
			local nNameBgH = self.pBbNameBg:getContentSize().height
			-- local nLvBgW = self.pBbLvBg:getContentSize().width

			self.pBbNameBg:setPosition3D(cc.vec3(self.tWArmyLvBgPos.x , self.tWArmyLvBgPos.y, 0))
			self.pBbName:setPosition3D(cc.vec3(nNameBgW/2, nNameBgH/2, 1))
			-- self.pBbLvBg:setPosition3D(cc.vec3(self.pBbNameBg:getPositionX() - nNameBgW/2 - nLvBgW/2 + 10, self.tWArmyLvBgPos.y - 1, 1))

			self.pImgDot:setCurrentImage(tArmyData.sIcon)
		end
	end

	--防止重复刷新
	if self.nX ~= self.tData.nX or self.nY ~= self.tData.nY then
		self.nX = self.tData.nX
		self.nY = self.tData.nY
		--更新坐标
		local fX, fY = self.pWorldLayer:getMapPosByDotPos(self.tData.nX,self.tData.nY)
		self:setPosition(fX, fY)

		self.pImgDot:setPosition(fX, fY + nShowYAdd)

		self.pClickNode:setPosition(fX, fY)
	end

	--更新是否显示进攻特效
	self:updateAtkEffect()	

	--更新发起了战争Ui
	self:updateWarUi()
end

--更新离开时间
function GhostdomDot:updateCd( )
	if not self.tData then
		unregUpdateControl(self)
		return
	end

	local nCd = self.tData:getBossLeaveCd()
	if nCd <= 0 then
		unregUpdateControl(self)
	end
end

--更新发起了战争Ui
function GhostdomDot:updateWarUi( )
	--显示战争Ui
	if self.tData then
		if self.tData.bIsHasBossWar then
			self:showCityWarEffect(true)
		else
			self:showCityWarEffect(false)
		end
	else
		self:showCityWarEffect(false)
	end
end


--国战特效显示
function GhostdomDot:showCityWarEffect( bIsShow )
	--减少刷新
	if self.bWarEffectPrev == bIsShow then
		return
	end
	self.bWarEffectPrev = bIsShow
	-- self.pImgWar:setVisible(bIsShow)
	-- self.pImgWarIcon:setVisible(bIsShow)

	if bIsShow then
		--武器动画
		-- if not self.pSwordArmList then
		-- 	self.pSwordArmList = {}
		-- 	local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
		-- 	for i=1,3 do
		-- 		local pArm = MArmatureUtils:createMArmature(
		-- 			tNormalCusArmDatas["47_"..i],
		-- 			self,
		-- 			nWarZorder,
		-- 			cc.p(fX, fY),
		-- 			function ( _pArm )
		-- 				_pArm:removeSelf()
		-- 				_pArm = nil 
		-- 			end, Scene_arm_type.world, cc.BillBoard_Mode.VIEW_PLANE_ORIENTED)
		-- 		if pArm then
		-- 			WorldFunc.setCameraMaskForView(pArm)
		-- 			pArm:play(-1)
		-- 			table.insert(self.pSwordArmList, pArm)
		-- 		end
		-- 	end
		-- else
		-- 	for i=1,#self.pSwordArmList do
		-- 		self.pSwordArmList[i]:setVisible(true)
		-- 		self.pSwordArmList[i]:play(-1)
		-- 	end
		-- end

		--新动画
		if self.pSwordArm then
			self.pSwordArm:setVisible(true)
		else
			local sName = createAnimationBackName("tx/exportjson/", "rwww_gjtx_yhyb_001")
		    self.pSwordArm = ccs.Armature:create(sName)
		    self.pSwordArm:getAnimation():play("Animation1", -1, -1)
		    local fX, fY = self:getContentSize().width/2, self:getContentSize().height/2
		    self.pSwordArm:setPosition(fX, fY)
		    self.pSwordArm:setScale(0.6)
		    self:addChild(self.pSwordArm,nSwordArmZorder)
		    WorldFunc.setCameraMaskForView(self.pSwordArm)
		end
	else
		self:hideSwordArm()
	end
end

--隐藏剑动画
function GhostdomDot:hideSwordArm(  )
	-- if self.pSwordArmList then
	-- 	for i=1,#self.pSwordArmList do
	-- 		self.pSwordArmList[i]:setVisible(false)
	-- 		self.pSwordArmList[i]:stop()
	-- 	end
	-- end
	--新动画
	if self.pSwordArm then
		self.pSwordArm:setVisible(false)
	end
end

--更新是否显示进攻特效
function GhostdomDot:updateAtkEffect(  )
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

--判断是否点中召唤气泡
--屏幕坐标
function GhostdomDot:checkIsClickedWar( fWorldX, fWorldY )
	-- --是否点击中战
	-- if self.pImgWar:isVisible() then
	-- 	local fX1,fY1 = self:getPosition()
	-- 	fX1 = fX1 - self:getContentSize().width/2
	-- 	fY1 = fY1 - self:getContentSize().height/2
	-- 	local fX2,fY2 = self.pImgWar:getPosition()
	-- 	local pRect = self.pImgWar:getBoundingBox()
	-- 	pRect.x = fX1 + fX2 - pRect.width/2
	-- 	pRect.y = fY1 + fY2 - pRect.height/2
	-- 	local pTouchPos = cc.p(fWorldX, fWorldY)
	-- 	if cc.rectContainsPoint(pRect, pTouchPos) then
	-- 		--获取Boss战列表
	-- 		SocketManager:sendMsg("reqWorldBossWarList",{self.tData.nX, self.tData.nY})
	-- 		return true
	-- 	end
	-- end
	return false
end

--隐藏
function GhostdomDot:setVisibleEx( bIsShow )
	if bIsShow then
		--开始更新
		regUpdateControl(self, handler(self, self.updateCd))
	else
		--清空数据
		self:delViewDotMsg()
		--去掉更新
		unregUpdateControl(self)
	end
	self:setVisible(bIsShow)
	self.pImgDot:setVisible(bIsShow)
	self.pClickNode:setVisible(bIsShow)
end

function GhostdomDot:delViewDotMsg( )
	--清空数据
	if self.tData then
		Player:getWorldData():delViewDotMsg(self.tData)
		self.tData = nil
	end
end



return GhostdomDot
