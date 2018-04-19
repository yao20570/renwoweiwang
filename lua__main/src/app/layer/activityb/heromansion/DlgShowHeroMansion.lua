-- author: liangzhaowei
-- Date: 2017-08-11 14:57:03
-- Description: 登坛拜将活动展示英雄界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemBuyHeroIcon = require("app.layer.buyhero.ItemBuyHeroIcon")
local IconGoods = require("app.common.iconview.IconGoods")
local StarAttrLayer = require("app.layer.hero.StarAttrLayer")

local DlgShowHeroMansion = class("DlgShowHeroMansion", function()
	return DlgBase.new(e_dlg_index.showheromansion)
end)

--_tData 获得物品, _nhandler 关闭窗口之前的方法
function DlgShowHeroMansion:ctor(_tData, _nhandler)
	-- body
	self:myInit()


	self.pData =  _tData or {}
	self.nBeforCloseHandler = _nhandler 
	self:hideTopTitle()
	parseView("dlg_hero_mansion_get", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("DlgShowHeroMansion",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgShowHeroMansion:myInit()
	-- body
	self.pData = nil --获得物品数据
	self.nPrice = 0 --继续购买的价格
	self.pLHandler = nil -- 左边按钮回调
	self.tGoodIcon = {} -- 获得物品 (单个)
	self.nShowNums = 0--需要展示的物品个数
	self.pHeroImg = nil --英雄形象图片
	self.nTxWjzs = 0 --特效重复出现的次数
	self.tHeroData = nil --英雄数据
	self.bShowTips = false --是否已经显示文本提示
	self.nShowContinue = false

	--特殊数据
	self.nRecommonNum = 0 --处理推荐信数量
end

--解析布局回调事件
function DlgShowHeroMansion:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层


	self:setupViews()
	self:onResume()


end

--初始化控件
function DlgShowHeroMansion:setupViews( )
	--ly
	self.pLyShowCn     			= 		self.pView:findViewByName("ly_show_cn")
	self.pLyShowHero     		= 		self.pView:findViewByName("ly_show_hero")
	self.pLyDown     			= 		self.pView:findViewByName("ly_down_btn")
	self.pLyShare     			= 		self.pView:findViewByName("ly_share")
	self.pLyInfo     			= 		self.pView:findViewByName("ly_info")
	self.pLyTuiYan    			= 		self.pView:findViewByName("ly_tuiyan")
	self.pLyHeroInfo   			= 		self.pView:findViewByName("ly_hero_info")
	self.pLyShowTx   			= 		self.pView:findViewByName("ly_show_tx")--用于显示上层特效
	self.pLyShowTx:setZOrder(11)

	self.pLyHeroInfo:setZOrder(10)

	self.pLbHeroTalent			= 		self.pView:findViewByName("lb_hero_talent")   	 --资质1
	setTextCCColor(self.pLbHeroTalent,_cc.blue)
	self.pLbHeroTalentAdd		= 		self.pView:findViewByName("lb_hero_talent_add")  --资质2
	setTextCCColor(self.pLbHeroTalentAdd,_cc.green)
	
	self.pLbHeroQuality			=	    self.pView:findViewByName("lb_hero_quality")  --品质

	self.pLbHeroTips1			= 		self.pView:findViewByName("lb_hero_tips_1")
	self.pLbHeroTips1:setString(getConvertedStr(5,10020))
	self.pLbHeroTips2			= 		self.pView:findViewByName("lb_hero_tips_2")
	self.pLbHeroTips2:setString(getConvertedStr(1,10331))


	self.pLbQualityTips			= 		self.pView:findViewByName("lb_quality_tips")--提示语
	local sStr = getTextColorByConfigure(getTipsByIndex(20107))
	self.pLbQualityTips:setString(sStr)

	self.pLbQualityTips:setVisible(false)
	self.pLyHeroInfo:setVisible(false)--默认隐藏



	self.pLyHeroInfo:setViewTouched(true)
	self.pLyHeroInfo:onMViewClicked(function ()
	end)
	self.pLyHeroInfo:setIsPressedNeedScale(false)
	self.pLyHeroInfo:setIsPressedNeedColor(false)

	

	self.pLyShare:setViewTouched(true)
    self.pLyShare:onMViewClicked(handler(self,self.onShareClick))

	self.pLyInfo:setViewTouched(true)
    self.pLyInfo:onMViewClicked(handler(self,self.onInfoClick))



	self.pLyTuiYan:setVisible(false)

	--self.pLyDown    			= 		self.pView:findViewByName("ly_down_btn")
	self.pLyContent    			= 		self.pView:findViewByName("ly_cn")
	--self.pLyContent:setScaleY(0)
	self.pLyContent:setVisible(true)

	--img
	self.pImgGxhd     			= 		self.pView:findViewByName("img_gxhd")
	self.pImgGxhd:setVisible(false)
	self.pImgGxhdBg 			= 		self.pView:findViewByName("Image_4")
	self.pImgGxhdBg:setVisible(false)
	self.pImgHeroType    			= 		self.pView:findViewByName("img_hero_type")


	self.pLyBtnL     			= 		self.pView:findViewByName("ly_btn_l")
	self.pLyBtnR     			= 		self.pView:findViewByName("ly_btn_r")
	self.pLyBtnM     			= 		self.pView:findViewByName("ly_btn_m")
	self.pLyBtnRX				= 		self.pLyBtnR:getPositionX()

	self.pLbHeroNe    			= 		self.pView:findViewByName("lb_hero_ne")--英雄名字
	self.pLbHeroInfo   			= 		self.pView:findViewByName("lb_hero_info")--英雄信息
	self.pLbHeroBot 			= 		self.pView:findViewByName("ly_down")
	self.pStarLayer = StarAttrLayer.new(0, 1)
	self.pStarLayer:setStartWidth(40)
	self.pLbHeroBot:addView(self.pStarLayer)



	self.pBtnL = getCommonButtonOfContainer(self.pLyBtnL, TypeCommonBtn.L_YELLOW, getConvertedStr(5, 10278))
	self.pBtnL:onCommonBtnClicked(handler(self, self.onBtnLClicked))
	self.pBtnR = getCommonButtonOfContainer(self.pLyBtnR, TypeCommonBtn.L_BLUE, getConvertedStr(5, 10174))
	self.pBtnR:onCommonBtnClicked(handler(self, self.onBtnRClicked))
	--新手引导确定
	Player:getNewGuideMgr():setNewGuideFinger(self.pBtnR, e_guide_finer.show_hero_btn)


	self:showAction()


end

--显示动作
function DlgShowHeroMansion:showAction()
	-- body
	self.pLyTuiYan:setBackgroundImage("ui/v1_bg_gxhdxsa_x_02.jpg")
	self.pLyTuiYan:setVisible(true)
	if self.pLyContent then
		-- --缩放
		-- local actionScaleTo1 = cc.ScaleTo:create(0.1, 1,1.1)
		-- --缩放
		-- local actionScaleTo2 = cc.ScaleTo:create(0.1, 1,0.9)
		-- --缩放
		-- local actionScaleTo3 = cc.ScaleTo:create(0.1, 1,1)	
		--回调
		local fCallback = cc.CallFunc:create(function (  )		
			if self.pImgGxhdBg then		
				local fCallbackGxhd = cc.CallFunc:create(function (  )	
					self:initShowItem()		
					local pImg1  = MUI.MImage.new("#v1_bg_gxhdxsa_x_01.png")
					pImg1:setScale(1.08)
					pImg1:setOpacity(255*0.8)
					pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
					pImg1:setPosition(self.pImgGxhdBg:getPositionX(), self.pImgGxhdBg:getPositionY())
					self.pImgGxhdBg:getParent():addView(pImg1)	
					local action1_1 = cc.ScaleTo:create(0.6, 1.17)
					local action1_2 = cc.FadeTo:create(0.6, 0)						       
			        pImg1:runAction(cc.Sequence:create(cc.Spawn:create(action1_1,action1_2)))

					local pImg2  = MUI.MImage.new("#v1_bg_gxhdxsa_x_01.png")
					pImg2:setOpacity(255*0.5)
					pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
					pImg2:setPosition(self.pImgGxhdBg:getPositionX(), self.pImgGxhdBg:getPositionY())
					self.pImgGxhdBg:getParent():addView(pImg2)	
					local action2_1 = cc.FadeTo:create(1.4, 0)						       
			        pImg2:runAction(action2_1)		        			        

				end)	
				
				self.pImgGxhdBg:setOpacity(255*0.06)
				self.pImgGxhdBg:setScale(0.37)				
				self.pImgGxhdBg:setVisible(true)
				local action1_1 = cc.ScaleTo:create(0.25, 1)
				local action1_2 = cc.FadeTo:create(0.25, 255)
				local actions1 = cc.Spawn:create(action1_1,action1_2)
				--获得图片
				self.pImgGxhdBg:runAction(cc.Sequence:create(actions1,fCallbackGxhd))

						
			end
			if self.pImgGxhd then				
				self.pImgGxhd:setScale(3)
				self.pImgGxhd:setOpacity(255*0.2)
				self.pImgGxhd:setPosition(self.pImgGxhd:getPositionX(), self.pImgGxhd:getPositionY())						
				local action3_1 = cc.ScaleTo:create(0.2, 1)
				local action3_2 = cc.FadeTo:create(0.2, 255)						       
		        self.pImgGxhd:runAction(cc.Sequence:create(cc.DelayTime:create(0.08), 
		        	cc.CallFunc:create(function ( ... )
		        	-- body
		        	self.pImgGxhd:setVisible(true)	
		        end),cc.Spawn:create(action3_1,action3_2)))

				local pImg4  = MUI.MImage.new("#v1_bg_gxhdxsa_01.png")
				pImg4:setOpacity(255)
				pImg4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
				pImg4:setPosition(self.pImgGxhd:getPositionX(), self.pImgGxhd:getPositionY())
				pImg4:setVisible(false)
				self.pImgGxhd:getParent():addView(pImg4)	
				local action4_1 = cc.FadeTo:create(0.33, 0)						       
		        pImg4:runAction(cc.Sequence:create(cc.DelayTime:create(0.25)
		        	,cc.CallFunc:create(function ( ... )
		        		-- body
		        		pImg4:setVisible(true)
		        	end)
		        	,action4_1))	
		    end				
		end)
		self.pLyContent:setVisible(true)
		self.pLyContent:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), fCallback))
	end

