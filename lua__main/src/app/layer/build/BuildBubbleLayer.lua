-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-07-05 17:46:46 星期三
-- Description: 建造冒泡
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local BuildBubbleLayer = class("BuildBubbleLayer", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function BuildBubbleLayer:ctor(_bSpecial)
	self:myInit()
	self.bSpecial = _bSpecial
	if self.bSpecial then
		parseView("layout_build_bubble_new", handler(self, self.onParseViewCallback))
	else
		parseView("layout_build_bubble", handler(self, self.onParseViewCallback))
	end
	
	
end

--初始化成员变量
function BuildBubbleLayer:myInit(  )
	-- body
	self.nType 			= 		nil 			--1：文字类型 2：图标类型1（黄底） 3：图标类型2（蓝底）
	self.nChildType 	= 		nil 			--冒泡类型 e_type_bubble 
	self.tAllYellowTx 	= 		nil 			--黄色光圈特效集合
	self.sYellowImgName = 		nil 			--黄色光圈特效图片名字
	self.bSpecial 		=		false 			--是否是三个兵营和科技园的特殊处理

	self.bShowTx 		= 		false
end

--解析布局回调事件
function BuildBubbleLayer:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView, 10)
	centerInView(self, pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("BuildBubbleLayer",handler(self, self.onBuildBubbleLayerDestroy))
end

--初始化控件
function BuildBubbleLayer:setupViews( )
	-- body
	--背景层
	self.pLayItem 		= 		self:findViewByName("default")
	--图片
	self.pImg 			= 		self:findViewByName("img")
	--label
	self.pLbText 		= 		self:findViewByName("lb_tips")

	--设置点击事件吞噬
	self:setTouchCatchedInList(true)
	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:setIsPressedNeedColor(false)
	self:onMViewClicked(handler(self, self.onItemClicked))

end

-- 修改控件内容或者是刷新控件数据
function BuildBubbleLayer:updateViews(  ) 
	-- body
	--建筑用背景图片v1_img_zjm_wzqpj 资源用背景图片v1_img_zjm_tzqpz
	if self.nType and self.nChildType then
		self.pImg:setScale(0.78)--默认缩放值
		self.pImg:setVisible(true) --默认展示
		local bIsPressedColor = true
		-- 8为原来背景图片（v1_img_zjm_wzqph 94）和 现在背景图片（v1_img_zjm_wzqpj 110）的差的一半，然后乘以缩放值
		if self.nType == 1 then
			self.pImg:setPositionY(48 + 8)
			--文字不显示
			self.pLbText:setVisible(false) 
			--设置背景层
			-- if self.bSpecial then
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqpj.png")
			-- else
				self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			-- end
			
			if self.nChildType == e_type_bubble.sjmf then --升级免费
				-- self.pImg:setVisible(false)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.tnolyspeed or
				self.nChildType == e_type_bubble.buildspeed or 
				self.nChildType == e_type_bubble.campspeed then --科研加速 
				--播放黄色光圈特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.zmwg then --招募文官
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#v1_fonts_zmwg.png") 
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.zbgfp then --珍宝阁翻牌
				self.pImg:setCurrentImage("#v1_fonts_fp.png") 
				--缩放效果
				self:showQiPaoRRsTx()
			elseif self.nChildType == e_type_bubble.bjtzm then --拜将台有免费招募
				self.pImg:setCurrentImage("#v1_fonts_mfzm.png") 
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.xlpmfxl then --洗炼铺的免费洗炼次数已满 
				self.pImg:setCurrentImage("#v1_fonts_xilian.png")
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.gatebc then --城门可增加城防军
				--播放黄色光圈特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.tjpspeedfree or self.nChildType == e_type_bubble.kjyspeedfree then --铁匠铺和科技院可免费加速
				--播放黄色光圈特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.recruit then --兵营有空闲队列 
				self:removeYellowRing()
				
				self.pImg:setCurrentImage("#v1_fonts_zhanm.png")
				--缩放效果
				self:showQiPaoRRsTx()
			elseif self.nChildType == e_type_bubble.jzkx then --工坊，科技园，铁匠铺 
				self:removeYellowRing()
				
				self.pImg:setCurrentImage("#v1_fonts_kongxian.png")
				--缩放效果
				self:showQiPaoRRsTx()
			elseif self.nChildType == e_type_bubble.zydh then --仓库有资源兑换次数
				self:removeYellowRing()
				self.pImg:setCurrentImage("#v1_fonts_zy.png") 
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()	
			elseif self.nChildType == e_type_bubble.gjqz then--国家互助
				--播放黄色光圈特效
				self:playYellowRing(2)
				self.pImg:setCurrentImage("#v2_fonts_qiuzhu.png") 
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			end
		elseif self.nType == 2 then --黄底
			
			--设置背景层
			-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			-- if self.bSpecial then
			-- 	self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqpj.png")
			-- else
				self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			-- end
			--文字不显示
			self.pLbText:setVisible(false)
			if self.nChildType == e_type_bubble.kjtb then --科技图标
				--正在研究的科技
				local tUpingTnoly = Player:getTnolyData():getUpingTnoly()
				if tUpingTnoly then
					self.pImg:setCurrentImage(tUpingTnoly.sSmallIcon) 
					self.pImg:setPositionY(48 + 8)
					self.pImg:setScale(0.78)
					--缩放效果
					-- self:showQiPaoRRsTx()
					--黄色光圈
					self:playYellowRing(2, tUpingTnoly.sSmallIcon)
					--展示摇摆类气泡效果
					self:showQiPaoRstTx()
				end
				bIsPressedColor = false
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			elseif self.nChildType == e_type_bubble.bbmb then --步兵 
				--缩放效果
				self.pImg:setPositionY(48 + 8)
				self.pImg:setScale(1.0)
				-- self:showQiPaoRRsTx()
				--黄色光圈
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.qbmb then --骑兵
				--缩放效果
				-- self:showQiPaoRRsTx()
				--黄色光圈
				self.pImg:setPositionY(48 + 8)
				self.pImg:setScale(1.0)
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()				
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.gbmb then --弓兵
				--缩放效果
				self.pImg:setPositionY(48 + 8)
				self.pImg:setScale(1.0)
				-- self:showQiPaoRRsTx()
				--黄色光圈
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()				
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.mjzs then --民居征收
				-- self.pImg:setVisible(false)
				self.pImg:setPositionY(48 + 8)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			elseif self.nChildType == e_type_bubble.ntzs then --农田征收
				-- self.pImg:setVisible(false)
				self.pImg:setPositionY(48 + 8)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			elseif self.nChildType == e_type_bubble.mczs then --木场征收
				-- self.pImg:setVisible(false)
				self.pImg:setPositionY(48 + 8)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			elseif self.nChildType == e_type_bubble.tkzs then --铁矿征收
				-- self.pImg:setVisible(false)
				self.pImg:setPositionY(48 + 8)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			elseif self.nChildType == e_type_bubble.mjjzcj then --民居建筑重建
				self.pImg:setPositionY(48 + 8*0.85)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.ntjzcj then --农田建筑重建
				self.pImg:setPositionY(48 + 8*0.85)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.mcjzcj then --木材建筑重建
				self.pImg:setPositionY(48 + 8*0.85)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.tkjzcj then --铁矿建筑重建
				self.pImg:setPositionY(48 + 8*0.85)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.tjptb then --铁匠铺生产完成
				--缩放效果
				self.pImg:setPositionY(48 + 8)
				-- self:showQiPaoRRsTx()
				--黄色光圈
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()				
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
				bIsPressedColor = false
			elseif self.nChildType == e_type_bubble.ateliertb then --工坊领取材料
				self.pImg:setPositionY(48 + 8*0.5)
				--缩放效果
				-- self:showQiPaoRRsTx()
				--黄色光圈
				self:playYellowRing(2, sIcon)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()				
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
				bIsPressedColor = false
			elseif	self.nChildType == e_type_bubble.herotravel then
				self:removeYellowRing()
				self.pImg:setCurrentImage("#v2_fonts_wjyl.png") 
				self.pImg:setScale(0.78)
				self.pImg:setPositionY(48 + 8*0.85)

				local tTravelData=Player:getHeroTravelData():getHeroTravelList()
				local nNum=Player:getHeroTravelData():getTravelingNum()
				
				for k,v in pairs(tTravelData) do
					if v.nCd == 0 or Player:getHeroTravelData():getTraveLeftTime(v.nQueueId) ==0 then
						local tDbData=getHeroTravelData(v.nTaskId)
						if tDbData then
							local tReward=getGoodsByTidFromDB(tDbData.tDropItem.k)
							if tReward then
								self:playYellowRing(2, tReward.sIcon)
								--展示摇摆类气泡效果
								-- self:showQiPaoRstTx()								
								self.pLbText:setVisible(false)
								break
							end
						end

					end
				end
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.tsfactivate then --统帅府御兵术激活
				local bActivate, sIcon = Player:getBuildData():getBuildById(e_build_ids.tcf):isShowActivate()
				sIcon = "#"..sIcon..".png"
				if bActivate then
					-- self.pImg:setCurrentImage(sIcon) 
					self.pImg:setPositionY(48 + 8)
					-- self.pImg:setScale(0.5)
					--黄色光圈
					self:playYellowRing(2, sIcon)
					--展示摇摆类气泡效果
					self:showQiPaoRstTx()					
				end
			elseif self.nChildType == e_type_bubble.ybssj then--御兵术升级
				self.pImg:setPositionY(48 + 8)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.jjctz then--竞技场挑战
				self.pImg:setPositionY(48 + 8)
				--播放特效
				self:playYellowRing(2)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			elseif self.nChildType == e_type_bubble.mbfjz then --募兵府建造
				--播放特效
				self:playYellowRing(2)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
			end
		elseif self.nType == 3 then --蓝底
			--设置背景层
			self.pLayItem:setBackgroundImage("#v1_img_zjm_tzqpz.png")
			--文字不显示
			self.pLbText:setVisible(false)
			if self.nChildType == e_type_bubble.mjzs then --民居征收
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#i3.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			elseif self.nChildType == e_type_bubble.ntzs then --农田征收
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#i2.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			elseif self.nChildType == e_type_bubble.mczs then --木场征收
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#i4.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			elseif self.nChildType == e_type_bubble.tkzs then --铁矿征收
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#i5.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			elseif self.nChildType == e_type_bubble.mjjzcj then
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#tz_11008.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			elseif self.nChildType == e_type_bubble.mcjzcj then
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#tz_11009.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")				
			elseif self.nChildType == e_type_bubble.ntjzcj then
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#tz_11010.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")
			elseif self.nChildType == e_type_bubble.tkjzcj then
				--先清除特效
				self:removeYellowRing()
				self.pImg:setCurrentImage("#tz_11011.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()
				--设置背景层(强制显示黄底)
				-- self.pLayItem:setBackgroundImage("#v1_img_zjm_wzqph.png")	
			elseif self.nChildType == e_type_bubble.ybssj then--御兵术升级	
				self:removeYellowRing()
				self.pImg:setCurrentImage("#v1_fonts_shengji.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()						
			elseif self.nChildType == e_type_bubble.jjctz then--竞技场挑战	
				self:removeYellowRing()
				self.pImg:setCurrentImage("#v1_fonts_tiaozhan.png") 
				self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)
				--展示摇摆类气泡效果
				self:showQiPaoRstTx()							
			elseif self.nChildType == e_type_bubble.zzdt then 
                if self.nTxIndex == 1 then
                    self:playYellowRing(2, self.sImgPath)
                end
                local sIconPath = "#" ..  self.sImgPath .. ".png"                 
                self.pImg:setCurrentImage(sIconPath) 
                
                self.pImg:setScale(0.85)
				self.pImg:setPositionY(48 + 8*0.85)	
				self:showQiPaoRstTx()	--展示摇摆类气泡效果			
			end
		end
		self:setIsPressedNeedColor(bIsPressedColor) 
	end
end

-- 析构方法
function BuildBubbleLayer:onBuildBubbleLayerDestroy(  )
	-- body
end

--设置当前数据
function BuildBubbleLayer:setCurData( nType, nChildType, nDlgIndex, nTxIndex, sImgPath)
	-- body
	self.nType = nType
	self.nChildType = nChildType
    self.nDlgIndex = nDlgIndex or 0
    self.nTxIndex = nTxIndex or 0
    self.sImgPath = sImgPath or ""
	if not self.bShowTx then
		self:updateViews()
		self.nRefreshHandler = nil
	else
		self.nRefreshHandler = handler(self, self.updateViews)
	end
	
end

--设置点击事件
function BuildBubbleLayer:setClickedCallBack( _handler )
	-- body
	self._nHandlerClicked = _handler
end

--点击事件
function BuildBubbleLayer:onItemClicked( pView )
	-- body
	if self._nHandlerClicked then		
		self._nHandlerClicked(self.nChildType, self.nDlgIndex, function (  )
			-- body
			if self:isNeedShowBubbleTx() then--点击不变色的话就执行活动加速_点击的反馈效果				
				self:playBubbleClickTx()
			end
		end)
	end

end

function BuildBubbleLayer:playTxByInde(nTxIndex, _nType, _img)
    if nTxIndex == 1 then
        self:playYellowRing()
    elseif nTxIndex == 2 then 
        self:showQiPaoRstTx()
    elseif nTxIndex == 3 then 
        self:showQiPaoRRsTx()
    end
end

--播放黄色光圈
function BuildBubbleLayer:playYellowRing( _nType, _img )
	-- body
	if not self.tAllYellowTx then 
		self.tAllYellowTx = {}
	end
	
	local sNameImg = nil --特效表现的内容图片
	local fScale = 1.0 --图片缩放值
	if self.nChildType == e_type_bubble.sjmf then --升级免费
		sNameImg = "#v1_fonts_mf.png"
		fScale = 1.0
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.tnolyspeed or
	self.nChildType == e_type_bubble.buildspeed or 
	self.nChildType == e_type_bubble.campspeed then --活动加速
		sNameImg = "#v1_fonts_hdjs.png"
		self.pImg:setCurrentImage(sNameImg) 
	elseif self.nChildType == e_type_bubble.mjzs then --民居征收
		sNameImg = "#i3.png"
		self.pImg:setCurrentImage(sNameImg) 
		fScale = 0.85
	elseif self.nChildType == e_type_bubble.ntzs then --农田征收
		sNameImg = "#i2.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg) 
	elseif self.nChildType == e_type_bubble.mczs then --木场征收
		sNameImg = "#i4.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg) 
	elseif self.nChildType == e_type_bubble.tkzs then --铁矿征收
		sNameImg = "#i5.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.mjjzcj then --民居建筑重建
		sNameImg = "#tz_11008.png"
		self.pImg:setCurrentImage(sNameImg) 
		fScale = 0.85
	elseif self.nChildType == e_type_bubble.ntjzcj then --农田建筑重建
		sNameImg = "#tz_11009.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg) 
	elseif self.nChildType == e_type_bubble.mcjzcj then --木场建筑重建
		sNameImg = "#tz_11010.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg) 
	elseif self.nChildType == e_type_bubble.tkjzcj then --铁矿建筑重建
		sNameImg = "#tz_11011.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.tjptb then -- 铁匠铺可领取
		local pEquip = Player:getEquipData():getMakeVo()
		sNameImg = getGoodsByTidFromDB(pEquip.nId).sIcon
		self.pImg:setCurrentImage(sNameImg) 
		self.pImg:setScale(0.6)
	elseif self.nChildType == e_type_bubble.bbmb then  --步兵募兵可领取
		sNameImg = "#v1_img_bubing_s.png"
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.qbmb then  --骑兵募兵可领取
		sNameImg = "#v1_img_qibing_s.png"
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.gbmb then  --弓兵募兵可领取
		sNameImg = "#v1_img_gongbing_s.png"
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.ateliertb then -- 工坊可领取
		local tGoods = Player:getBuildData():getBuildById(e_build_ids.atelier):getFirstFinshQueueItem()
		if tGoods then
			local sIcon = getGoodsByTidFromDB(tGoods.tGs.k).sIcon
			self.pImg:setCurrentImage(sIcon) 
			self.pImg:setScale(0.5)
			sNameImg = sIcon
		end
	elseif self.nChildType == e_type_bubble.kjtb then      -- 科技可领取
		sNameImg = _img
	elseif self.nChildType == e_type_bubble.tjpspeedfree or
		self.nChildType == e_type_bubble.kjyspeedfree then --铁匠铺和科技院可免费加速
		sNameImg = "#v1_fonts_mfjs.png"
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.gatebc then --城门可增加城防军
		sNameImg = "#v1_fonts_bccf.png"
		self.pImg:setCurrentImage(sNameImg)
	elseif self.nChildType == e_type_bubble.herotravel then 		--武将游历可领取
		sNameImg =_img
		self.pImg:setCurrentImage(_img)
		local nScale=55/self.pImg:getHeight()
		self.pImg:setScale(nScale)
	elseif self.nChildType == e_type_bubble.tsfactivate then 		--统帅府有御兵术可激活
		sNameImg =_img
		self.pImg:setCurrentImage(_img)
		local nScale=75/self.pImg:getHeight()
		self.pImg:setScale(nScale)
	elseif self.nChildType == e_type_bubble.ybssj then--御兵术升级	
		sNameImg = "v1_fonts_shengji"
		fScale = 0.85
		self.pImg:setCurrentImage("#v1_fonts_shengji.png") 
	elseif self.nChildType == e_type_bubble.jjctz then--竞技场挑战	
		sNameImg = "v1_fonts_tiaozhan"
		fScale = 0.85
		self.pImg:setCurrentImage("#v1_fonts_tiaozhan.png") 
	elseif self.nChildType == e_type_bubble.xlpmfxl then--免费洗练	
		sNameImg = "v1_fonts_xilian"
		fScale = 0.85
		self.pImg:setCurrentImage("#v1_fonts_xilian.png") 	
    elseif self.nChildType == e_type_bubble.zzdt then--战争大厅	
		sNameImg = _img
		fScale = 0.85
	elseif self.nChildType == e_type_bubble.mbfjz then--募兵府建造	
		sNameImg = "#v2_fonts_gjby.png"
		fScale = 0.85
		self.pImg:setCurrentImage(sNameImg) 
	end

	--判断是否需要创建特效
	if self.sYellowImgName then
		if self.sYellowImgName == sNameImg then --如果播放的正是当前特效，那么直接返回
			return 
		else
			--需要重新加载特效，先清除特效
			self:removeYellowRing()
			--重新加载
			self:playYellowRing(_nType)
			return
		end
	end

	if sNameImg then

		--移除摇摆类气泡效果
		-- self:removeQiPaoRstTx()
		--移除缩放气泡效果
		self:removeQiPaoRRsTx()
		--图片名字赋值
		self.sYellowImgName = sNameImg 

		--黄色光圈特效
		self.tAllYellowTx = showYellowRing(self.pLayItem, _nType, sNameImg,fScale)
		
		--添加例子效果
		self:showQiPaoParitcle()
	end
end

--移除黄色光圈
function BuildBubbleLayer:removeYellowRing(  )
	-- body
	if self.tAllYellowTx and table.nums(self.tAllYellowTx) > 0 then
		local nSize = table.nums(self.tAllYellowTx)
		for i = nSize, 1, -1 do
			self.tAllYellowTx[i]:removeSelf()
			self.tAllYellowTx[i] = nil
		end
	end
	self.tAllYellowTx = nil
	self.sYellowImgName = nil
	--移除粒子效果
	self:removeQiPaoParitcle()
end

--添加粒子效果
function BuildBubbleLayer:showQiPaoParitcle(  )
	-- body
	-- if not self.pParitcle then
	-- 	self.pParitcle = createParitcle("tx/other/lizi_qipao_01.plist")
	-- 	self.pParitcle:setPosition(self.pLayItem:getWidth() / 2 ,self.pLayItem:getHeight() / 2)
	-- 	self.pLayItem:addView(self.pParitcle,80)
	-- 	self.pParitcle:setScale(1.05)
	-- 	centerInView(self.pLayItem,self.pParitcle)
	-- end
end

--移除粒子效果
function BuildBubbleLayer:removeQiPaoParitcle(  )
	-- body
	-- if self.pParitcle then
	-- 	self.pParitcle:removeSelf()
	-- 	self.pParitcle = nil
	-- end
end

--展示摇摆类气泡效果
function BuildBubbleLayer:showQiPaoRstTx(  )
	-- body
	--默认偏移角度
	self.pLayItem:setRotation(-1.5)
	--左右摇摆效果
	showRotateQiPao(self.pLayItem)
	--添加例子效果
	self:showQiPaoParitcle()
end

--移除摇摆类气泡效果
function BuildBubbleLayer:removeQiPaoRstTx(  )
	-- body
	--停止所有的动作
	self.pLayItem:stopAllActions()
	--恢复默认角度
	self.pLayItem:setRotation(0)
	--移除粒子效果
	self:removeQiPaoParitcle()
end

--展示缩放类气泡效果
function BuildBubbleLayer:showQiPaoRRsTx(  )
	-- body
	--默认缩放值
	self.pLayItem:setScale(1)
	--缩放效果
	showScaleQiPao(self.pLayItem)
	--添加例子效果
	-- self:showQiPaoParitcle()
end

--移除缩放类气泡效果
function BuildBubbleLayer:removeQiPaoRRsTx(  )
	-- body
	--停止所有的动作
	self.pLayItem:stopAllActions()
	--恢复默认缩放值
	self.pLayItem:setScale(1)
	--移除粒子效果
	-- self:removeQiPaoParitcle()
end

--隐藏
function BuildBubbleLayer:hideBubbleSelf( _func )
	-- body
	local hide = function ( ... )
		-- body
		--隐藏冒泡
		self:setVisible(false)
		--如果存在黄色光圈，移除
		self:removeYellowRing()
		--移除左右摇摆效果
		self:removeQiPaoRstTx()
		--移除缩放效果
		self:removeQiPaoRRsTx()
		if _func then
			_func()
		end
	end
	if not self.bShowTx then
		hide()
		self.nHideHandler = nil
	else
		self.nHideHandler = hide
	end

end

--执行气泡点击效果
function BuildBubbleLayer:playBubbleClickTx( )
	-- body
	if self.bShowTx then
		return
	end
	self.bShowTx = true
	for i = 1, 2 do
		local pArm = MArmatureUtils:createMArmature(
			tNormalCusArmDatas["53_" .. i], 
			self.pLayItem, 
			100, 
			cc.p(self.pLayItem:getWidth()/2, self.pLayItem:getHeight()/2),
		    function ( _pArm )
		    	if i == 1 then		    				    	
		    		if self.pBCTLayer then
		    			self.pBCTLayer:removeSelf()
		    			self.pBCTLayer = nil
		    		end
		    		if self.nHideHandler then
		    			self.nHideHandler()
		    		end
		    		if self.nRefreshHandler then
		    			self.nRefreshHandler()
		    		end	
		    		self.bShowTx = false	    		
		    	end		    	
		    	_pArm:removeSelf()
		    	_pArm = nil
		    end, Scene_arm_type.base)		
		if pArm then
			pArm:play(1)
		end
	end
	--点击特效层
	if not self.pBCTLayer then
		self.pBCTLayer = MUI.MLayer.new()
		self.pBCTLayer:setContentSize(self.pLayItem:getContentSize())
		self.pLayItem:addView(self.pBCTLayer, 101)
		self.pBCTLayer:setViewTouched(false)
		self.pBCTLayer:setAnchorPoint(cc.p(0.5, 0.5))		
		
	end
	self.pBCTLayer:removeAllChildren()
	local pBgImg = MUI.MImage.new("#v1_img_zjm_tzqpz.png")
	pBgImg:setPosition(self.pBCTLayer:getWidth()/2, self.pBCTLayer:getHeight()/2)
	self.pBCTLayer:addView(pBgImg)	
	showBubbleImgAction(pBgImg)
	local pImg = self.pImg:createCloneInstance_()
	pImg:setScale(self.pImg:getScale())
	pImg:setPosition(self.pImg:getPositionX(), self.pImg:getPositionY())
	self.pBCTLayer:addView(pImg, 10)
	showBubbleImgAction(pImg)
	--
	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["54"], 
		self.pLayItem, 
		99, 
		cc.p(self.pLayItem:getWidth()/2, self.pLayItem:getHeight()/2),
	    function ( _pArm )	  	    
	    	_pArm:removeSelf()
	    	_pArm = nil
	    end, Scene_arm_type.base)	
	if pArm then
		pArm:play(1)
	end
end

function BuildBubbleLayer:isNeedShowBubbleTx( )
	-- body
	return not self:getIsPressedNeedColor()
end
--在判定执行点击响应期间，屏蔽到重复的点击响应
function BuildBubbleLayer:isCanDoItemClick( )
	-- body
	return not self.bShowTx and self:isVisible()
end

return BuildBubbleLayer