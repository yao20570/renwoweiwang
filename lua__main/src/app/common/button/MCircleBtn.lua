----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-22 17:45:28
-- Description: 圆形按钮 --主任务，世界点击界面按钮
-----------------------------------------------------
local MCircleBtn = class("MCircleBtn", function()
	local MCommonView = require("app.common.MCommonView")
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	return pView
end)

--_pContainer：存放按钮的父层
--_nType：按钮样式
function MCircleBtn:ctor( _pContainer, _nType )
	-- body
	self:myInit()
	self.pContainer = _pContainer
	self.nType = _nType or self.nType

	parseView("layout_circle_btn", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function MCircleBtn:myInit(  )
	-- body
	self.pContainer 		= nil                      --存放按钮的父层
end


function MCircleBtn:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:setDestroyCallback(handler(self, self.onMCircleBtnDestroy))

	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onViewClicked))
end

--析构方法
function MCircleBtn:onMCircleBtnDestroy(  )
end


--初始化控件
function MCircleBtn:setupViews( )
	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onViewClicked))

	self.pView = self:findViewByName("view")--底框

	self.pTxtName = self:findViewByName("txt_name")--开关底图
	self.pTxtName:enableOutline(cc.c4b(0, 0, 0, 255),2)
	setTextCCColor(self.pTxtName, _cc.lyellow)
	self.pImgBtn = self:findViewByName("img_btn") --圆点

	self.pImgBtnB = self:findViewByName("img_btn_b") --高亮辅助 
	self.pImgBtnB:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)

	self.pImgTx = self:findViewByName("img_tx")
	self.pImgTx:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
end

function MCircleBtn:updateBtnType( nType )
	self.nType = nType
	self:updateViews()
end

--设置回调
function MCircleBtn:onCommonBtnClicked(_handler)
	if _handler then
		self.pHandler = _handler
	end
end

--按钮回调
function MCircleBtn:onViewClicked(pView)


	if self.pHandler then
		self:pHandler()
	end
end

-- 修改控件内容或者是刷新控件数据
function MCircleBtn:updateViews(  )
	local sName = ""
	if self.nType == TypeCirleBtn.CALL then          --召唤
		self.sImgName = "#v1_btn_zhaohuan.png"
		sName = getConvertedStr(3, 10163)
	elseif self.nType == TypeCirleBtn.PROTECT then       --保护
		self.sImgName = "#v1_btn_baohu.png"
		sName = getConvertedStr(3, 10001)
	elseif self.nType == TypeCirleBtn.ENTER then        --进入
		sName = getConvertedStr(3, 10002)
		self.sImgName = "#v1_btn_jinru.png"
	elseif self.nType == TypeCirleBtn.SHARE then     --分享
		sName = getConvertedStr(3, 10003)
		self.sImgName = "#v1_btn_fenxiang.png"
	elseif self.nType == TypeCirleBtn.DETECT then     --帧查
		sName = getConvertedStr(3, 10004)
		self.sImgName = "#v1_btn_zhencha.png"
	elseif self.nType == TypeCirleBtn.CITYWAR then     --城战
		sName = getConvertedStr(3, 10005)
		self.sImgName = "#v1_btn_chengzhan.png"
	elseif self.nType == TypeCirleBtn.COUNTRYWAR then     --国战
		sName = getConvertedStr(3, 10007)
		self.sImgName = "#v1_btn_guozhan2.png"
	elseif self.nType == TypeCirleBtn.MOVECITY then     --迁城
		sName = getConvertedStr(3, 10102)
		self.sImgName = "#v1_btn_qiancheng.png"
	elseif self.nType == TypeCirleBtn.GARRRISON then --驻防
		sName = getConvertedStr(3, 10083)
		self.sImgName = "#v1_btn_zhufang.png"
	elseif self.nType == TypeCirleBtn.CHAT then --私聊
		sName = getConvertedStr(3, 10008)
		self.sImgName = "#v1_btn_siliao.png"
	elseif self.nType == TypeCirleBtn.DETAIL then --详情
		sName = getConvertedStr(3, 10006)
		self.sImgName = "#v1_btn_xiangqing.png"
	elseif self.nType == TypeCirleBtn.WOLRD then --世界
		sName = getConvertedStr(3, 10011)
		self.sImgName = "#v1_btn_shijie.png"
	elseif self.nType == TypeCirleBtn.BOSS then    --Boss召唤
		self.sImgName = "#v1_btn_zhaohuan.png"
		sName = getConvertedStr(3, 10497)
	elseif self.nType == TypeCirleBtn.BOSSWAR then    --Boss讨伐
		self.sImgName = "#v1_btn_taofa.png"
		sName = getConvertedStr(3, 10498)
	elseif self.nType == TypeCirleBtn.LEVY then --系统城池征收
		self.sImgName = "#v1_img_zjm_hd.png"
		sName = getConvertedStr(3, 10157)
	elseif self.nType == TypeCirleBtn.ELECT then --系统城池竞选
		self.sImgName = "#v1_btn_czdl.png"
		sName = getConvertedStr(3, 10700)
	elseif self.nType == TypeCirleBtn.JOINWAR then     --参战
		sName = getConvertedStr(3, 10701)
		self.sImgName = "#v1_btn_chengzhan.png"
	elseif self.nType == TypeCirleBtn.FILLCDEF then --补充城防
		sName = getConvertedStr(3, 10704)
		self.sImgName = "#v1_img_bufang.png"
	elseif self.nType == TypeCirleBtn.RANK then --榜单（限时BOSS）
		sName = getConvertedStr(3, 10801)
		self.sImgName = "#v2_btn_bangdan.png"
	elseif self.nType == TypeCirleBtn.DISPATCH then --派遣（限时BOSS）
		sName = getConvertedStr(3, 10802)
		self.sImgName = "#v2_btn_paiqian.png"
	elseif self.nType == TypeCirleBtn.FIVEHIT then --五连击（限时BOSS）
		sName = getConvertedStr(3, 10803)
		self.sImgName = "#v2_btn_wulianji.png"
	elseif self.nType == TypeCirleBtn.ATTACK then --攻击（限时BOSS）
		sName = getConvertedStr(3, 10005)
		self.sImgName = "#v1_ing_zjm_jinru.png"
	elseif self.nType == TypeCirleBtn.BATTLEFIELD then --战场（决战阿房宫）
		sName = getConvertedStr(3, 10900)
		self.sImgName = "#v2_btn_zhanchang.png"
	elseif self.nType == TypeCirleBtn.TOGETHER then --集结（决战阿房宫）
		sName = getConvertedStr(3, 10851)
		self.sImgName = "#v2_img_qiuzhu.png"
	end

	--文本
	self.pTxtName:setString(sName)
	--设置按钮图片
	self.pImgBtn:setCurrentImage(self.sImgName)
	self.pImgBtnB:setCurrentImage(self.sImgName)