end


--显示特效
function DlgShowHeroMansion:showTx()

	local nArmTag = 89754
	local sName = createAnimationBackName("tx/exportjson/", "sg_ckp_8gz_001")
    local pArm = ccs.Armature:create(sName)
    --替换骨骼
    for i = 1, 11 do
    	local sBoneName = "thgc"
    	if i < 10 then
    		sBoneName = sBoneName .. "0" .. i
    	else
    		sBoneName = sBoneName .. i
    	end
	    changeBoneWithPngAndScale(pArm,sBoneName,"ui/sg_ckp_8gz_tx_06.png",true) 
    end
    pArm:setPosition(320,568)
    self:addChild(pArm,10,nArmTag)
    pArm:getAnimation():play("Animation1", 1)


    pArm:getAnimation():setMovementEventCallFunc(function ( arm, eventType, movmentID )
		if (eventType == MovementEventType.COMPLETE) then
			local pLayer = self:getChildByTag(nArmTag)
			if pLayer then
				pLayer:removeFromParent(true)
			end
			self:setupViews()
			self:onResume()
		end
	end)

end


--分享按钮回调
function DlgShowHeroMansion:onShareClick(pView)
	if self.tHeroData and self.tHeroData.nId then
		openShare(pView, e_share_id.hero, {"c^g_"..self.tHeroData.nId,self.tHeroData.nLv}, self.tHeroData.nId)
	end
