-- Author: liangzhaowei
-- Date: 2017-04-13 14:58:34
-- 副本关卡item

local MCommonView = require("app.common.MCommonView")
local ItemFubenLevel = class("ItemFubenLevel", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index
function ItemFubenLevel:ctor(_index)
	-- body
	self:myInit()

	self.nIndex = _index or self.nIndex
    
	parseView("item_fuben_level", handler(self, self.onParseViewCallback))
    
	--注册析构方法
	self:setDestroyHandler("ItemFubenLevel",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemFubenLevel:myInit()
	-- body
	self.nIndex = 1

	self.pData = {} --章节数据
end

--解析布局回调事件
function ItemFubenLevel:onParseViewCallback( pView )
    self.pMainView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemFubenLevel:setupViews( )
	self:setViewTouched(true)
	self:onMViewClicked(handler(self,self.onViewClick))

                      	
	self.pLyMain =  self.pMainView:getChildByName("ly_main")

	--ly
	self.pImgLevel = self.pLyMain:getChildByName("img_level")

	--投影
	self.pLayShadow = self.pLyMain:getChildByName("lay_shadow")  

	self.pLyStart =  self.pLyMain:getChildByName("ly_start")    
	self.pLyStart:setVisible(false)     
    
    self.tImgStart = {}
	for i=1,3 do
		self.tImgStart[i] = self.pLyStart:getChildByName("img_start_"..i)
		-- self.tImgStart[i]:setScale(scale)
	end

	self.pLbName = self.pLyMain:getChildByName("lb_name")
	self.pLbName:setString(tostring(self.nIndex))

	self.pImgName = self.pLyMain:getChildByName("img_name")
    

end

--显示或隐藏投影、星星和名字
function ItemFubenLevel:showStarLayAndName(_bVis)
	-- body
	self.pLbName:setVisible(_bVis)
	self.pImgName:setVisible(_bVis)
	self.pLayShadow:setVisible(_bVis)
end

-- 修改控件内容或者是刷新控件数据
function ItemFubenLevel:updateViews(  )

	if not self.pData then
		return
	end
	--如果是新关卡开启并且还不能刷新数据(等播放特效后刷新)
	local bTar = false
	
	if self.pData.bOpen then
		if self.tOpenPost then
			for _, id in pairs(self.tOpenPost) do
				if self.pData.nId == id then
					bTar = true
				end
			end
		end
	end
	local nFromItemId = Player:getFuben():getChanllengeId()
	if self.tOpenPost and self.pData.nId == nFromItemId then
		self:setViewTouched(false)
	end
	if bTar and not self.bCanRefresh then
		self:setViewTouched(false)
		return
	end
	
	if self.pData.nId == nFromItemId and self.tOpenPost and not self.bCanRefresh then
		return
	end

	--关卡名字
	if self.pData.sName then
		self.pLbName:setString(self.pData.sName or "1")
	end

	--如果是普通关卡且已经通关
	-- if self.pData.nType == 0 and self.pData.nP == 1 and self.pData.nCanRepeat == 0 then 
	-- 	self.pData.nS = 3 --强行展示获得星星个数未 3
	-- end
	

	--星级
	if self.pData.bOpen and self.pData.nS and  self.pData.nS > 0 then
		self.pLyStart:setVisible(true)
		for k,v in pairs(self.tImgStart) do
			if self.pData.nS >= k then
				v:setCurrentImage("#v1_img_star5.png")
			else
				v:setCurrentImage("#v2_img_star5b.png")
			end
		end
	else
		self.pLyStart:setVisible(false)
	end


	--重置大小以及位置
	self.pImgName:setContentSize(self.pLbName:getWidth()+30,self.pImgName:getHeight())
	local nPosX = self.pLyMain:getWidth()/2
	self.pImgName:setPositionX(nPosX)
	self.pLbName:setPositionX(nPosX)


    
	-- if self.nIndex == 6 then
	-- 	self.pImgLevel:setScale(1)
	-- else
	-- 	self.pImgLevel:setScale(0.8)
	-- end

	self:showStarLayAndName(self.pData.bOpen)

	if self.pData.bOpen then
		-- self:setVisible(true)
		--关卡图片
		if self.pData.sIcon then
			self.pImgLevel:setCurrentImage(self.pData.sIcon)
		end
		if self.pData.nCanRepeat == 0 and self.pData.nP == 1 then  --通关且不可重复挑战
			self:setViewTouched(false)
			self:setViewEnabled(false)
			for i=1, 3, 1 do
				self:showWaveTx(i, false)
			end
			self:showOtherTx(false)
		else
			self:setViewTouched(true)
			self:setViewEnabled(true)


			if self.bCanRefresh then
				--新关卡开启动画
				self.pImgLevel:setScale(1.13)
				self.pImgLevel:setAnchorPoint(0.5, 0.5)
				local nPosY = self.pImgLevel:getPositionY()
				self.pImgLevel:setPositionY(nPosY + self.pImgLevel:getHeight()/2)
				local pSequence = cc.Sequence:create({
			        cc.ScaleTo:create(0.17, 0.97),
			        cc.ScaleTo:create(0.29 - 0.17, 1.02),
			        cc.ScaleTo:create(0.58 - 0.29, 1),
			        })
			    self.pImgLevel:runAction(pSequence)

			    local pImg2 = MUI.MImage.new(self.pData.sIcon)
				self.pLyMain:addView(pImg2, 10)
				pImg2:setPosition(self.pImgLevel:getPosition())
				pImg2:setScale(1.13)
				pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
				local pSequence = cc.Sequence:create({
					cc.Spawn:create({
			            cc.ScaleTo:create(0.17, 0.97),
			            cc.FadeTo:create(0.97, 255*0.73)
			            }),
					cc.Spawn:create({
			            cc.ScaleTo:create(0.29 - 0.17, 1.02),
			            cc.FadeTo:create(0.29 - 0.17, 255*0.53)
			            }),
					cc.Spawn:create({
			            cc.ScaleTo:create(0.58 - 0.29, 1),
			            cc.FadeTo:create(0.58 - 0.29, 0)
			            }),
			        cc.CallFunc:create(function()
				        pImg2:removeSelf()
				    end)
			        })
			    pImg2:runAction(pSequence)

			    local pImg3 = MUI.MImage.new(self.pData.sIcon)
				self.pLyMain:addView(pImg3, 10)
				pImg3:setPosition(self.pImgLevel:getPosition())
				pImg3:setScale(1.44)
				pImg3:setOpacity(255*0.35)
				pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
				local pSequence = cc.Sequence:create({
					cc.Spawn:create({
			            cc.ScaleTo:create(0.58, 1.79),
			            cc.FadeTo:create(0.58, 0)
			            }),
			        cc.CallFunc:create(function()
				        pImg3:removeSelf()
						self.pImgLevel:setPositionY(nPosY)
						self.pImgLevel:setAnchorPoint(0.5, 0)
				    end)
			        })
			    pImg3:runAction(pSequence)
			end



			--波纹特效
			for i=1, 3, 1 do
				self:performWithDelay(function (  )
					if not (self.pData.nCanRepeat == 0 and self.pData.nP == 1) then
						self:showWaveTx(i, true)
					end
				end, 0.55*(i-1))
			end
			--其他特效
			self:showOtherTx(true)
		end
	else
		-- self:setVisible(false)
		--关卡图片设置为锁定
		self.pImgLevel:setCurrentImage("#v1_weijiesuo_fb.png")

		self:setViewTouched(true)
		self:setViewEnabled(true)
		for i=1, 3, 1 do
			self:showWaveTx(i, false)
		end
		self:showOtherTx(false)
	end
    
end

--当前关卡波纹特效显示
function ItemFubenLevel:showWaveTx(_index, _vis )
	self.tTx = self.tTx or {}
	local pos = cc.p(self.pLayShadow:getWidth() / 2, 20)
	if(_vis) then
		if(not self.tTx[_index]) then
			if self.nIndex == 6 then
				self.tTx[_index] = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["43"], 
				self.pLayShadow, 
				10, 
				pos,
				function ( _pArm )

				end, Scene_arm_type.normal)
			else
				self.tTx[_index] = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["44"], 
				self.pLayShadow, 
				10, 
				pos,
				function ( _pArm )

				end, Scene_arm_type.normal)
			end
			self.tTx[_index]:play(-1)
		end

		self.tTx[_index]:setVisible(_vis)
	else
		if(self.tTx[_index]) then
			self.tTx[_index]:setVisible(false)
		end
	end