end

-- 按钮特效
function MCircleBtn:showTx()
	self.pView:setOpacity(0)
	self.pView:setScale(0.5)
	self.pImgBtnB:setOpacity(0)
	self.pImgBtnB:setScale(0.5)
	self.pImgTx:setOpacity(0)


	local tAction_1 = cc.Spawn:create(cc.ScaleTo:create(0.14, 1.05), cc.FadeIn:create(0.14))
	local tAction_2 = cc.ScaleTo:create(0.1, 0.98)
	local tAction_3 = cc.ScaleTo:create(0.06, 1)
	self.pView:runAction(cc.Sequence:create(tAction_1, tAction_2, tAction_3))

	local tAction_4 = cc.Spawn:create(cc.ScaleTo:create(0.14, 1.05), cc.FadeTo:create(0.14,255*0.3))
	local tAction_5 = cc.Spawn:create(cc.ScaleTo:create(0.1, 0.98), cc.FadeTo:create(0.14,255*0.23))
	local tAction_6 = cc.Spawn:create(cc.ScaleTo:create(0.06, 1), cc.FadeTo:create(0.14,255*0.18))
	local tAction_7 = cc.FadeOut:create(0.28)
	self.pImgBtnB:runAction(cc.Sequence:create(tAction_4, tAction_5, tAction_6, tAction_7))

	local tAction_8 = cc.FadeIn:create(0.14)
	local tAction_9 = cc.FadeOut:create(0.29)
 	self.pImgTx:runAction(cc.Sequence:create(tAction_8, tAction_9))


end

-- 播放倒计时遮罩及特效
function MCircleBtn:showCdBlack( nCd, nCdMax, nCBFunc )
	if self.pRroCdBlack then
		self.pRroCdBlack:setVisible(true)
	else
		local pImgJdt = display.newSprite("ui/big_img/rwww_boss_lenq_hsmb_001.png")
	    local pRroCdBlack = cc.ProgressTimer:create(pImgJdt)  
	    self.pRroCdBlack = pRroCdBlack
	    pRroCdBlack:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
	    pRroCdBlack:setReverseDirection(true) --反向
	    pRroCdBlack:setScale(1.2)
	    self:addView(pRroCdBlack, 4)
	    centerInView(self, pRroCdBlack)
	end
	self.pRroCdBlack:stopAllActions()
	self.pRroCdBlack:setPercentage(nCd/nCdMax * 100)
	local progressTo = cc.ProgressTo:create(nCd,0)  
    local clear = cc.CallFunc:create(function (  )  
    	self:showCdBlackRecove()
    	if nCBFunc then
    		nCBFunc()
    	end
    end) 
    local pAct = cc.Sequence:create(progressTo,clear)
    self.pRroCdBlack:runAction(pAct)
end

-- 停止倒计时遮置
function MCircleBtn:stopCdBlack(  )
	if self.pRroCdBlack then
		self.pRroCdBlack:stopAllActions()
		self.pRroCdBlack:setVisible(false)
	end