end

--属性按钮回调
function DlgShowHeroMansion:onInfoClick(pView)
	if self.tHeroData then
		local tObject = {}
		tObject.nType = e_dlg_index.heroinfo --dlg类型
		tObject.tData = self.tHeroData
		sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--获取icon位置
function DlgShowHeroMansion:getItemPos(_nPos)
	-- body
	local nMaxIndex = table.nums(self.tShowData)
	local pos = cc.p(0,0)
	if nMaxIndex >3 then
	
		if _nPos > 0  and _nPos< 17 then
			local nY = 4 - math.floor((_nPos+3)/4)  +1
			pos.y = 40*nY + (nY-1)*108

			local nX = _nPos%4
			if nX == 0 then
				nX = 4
			end

			-- if nY == 1 then
			-- 	nX = nX +1
			-- end

			pos.x = 37*nX + (nX-1)*108 

		end
	else

		pos.y = self.pLyShowCn:getPositionY() + self.pLyShowCn:getHeight()/2
		if nMaxIndex == 3 then
			pos.x = 118 + (_nPos -1) * (108 +40)
		elseif nMaxIndex == 2 then
			pos.x = 172 + (_nPos -1) * (108 +80)
		end

	end

	return pos
end


--根据获得物品创建物品显示
function DlgShowHeroMansion:initShowItem()
	-- body
	self.tShowData = {}

	for k,v in pairs(self.pData) do
		for x,y in pairs(v.d) do
			table.insert(self.tShowData,y)
		end
	end


	self.tShowData =  getRewardItemsFromSever(self.tShowData)


	if self.tShowData then
		local bFindHero	 = false --是否获得英雄
		for k,v in pairs(self.tShowData) do
			if v.nId and  (v.nId >= 200001 and v.nId <= 299999)  then
				bFindHero = true
				break
			end
		end

		if table.nums(self.tShowData) == 1 then
			local pIconData = self.tShowData
			if pIconData[1] then
				local pIcon = getIconGoodsByType(self.pLyShowCn, TypeIconGoods.HADMORE, type_icongoods_show.itemnum,
			      pIconData[1], TypeIconGoodsSize.L)
				pIcon:setAnchorPoint(cc.p(0.5,0.5))
				centerInView(self.pLyShowCn,pIcon)
				self.nShowNums = table.nums(self.tShowData)
				self:showSingleItemTx(pIcon,pIconData[1])

			end
		else
			self.nShowNums = table.nums(self.tShowData)
			self:showIcon()
		end

	end

end

--显示icon
function DlgShowHeroMansion:showIcon()
	local pIconData = self.tShowData
	local nMaxIndex = table.nums(self.tShowData)
	local nIndex = nMaxIndex - self.nShowNums+1
	if pIconData[nIndex] then
        local pIcon = IconGoods.new(TypeIconGoods.HADMORE,type_icongoods_show.itemnum)            
        self.pLyShowCn:addView(pIcon)
        --设置值
        pIcon:setCurData(pIconData[nIndex])
		pIcon:setAnchorPoint(cc.p(0.5,0.5))
		pIcon:setPosition(self:getItemPos(nIndex).x, self:getItemPos(nIndex).y)
		self:showSingleItemTx(pIcon,pIconData[nIndex])
	end