end

--关卡其他特效显示
function ItemFubenLevel:showOtherTx(_vis)
	-- body
	local imgPos = cc.p(107, 51)
	if (_vis) then
		local pos = cc.p(self.pLayShadow:getWidth() / 2, 20)
		if not self.tOtherTx then
			self.tOtherTx = {}
			--1.
			local pImgCircle = MUI.MImage.new("#sg_fbtxtx_s_sda_002.png")
		    pImgCircle:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		    local pLayer1 = MUI.MLayer.new()
		    pLayer1:setLayoutSize(cc.size(pImgCircle:getWidth(), pImgCircle:getHeight()))
		    self.pLayShadow:addView(pLayer1, 9)
		    pLayer1:setPosition(pos)
		    pLayer1:addView(pImgCircle, 10)

		    if self.nIndex == 6 then
		    	pLayer1:setScaleX(1.1)
		    	pLayer1:setScaleY(0.44)
		    else
		    	pLayer1:setScaleX(0.75)
		    	pLayer1:setScaleY(0.3)
		    end
		    pImgCircle:setOpacity(255)
		    pImgCircle:runAction(cc.RepeatForever:create(
		        cc.RotateBy:create(3, -360)))
			table.insert(self.tOtherTx, pLayer1)
			--2.
			local pShadowTx
			if self.nIndex == 6 then
				pShadowTx = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["43_1"], 
					self.pLayShadow, 
					10, 
					pos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			else
				pShadowTx = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["44_1"], 
					self.pLayShadow, 
					10, 
					pos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			end
			pShadowTx:play(-1)
			table.insert(self.tOtherTx, pShadowTx)
			--3.
			local pDiTx
			if self.nIndex == 6 then
				pDiTx = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["43_2"], 
					self.pLayShadow, 
					10, 
					pos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			else
				pDiTx = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["44_2"], 
					self.pLayShadow, 
					10, 
					pos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			end
			pDiTx:play(-1)
			table.insert(self.tOtherTx, pDiTx)
			--4.
			local pBigWaveTx
			if self.nIndex == 6 then
				pBigWaveTx = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["43_3"],
				self.pLayShadow, 
				10, 
				pos,
			    function ( _pArm )

			    end, Scene_arm_type.normal)
			else
				pBigWaveTx = MArmatureUtils:createMArmature(
				tNormalCusArmDatas["44_3"],
				self.pLayShadow, 
				10, 
				pos,
			    function ( _pArm )

			    end, Scene_arm_type.normal)
			end
			pBigWaveTx:play(-1)
			table.insert(self.tOtherTx, pBigWaveTx)
			--5.
			-- local pImgLvTx1 = MArmatureUtils:createMArmature(
			-- 	tNormalCusArmDatas["43_4"],
			-- 	self.pLayShadow, 
			-- 	10, 
			-- 	pos,
			--     function ( _pArm )

			--     end, Scene_arm_type.normal)
			-- pImgLvTx1:play(-1)
			-- table.insert(self.tOtherTx, pImgLvTx1)
			--6.
			if self.nIndex == 6 then
				local pImgLvTxTx2 = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["43_5"],
					self.pLyMain, 
					10, 
					imgPos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			
				pImgLvTxTx2:play(-1)
				table.insert(self.tOtherTx, pImgLvTxTx2)
			end
			--7.
			local pLightTx
			if self.nIndex == 6 then
				pLightTx = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["43_6"],
					self.pLayShadow, 
					10, 
					pos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			else
				pLightTx = MArmatureUtils:createMArmature(
					tNormalCusArmDatas["44_4"],
					self.pLyMain, 
					10, 
					imgPos,
				    function ( _pArm )

				    end, Scene_arm_type.normal)
			end
			pLightTx:play(-1)
			table.insert(self.tOtherTx, pLightTx)
			--8.
			local pLiziEff = createParitcle("tx/other/sg_xgk_sa_la_001.plist")
			if self.nIndex == 6 then
				pLiziEff:setScale(1.3)
			else
				pLiziEff:setScale(1)
			end
    		self.pLyMain:addView(pLiziEff, 999)
    		pLiziEff:setPosition(imgPos.x, imgPos.y + 30)
			table.insert(self.tOtherTx, pLiziEff)

			--9.箭头指示特效
			local pArrowTx = getArrowAction(15, true)
			self.pLyMain:addView(pArrowTx, 10)
			local nArrowPosX = imgPos.x - pArrowTx:getWidth()/2
			local nArrowPosY
			if self.pLyStart:isVisible() then
				nArrowPosY = imgPos.y + self.pImgLevel:getHeight() + self.pLyStart:getHeight()
			else
				nArrowPosY = imgPos.y + self.pImgLevel:getHeight()
			end
			pArrowTx:setPosition(nArrowPosX, nArrowPosY)
			table.insert(self.tOtherTx, pArrowTx)

		end
	end

	if(self.tOtherTx) then
		for k, v in pairs(self.tOtherTx) do
			v:setVisible(_vis)
		end
		if _vis then
			local nArrowPosY = 0
			if self.pLyStart:isVisible() then
				nArrowPosY = imgPos.y + self.pImgLevel:getHeight() + self.pLyStart:getHeight()
			else
				nArrowPosY = imgPos.y + self.pImgLevel:getHeight()
			end
			self.tOtherTx[#self.tOtherTx]:setPositionY(nArrowPosY)
		end
	end
end

--析构方法
function ItemFubenLevel:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemFubenLevel:setCurData(_data, _tOpenPost)
	if not _data then
		return
	end

	self.pData = _data or {}
	self.tOpenPost = _tOpenPost

	self.bCanRefresh = false

	self:updateViews()



end


--可以刷新新开启数据了
function ItemFubenLevel:refreshOpenData()
	-- body
	self.bCanRefresh = true
	self:updateViews()
end

--view点击回调
function ItemFubenLevel:onViewClick(pView)
	--如果未解锁, 点击提示"通过%解锁"
	if not self.pData.bOpen then
		local tLevelData = Player:getFuben():getLevelById(self.pData.nPrevious)
		local str = string.format(getTipsByIndex(10069), tLevelData.sName)
		TOAST(str)
		return
	end

	local tLevleData = self.pData
	if tLevleData and table.nums(tLevleData)> 0 then
		local tObject = {}
		tObject.nType = e_dlg_index.armylayer --dlg类型
		tObject.nArmyType = en_army_type.fuben -- 部队类型
		tObject.sTitle = tLevleData.sName -- 部队界面标题
		tObject.tMyArmy = Player:getHeroInfo():getOnlineHeroList(true) --我方部队
		tObject.tEnemy = getNpcGropById(tLevleData.nMonsters) --地方部队
		tObject.nEnemyArmyFight = getNpcGropListDataById(tLevleData.nMonsters).score or 0 --敌方战力
		tObject.nExpendEnargy = tLevleData.nCost --战斗所需要能量
		tObject.tFubenData = tLevleData  --副本章节数据
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--获取章节数据
function ItemFubenLevel:getData()
	return self.pData
end



return ItemFubenLevel