end

-- 播放倒计时完存恢复特效
function MCircleBtn:showCdBlackRecove(  )
	self.pRroCdBlack:setVisible(false)

	local function getTxLayer()
		local pLay = display.newNode()
		pLay:setAnchorPoint(0.5, 0.5)
		pLay:setCascadeOpacityEnabled(true)
		pLay:setContentSize(self:getWidth(), self:getHeight())
		self:addView(pLay, 5)
		centerInView(self, pLay)
		local pImgBg1 = display.newSprite("#v1_ing_zjm_gndi.png")
		pImgBg1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pLay:addChild(pImgBg1, 1)
		centerInView(pLay, pImgBg1)
		local pImgIcon1 = display.newSprite(self.sImgName)
		pImgIcon1:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
		pLay:addChild(pImgIcon1, 2)
		centerInView(pLay, pImgIcon1)
		return pLay
	end

	-- 第一层：
	-- 时间    透明度    是否加亮
	-- 0秒      50%        加亮
	-- 0.05秒   100%       加亮 
	-- 0.5秒    0%         加亮
	local pLay1 = getTxLayer()
	pLay1:setOpacity(0.5 * 255)
	local pAct = cc.Sequence:create({
		cc.FadeTo:create(0.05, 255),
		cc.FadeOut:create(0.5 - 0.05),
		cc.CallFunc:create(function (  )
	 		pLay1:removeFromParent()
	 	end),
	 	})
	pLay1:runAction(pAct)

	-- 第二层：
	-- 时间    透明度   缩放值       是否加亮
	-- 0秒      50%      105%         加亮
	-- 0.05秒   100%     108%         加亮 
	-- 0.25秒    0%      120%         加亮
	local pLay2 = getTxLayer()
	pLay2:setOpacity(0.5 * 255)
	pLay2:setScale(1.05)
	local pAct = cc.Sequence:create({
		cc.Spawn:create({
						cc.FadeTo:create(0.05, 255),
		    			cc.ScaleTo:create(0.05, 1.08),
		    		}),
		cc.Spawn:create({
						cc.FadeOut:create(0.25 - 0.05),
		    			cc.ScaleTo:create(0.25 - 0.05, 1.2),
		    		}),
		cc.CallFunc:create(function (  )
	 		pLay2:removeFromParent()
	 	end),
	 	})
	pLay2:runAction(pAct)
end

--设置cd文本
function MCircleBtn:setCdText( sStr )
	if sStr then
		if self.pTxtCd then
			self.pTxtCd:setVisible(true)
			self.pTxtCd:setString(sStr)
		else
			local pSize = self:getContentSize()
			local nX, nY = pSize.width/2, pSize.height/2
			self.pTxtCd = MUI.MLabel.new({
            text = sStr,
            size = 26,})
            self:addView(self.pTxtCd, 6)
            self.pTxtCd:setPosition(nX, nY)
            setTextCCColor(self.pTxtCd, _cc.red)
            self.pTxtCd:enableOutline(cc.c4b(0,0,0,255), 2)
		end
	else
		if self.pTxtCd then
			self.pTxtCd:setVisible(false)
		end
	end
end

--设置元宝花费文本
function MCircleBtn:setGoldText( sStr )
	if sStr then
		if self.pTxtGold then
			self.pTxtGold:setVisible(true)
			self.pTxtGold:setString(sStr)
			self.pTxtGold:showImg()
		else
			local pSize = self:getContentSize()
			local nX, nY = pSize.width/2, 0
			local MImgLabel = require("app.common.button.MImgLabel")
			self.pTxtGold = MImgLabel.new({text=sStr, size = 18, parent = self, zorder = 10})
			self.pTxtGold:setImg("#v1_img_huangjin.png", 0.8, "left")
			self.pTxtGold:followPos("center", nX, nY, 5)
		end

		if self.pImgGoldBg then
			self.pImgGoldBg:setVisible(true)
		else
			local pSize = self:getContentSize()
			local nX, nY = pSize.width/2, 0
			self.pImgGoldBg = MUI.MImage.new("#v1_img_namebg3a.png")
            self:addView(self.pImgGoldBg, 2)
            self.pImgGoldBg:setPosition(nX, nY)
        end
	else
		if self.pTxtGold then
			self.pTxtGold:setVisible(false)
			self.pTxtGold:hideImg()
		end
		if self.pImgGoldBg then
			self.pImgGoldBg:setVisible(false)
		end
	end
end

function MCircleBtn:setGoldTxtVisible( bIsShow )
	if self.pTxtGold then
		self.pTxtGold:setVisible(bIsShow)
		if bIsShow then
			self.pTxtGold:showImg()
		else
			self.pTxtGold:hideImg()
		end
	end
	if self.pImgGoldBg then
		self.pImgGoldBg:setVisible(bIsShow)
	end
end

-- 析构方法
function MCircleBtn:onMCircleBtnDestroy(  )
	-- body
end

return MCircleBtn