end


--显示单个icon特效 _pItem (icon) pData(数据)
function DlgShowHeroMansion:showSingleItemTx(_pItem,_pData)

	if not _pItem then
		return
	end

	if not _pData  then
		return
	end

	local posX = _pItem:getPositionX()
	local posY = _pItem:getPositionY()
	local nMaxIndex = table.nums(self.tShowData)
	local nIndex = nMaxIndex - self.nShowNums+1

	self.nShowNums = self.nShowNums -1

	
	if _pItem then


		--初始状态
		_pItem:setOpacity(70)
		_pItem:setScale(-1)
		_pItem:setScaleY(1.3)

		local pScaleTo1 = cc.ScaleTo:create(0.04, -1.5,2)
		local pFadeTo1 = cc.FadeTo:create(0.04, 255*0.42)
		local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1)


		local pScaleTo2 = cc.ScaleTo:create(0.17, -0.04,1.97)
		local pFadeTo2 = cc.FadeTo:create(0.17, 255*0.88)
		local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)


		local pScaleTo3 = cc.ScaleTo:create(0.04, 0.3,0.8)
		local pFadeTo3 = cc.FadeTo:create(0.04, 255*1)
		local action3 = cc.Spawn:create(pScaleTo3,pFadeTo3)

		local pScaleTo4 = cc.ScaleTo:create(0.05, 0.7,0.7)

		local pScaleTo5 = cc.ScaleTo:create(0.12, 1.03,1.03)

		local pScaleTo6 = cc.ScaleTo:create(0.08, 1,1)

		_pItem:ignoreAnchorPointForPosition(true)

		Sounds.playEffect(Sounds.Effect.get)
		_pItem:runAction(cc.Sequence:create(action1,action2,fCallback,action3,pScaleTo4,pScaleTo5,pScaleTo6))
		
	end

	local nFlewY = 20


	local pImg1  = MUI.MImage.new("#sg_dc_tbiao_sdtx_001.png")
	if pImg1 then

		self.pLyShowCn:addView(pImg1)

		pImg1:setAnchorPoint(cc.p(0.5,0.5))
	    pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg1:setPosition(posX+_pItem:getWidth()/2, posY+_pItem:getHeight()/2+nFlewY)

		--初始状态
		pImg1:setScaleY(1.3)
		pImg1:setScaleX(-1)

		local pScaleTo1 = cc.ScaleTo:create(0.04, -1.5,2)


		local pScaleTo2 = cc.ScaleTo:create(0.17, -0.04,1.97)

		local pScaleTo3 = cc.ScaleTo:create(0.04, 0.3,0.8)
		local pFadeTo3 = cc.FadeTo:create(0.04, 255*0.67)
		local action3 = cc.Spawn:create(pScaleTo3,pFadeTo3)

		local pScaleTo4 = cc.ScaleTo:create(0.05, 0.7,0.7)
		local pFadeTo4 = cc.FadeTo:create(0.05, 255*0.33)
		local action4 = cc.Spawn:create(pScaleTo4,pFadeTo4)

		local pScaleTo5 = cc.ScaleTo:create(0.12, 1.03,1.03)
		local pFadeTo5 = cc.FadeTo:create(0.12, 0)
		local action5 = cc.Spawn:create(pScaleTo5,pFadeTo5)

		local pScaleTo6 = cc.ScaleTo:create(0.08, 1,1)

	    pImg1:runAction(cc.Sequence:create(pScaleTo1,pScaleTo2,action3,action4,action5,pScaleTo6))

	end



	local pImg2  = MUI.MImage.new("#sg_dc_tbiao_sdtx_003.png")
	if pImg2 then

		self.pLyShowCn:addView(pImg2)

		pImg2:setAnchorPoint(cc.p(0.5,0.5))
	    pImg2:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg2:setPosition(posX+_pItem:getWidth()/2, posY+_pItem:getHeight()/2+nFlewY)

		--初始状态
		pImg2:setOpacity(0)
		pImg2:setScale(0.23)

		local pDelay = cc.DelayTime:create(0.3)


		local fCallback = cc.CallFunc:create(function (  )
			--显示英雄
			if bJudgeHeroData(_pData)  then --是否为英雄
				--获取本地英雄数据
				_pData = Player:getHeroInfo():getHero(_pData.nKey)
				self:showHero(_pItem,_pData)
			elseif bJudgeRecommend(_pData) then --是否为推荐信
				local pRecommendData = {}
				self.nRecommonNum = self.nRecommonNum + 1
				pRecommendData.nRecommonNum = self.nRecommonNum
				pRecommendData.tCallback = function()
					if self and self.showIcon then
						self:showIcon()
					end
				end
				showItemInfoDlg(100177, 2, pRecommendData)
			elseif self.pData[nIndex].activityId == e_id_activity.snatchturn then --夺宝转盘合成
				local id =self.pData[nIndex].showId
				local pRecommendData = {}
				pRecommendData.tCallback = function()
					if self and self.showIcon then
						self:showIcon()
					end
				end
				local pDlg = showItemInfoDlg(tonumber(id), 2, pRecommendData)
				if pDlg and pDlg.setTips and self.pData[nIndex].str then
					pDlg:setTips(self.pData[nIndex].str)
				end
				self.bTipsDialog = false
			else
				self:showIcon()
			end


			local pImg4  = MUI.MImage.new("#sg_dc_tbiao_sdtx_002.png")
			self.pLyShowCn:addView(pImg4)
			pImg4:setOpacity(0)
			pImg4:setAnchorPoint(cc.p(0.5,0.5))
		    pImg4:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
			pImg4:setPosition(posX+_pItem:getWidth()/2, posY+_pItem:getHeight()/2+nFlewY)


			local pFadeTo1 = cc.FadeTo:create(0.17, 255*0.6)
			local pFadeTo2 = cc.FadeTo:create(0.63, 0)

			pImg4:runAction(cc.Sequence:create(pFadeTo1,pFadeTo2))

		end)

		local pFadeTo1 = cc.FadeTo:create(0.01, 255*0.3)

		local pScaleTo2 = cc.ScaleTo:create(0.17, 1)
		local pFadeTo2 = cc.FadeTo:create(0.17, 255*0.2)
		local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)

		local pScaleTo3 = cc.ScaleTo:create(0.29, 1.25)
		local pFadeTo3 = cc.FadeTo:create(0.29, 0)
		local action3 = cc.Spawn:create(pScaleTo3,pFadeTo3)

	    pImg2:runAction(cc.Sequence:create(pDelay,fCallback,pFadeTo1,action2,action3))
	end



	local pImg3  = MUI.MImage.new("#sg_dc_tbiao_sdtx_003.png")
	if pImg3 then

		self.pLyShowCn:addView(pImg3)

		pImg3:setAnchorPoint(cc.p(0.5,0.5))
	    pImg3:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg3:setPosition(posX+_pItem:getWidth()/2, posY+_pItem:getHeight()/2+nFlewY)

		--初始状态
		pImg3:setOpacity(0)
		pImg3:setScale(0.23)

		local pDelay = cc.DelayTime:create(0.35)

		local pFadeTo1 = cc.FadeTo:create(0.01, 255*0.8)

		local pScaleTo2 = cc.ScaleTo:create(0.3, 1)
		local pFadeTo2 = cc.FadeTo:create(0.3, 255*0.5)
		local action2 = cc.Spawn:create(pScaleTo2,pFadeTo2)

		local pScaleTo3 = cc.ScaleTo:create(0.46, 1.35)
		local pFadeTo3 = cc.FadeTo:create(0.46, 0)
		local action3 = cc.Spawn:create(pScaleTo3,pFadeTo3)



		local fCallback = cc.CallFunc:create(function (  )
			if self.nShowNums<=0 then

				if not self.bShowTips then
					self.bShowTips = true
				
					if not self.pLyHeroInfo:isVisible() then
						self.pLyDown:setVisible(true)
					end
				end

				--播放飘物品
				if self.tEndPopGoods then
					local tGoodsList = self.tEndPopGoods
					
					self:performWithDelay(function ()
			 			showGetAllItems(tGoodsList)
			 		end, 1)

					self.tEndPopGoods = nil
				end
			end
		end)


	    pImg3:runAction(cc.Sequence:create(pDelay,pFadeTo1,action2,action3,fCallback))
	end

end

--显示英雄特效 _pItem (icon) _pData 英雄数据
function DlgShowHeroMansion:showHero(_pItem,_pData)
	if not _pItem then
		return
	end

	if not _pData then
		return
	end

	self.tHeroData = _pData--记录英雄数据

	local nFlewY = -233 --偏移位置 这里因为显示物品的区域调整所以这里增加-148的高度调整

	local posX = _pItem:getPositionX()
	local posY = _pItem:getPositionY()


	local pImg1  = MUI.MImage.new("#sg_dc_tbiao_sdtx_002.png")
	if pImg1 then

		self.pLyShowTx:addView(pImg1,100)

		pImg1:setAnchorPoint(cc.p(0.5,0.5))
	    pImg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pImg1:setPosition(posX+_pItem:getWidth()/2, posY+_pItem:getHeight()/2+nFlewY)


		local pScaleTo1 = cc.ScaleTo:create(0.33, 4.75)
		local pMoveto1 = cc.MoveTo:create(0.33, cc.p(self.pLyShowTx:getWidth()/2,self.pLyShowTx:getWidth()/2))
		local action1 = cc.Spawn:create(pScaleTo1,pMoveto1)

		local fCallback = cc.CallFunc:create(function (  )

			self:showHeroInfo(_pData)

		end)


		local pFadeOut = cc.FadeOut:create(0.33)


	    pImg1:runAction(cc.Sequence:create(action1,fCallback,pFadeOut))

	end

	if self.nShowContinue then
		self:hideLBtn(true)
		self.pRHandlerNotClose = true
		self:setRBtnHandler(function()
			self.pLyHeroInfo:setVisible(false)
			self.pLbQualityTips:setVisible(false)
			self:showIcon()
			self:setRBtnHandler(nil)
			self:showLBtn()
		end)
	end

end
--展示英雄信息
function DlgShowHeroMansion:showHeroInfo(_tData)
	-- body
	if not _tData then
		return
	end
	--获得武将音效
	Sounds.playEffect(Sounds.Effect.summon)
	--名字
	if _tData.sName and _tData.nQuality then
		self.pLbHeroNe:setString(_tData.sName)
		setTextCCColor(self.pLbHeroNe, getColorByQuality(_tData.nQuality))
	end

	self.pImgKuang1				=		self.pView:findViewByName("img_kuang1")--框下边
	self.pImgKuang1:setFlippedX(true)
	self.pImgKuang1:setFlippedY(true)
	self.pImgKuang2				=		self.pView:findViewByName("img_kuang2")--框上边


	if _tData.nQuality then
		local path = getHeroKuangByQuality(_tData.nQuality)
		self.pImgKuang1:setCurrentImage(path)
		self.pImgKuang2:setCurrentImage(path)

		self.pLbHeroQuality:setString(getHeroTextByQuality(_tData.nQuality))

		setTextCCColor(self.pLbHeroQuality, getColorByQuality(_tData.nQuality))
		
	end

	if _tData.getBaseTotalTalent then
		self.pLbHeroTalent:setString(_tData:getBaseTotalTalent())
	end
	if _tData.getExTotalTalent then
		local x = self.pLbHeroTalent:getPositionX()
		self.pLbHeroTalentAdd:setPositionX(x + self.pLbHeroTalent:getContentSize().width+5)
		self.pLbHeroTalentAdd:setString("+".._tData:getExTotalTalent())
	end

	--英雄资质
	-- local strInfo = {
	-- 	{text = getConvertedStr(5, 10233),color = _cc.pwhite},
	-- 	{text = _tData:getBaseTotalTalent(),color = _cc.blue},
	-- 	{text = " +".._tData:getExTotalTalent(),color = _cc.green},
	-- }

	-- self.pLbHeroInfo:setString(strInfo)
	setTextCCColor(self.pLbHeroInfo, _cc.pwhite)
	self.pLbHeroInfo:setString(_tData.sAppear, false)	
		 
	if _tData.getHeroKindImg then
		self.pImgHeroType:setCurrentImage(_tData:getHeroKindImg(2))
	 end 

	if _tData.sImg then
		if not self.pHeroImg then

		    self.pHeroImg = creatHeroView(_tData.sImg)
		    self.pHeroImg:setPosition(0, 0)
			self.pLyShowHero:addView( self.pHeroImg, 0)

		    self.pHeroImg1 = creatHeroView(_tData.sImg)
			self.pLyShowHero:addView( self.pHeroImg1, 1)

			self.pHeroTxImg = MUI.MImage.new("ui/sg_dc_tbiao_10ctx_001.png")
			self.pHeroTxImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)			
			self.pHeroTxImg:setScale(2.22*1.08)
			self.pHeroTxImg:setOpacity(255)				
			self.pLyHeroInfo:addView(self.pHeroTxImg, 20)
			centerInView(self.pLyHeroInfo, self.pHeroTxImg)		

		else
			self.pHeroImg:updateHeroView(_tData.sImg)
			self.pHeroImg1:updateHeroView(_tData.sImg)
			self.pHeroTxImg:setScale(2.22*1.08)
			self.pHeroTxImg:setOpacity(255)				
		end

	    self.pHeroImg1:setPosition(self.pHeroImg1:getWidth()/2, self.pHeroImg1:getHeight()/2)
	    self.pHeroImg1:setAnchorPoint(0.5,0.5)
		self.pHeroImg1:setScale(0.963)
		self.pHeroImg1:setOpacity(255)
		local pScaleTo1 = cc.ScaleTo:create(0.6, 1.1)
		local pFadeTo1 = cc.FadeTo:create(0.6, 0)
		local pMoveTo1 = cc.MoveTo:create(0.6, cc.p(self.pHeroImg1:getWidth()/2, self.pHeroImg1:getHeight()/2+15))
		local action1 = cc.Spawn:create(pScaleTo1,pFadeTo1,pMoveTo1)
		
		self.pHeroImg1:runAction(action1)

		local pScaleTo2 = cc.ScaleTo:create(0.16, 2.26*1.08)
		local pFadeTo2 = cc.FadeTo:create(0.16, 255*0.5)

		local pScaleTo3 = cc.ScaleTo:create(1, 2.4*1.08)
		local pFadeTo3 = cc.FadeTo:create(1, 0)

		self.pHeroTxImg:runAction(cc.Sequence:create(cc.Spawn:create(pScaleTo2, pFadeTo2), cc.Spawn:create(pScaleTo3, pFadeTo3)))

		
		self.nTxWjzs = 6
		self:showWjzsTx()
		--todo
	end
	self.pStarLayer:resetStar()
	self.pStarLayer:setPosition(self.pLbHeroNe:getPositionX()+self.pLbHeroNe:getWidth()+40, self.pLbHeroNe:getPositionY() - self.pLbHeroNe:getHeight()/2)
	self.pLyHeroInfo:setVisible(true)
	self.pLbQualityTips:setVisible(true)
	--显示武将星级动画
	doDelayForSomething(self, function ( ... )
		-- body
		self.pStarLayer:updateStarWithAction(_tData.tSoulStar)
		self.pLyDown:setVisible(true)
	end, 0.4)
end

--创建 特效
function DlgShowHeroMansion:showWjzsTx()
	-- body


	--倒序
	local tImgPos = {
		cc.p(167,150),
		cc.p(-40,-58),
		cc.p(-119,76),
		cc.p(-144,-170),
		cc.p(183,-101),
		cc.p(-194,164),
	}

	if not tImgPos[self.nTxWjzs] then
		return
	end

	local pImg =  MUI.MImage.new("ui/wjzs_gx_xx_4_01.png")
	pImg:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	self.pLyShowHero:addView(pImg,12)
	pImg:setPosition(self.pLyShowHero:getWidth()/2+ tImgPos[self.nTxWjzs].x,
	 self.pLyShowHero:getHeight()/2 + tImgPos[self.nTxWjzs].y)
	pImg:setRotation(32)
	pImg:setScaleY(0.02)

	local pScaleTo1 = cc.ScaleTo:create(0.6,1,1)
	local pScaleTo2 = cc.ScaleTo:create(0.8,1,0)
	local pDelay = cc.DelayTime:create(0.5)
	local fCallbackImg = cc.CallFunc:create(function ( )
		pImg:removeFromParent(true) --移除
		pImg = nil

	end)
	local fCallbackCreate = cc.CallFunc:create(function ( )
		self.nTxWjzs = self.nTxWjzs -1
		if self.nTxWjzs ==0 then
			self.nTxWjzs = 6
		end
		self:showWjzsTx()

	end)

	pImg:runAction(cc.Sequence:create(pScaleTo1,fCallbackCreate,pScaleTo2,pDelay,fCallbackImg))
end

-- 没帧回调 _index 下标 _pView 视图
function DlgShowHeroMansion:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		if self.tShowData[_index] then
			pView = ItemBuyHeroIcon.new()
		end
	end

	if _index and self.tShowData[_index] then
		pView:setCurData(self.tShowData[_index])	
	end

	return pView
end

-- 修改控件内容或者是刷新控件数据
function DlgShowHeroMansion:updateViews(  )
	-- body
end

--左边点击按钮
function DlgShowHeroMansion:onBtnLClicked(pView)
	-- body
	if self.pLHandler then
		self:pLHandler()
	end

    local tObject = {}
    tObject.nType = e_dlg_index.dlgherolineup --dlg类型
    sendMsg(ghd_show_dlg_by_type,tObject)

	closeDlgByType(e_dlg_index.showheromansion, false)
	
end

--设置回调
function DlgShowHeroMansion:setHandler(_handler)
	-- body
	if _handler then
		 self.pLHandler  = _handler
	end
end

--设置右按钮回调
function DlgShowHeroMansion:setRBtnHandler( _handler)
	self.pRHandler  = _handler
end

--右边点击按钮
function DlgShowHeroMansion:onBtnRClicked(pView)
	if self.pRHandler then
		self.pRHandler()
		--有这个状态就点击不关闭界面
		if self.pRHandlerNotClose then
			self.pRHandlerNotClose = false
			return
		end 
	end

	--关闭也要处理装备合成弹窗
	if self.bTipsDialog then
		self.bTipsDialog = false
		for i=1, #self.pData do
			if self.pData[i].activityId == e_id_activity.snatchturn then
				local id =self.pData[i].showId
				local pRecommendData = {}

				local pDlg = showItemInfoDlg(tonumber(id), 2, pRecommendData)
				if pDlg and pDlg.setTips and self.pData[i].str then
					pDlg:setTips(self.pData[i].str)
				end
				break
			end
		end
	end

	-- body	
	closeDlgByType(e_dlg_index.showheromansion, false)
	--新手引导
	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.show_hero_btn)
end

--设置左边按钮
function DlgShowHeroMansion:setLBtn( tLBtnData )
	if not tLBtnData then
		return
	end
	self.pBtnL:setButton(tLBtnData.nBtnType, tLBtnData.sBtnStr)
	self.pBtnL:onCommonBtnClicked(tLBtnData.nClickedFunc)
	if tLBtnData.nPrice and tLBtnData.nPrice > 0 then
		local tConTable = {}
		tConTable.img = getCostResImg(e_type_resdata.money)
		--文本
		local tLabel = {
		 {tostring(tLBtnData.nPrice),getC3B(_cc.white)},
		}
		tConTable.tLabel = tLabel
		self.pBtnL:setBtnExText(tConTable)
	end
	self.pBtnL:setBtnEnable(tLBtnData.bIsEnable)

	--消耗的物品id
	if tLBtnData.nCostId then
		local pCostGood = getGoodsByTidFromDB(tLBtnData.nCostId)
		local MImgLabel = require("app.common.button.MImgLabel")
		local pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLyBtnL})
		pImgLabel:setImg(pCostGood.sIcon, 0.4, "right")
		pImgLabel:followPos("center", self.pLyBtnL:getContentSize().width/2, self.pLyBtnL:getContentSize().height+10, 5)

		--数量文字颜色(小于消耗显示红色)
		local sNumColor = getC3B(_cc.white)
		if tLBtnData.nHasCostItemCnt < tLBtnData.nCostNum then
			sNumColor = getC3B(_cc.red)
		end
		local tLabel = {
			{text = getConvertedStr(7, 10296), color = _cc.white},
			{text = tLBtnData.nHasCostItemCnt, color = sNumColor}
		}
		pImgLabel:setString(tLabel)

		self.pBtnL:setBtnEnable(true)

		local sTip = string.format(getConvertedStr(7, 10297), pCostGood.sName)
		local pLbBottomTip = MUI.MLabel.new({text = sTip, size = 20, color = getC3B(_cc.pwhite)})
		self.pLyDown:addView(pLbBottomTip, 10)
		pLbBottomTip:setPosition(self.pLyDown:getWidth()/2, 60)
	end

	if tLBtnData.tConTable then
		self.pBtnL:setBtnExText(tLBtnData.tConTable)
		self.pBtnL:setBtnEnable(true)
	end

end

--设置左边按钮
function DlgShowHeroMansion:setRBtn( tRBtnData )
	if not tRBtnData then
		return
	end
	self.pBtnR:setButton(tRBtnData.nBtnType, tRBtnData.sBtnStr)

	self.pBtnR:setBtnEnable(tRBtnData.bIsEnable)

	if tRBtnData.tConTable then
		self.pBtnR:setBtnExText(tRBtnData.tConTable)
	end

end

--隐藏左边按钮
function DlgShowHeroMansion:hideLBtn( bHideLBtn )
	-- body
	if bHideLBtn then
		self.pBtnL:setBtnVisible(false)
		self.pLyBtnR:setPositionX((self.pLyDown:getWidth() - self.pLyBtnR:getWidth())/2)
	end
end

--显示左边按钮
function DlgShowHeroMansion:showLBtn(  )
	-- body
	self.pBtnL:setBtnVisible(true)
	self.pLyBtnR:setPositionX(self.pLyBtnRX)
end

--显示获得武将动画之后的执行方法
function DlgShowHeroMansion:onBeforCloseHandler(  )
	-- body
	if self.nBeforCloseHandler then
		self.nBeforCloseHandler()
	end
end

-- 析构方法
function DlgShowHeroMansion:onDestroy()
	-- body
	self:onPause()
end

-- 注册消息
function DlgShowHeroMansion:regMsgs( )
	-- body
end

-- 注销消息
function DlgShowHeroMansion:unregMsgs(  )
	-- body
end


--暂停方法
function DlgShowHeroMansion:onPause( )
	-- body
	self:onBeforCloseHandler()
	self:unregMsgs()
	--允许提示弹框
	showNextSequenceFunc(e_show_seq.gethero)
	--寻龙夺宝活动获得目标物品
	if self.tGetTargetGoods then
		local tObject = {}
    	tObject.nType = e_dlg_index.gettargetgoodstip --dlg类型
    	tObject.tData = self.tGetTargetGoods
    	sendMsg(ghd_show_dlg_by_type,tObject)
	end
end

--继续方法
function DlgShowHeroMansion:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

--设置最后飘的东西
--tOb List<Pair<Integer,Long>>
function DlgShowHeroMansion:setEndPopGoods( tOb )
	self.tEndPopGoods = tOb
end

--设置关掉界面后弹窗获得的目标物品
--tOb List<Pair<Integer,Long>>
function DlgShowHeroMansion:setEndTargetGoods( tOb )
	self.tGetTargetGoods = tOb
end

--设置是否需要弹窗属性
function DlgShowHeroMansion:setTipsDialog( bShowTip )
	self.bTipsDialog = bShowTip
end


function DlgShowHeroMansion:setBottomTip(_sStr)
	if not _sStr then
		return
	end

	if not self.pBottomLabel then

		self.pBottomLabel = MUI.MLabel.new({text =_sStr, size = 20})
		local nY=self.pLyBtnL:getPositionY() - 30
		self.pBottomLabel:setPosition(self:getWidth()/2,nY)
		self.pLyDown:addChild(self.pBottomLabel)
	else
		self.pBottomLabel:setString(_sStr)
	end
end

function DlgShowHeroMansion:setRecommonNum(num)
	self.nRecommonNum = num
end

function DlgShowHeroMansion:setShowContinue(_status)
	self.nShowContinue = _status
end

return DlgShowHeroMansion