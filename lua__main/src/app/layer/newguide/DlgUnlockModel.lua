-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2018-04-13 09:40:00 星期五
-- Description: 功能开放解锁提示框
-----------------------------------------------------


local MDialog = require("app.common.dialog.MDialog")
local DlgUnlockModel = class("DlgUnlockModel", function ()
	return MDialog.new()
end)

function DlgUnlockModel:ctor(  )
	-- body
	self:myInit()

    self:setIsNeedOutside(true)
    self:setOutSideHandler(handler(self, self.onOutsideHandler))

	parseView("dlg_unlock_build", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgUnlockModel:myInit(  )
	self.eDlgType 		= e_dlg_index.unlockmodel   --对话框类型
end

--解析布局回调事件
function DlgUnlockModel:onParseViewCallback( pView )
	-- body
	self:setContentView(pView)
	self:updateViews()

	pView:setViewTouched(true)
	pView:setIsPressedNeedScale(false)
	pView:setIsPressedNeedColor(false)
	pView:onMViewClicked(function ( _pView )
	    self:onOutsideHandler()
	end)

	--注册析构方法
	self:setDestroyHandler("DlgUnlockModel",handler(self, self.onDlgUnlockModelDestroy))
end

function DlgUnlockModel:setData( nOpenId, nGuideId)
	self.nGuideId = nGuideId
	self.tOpenData = getOpenSystem(nOpenId)
	self:updateViews()
end

-- 修改控件内容或者是刷新控件数据
function DlgUnlockModel:updateViews(  )
	if not self.tOpenData then
		return
	end


	-- 分帧执行实际的刷新
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if(_index == 1) then
			-- body
			--设置标题
			if self.pLbTitle == nil then
				self.pLbTitle = self:findViewByName("lb_title")
				setTextCCColor(self.pLbTitle, _cc.white)
			end
			self.pLbTitle:setString(getConvertedStr(3, 10741))

			--设置名字
			if(self.pLbName == nil) then
				self.pLbName =  self:findViewByName("lb_name")
			end
			self.pLbName:setString(self.tOpenData.name)
			setTextCCColor(self.pLbName, _cc.yellow)
		elseif(_index == 2) then
			--设置内容
			if self.pLbDesc == nil then
				self.pLbDesc = self:findViewByName("lb_desc")
				setTextCCColor(self.pLbDesc, _cc.pwhite)
			end
			local sDesc = self.tOpenData.open or ""
			self.pLbDesc:setString(getTextColorByConfigure(sDesc))
			--设置提示语
			if self.pLbTips == nil then
				self.pLbTips = self:findViewByName("lb_tips")
				setTextCCColor(self.pLbTips, _cc.pwhite)
			end
			self.pLbTips:setString(getConvertedStr(1, 10255))
		elseif(_index == 3) then
			--获得内容层 
			if self.pLayCon == nil then
				self.pLayCon = self:findViewByName("lay_main")
			end
			--展示特效
			self:showOpenTx()
		end 
		if(_bEnd) then
			--1秒后关闭提示框
			doDelayForSomething(self, function (  )
				self:onOutsideHandler()
			end,5.0)
		end
	end)
end

--展示解锁教程
function DlgUnlockModel:showUnlockGuide(  )
	if self.nGuideId then
		Player:getNewGuideMgr():showNewGuideByStepId(self.nGuideId)
	end
end

--点击四周关闭
function DlgUnlockModel:onOutsideHandler(  )
	self:showUnlockGuide()
	self:closeDlg()
end

-- 析构方法
function DlgUnlockModel:onDlgUnlockModelDestroy(  )
	--显示下一条顺序显示
    showNextSequenceFunc(e_show_seq.unlockmodel)
end

--展示解锁特效
function DlgUnlockModel:showOpenTx(  )
	if not self.tOpenData then
		return
	end

	--添加纹理
	addTextureToCache("tx/other/p1_tx_jzjs")
	-- body
	local fScale = 1
	local tPos = cc.p(100,100)
	local tBgPos = cc.p(100,100)
	
	local sImg = "#"..tostring(self.tOpenData.icon)..".png"
	
	--第一层
	local pParitcle = createParitcle("tx/other/lizi_huode_xjz_lzdh_001.plist")
	pParitcle:setPosition(tBgPos)
	self.pLayCon:addView(pParitcle,10)
	--第二层
	local pImg1 = getCircleRepeatForever("#sg_guqt__2_sa1_001.png",9,true)
	pImg1:setPosition(tBgPos)
	self.pLayCon:addView(pImg1,20)
	--第三层
	local pImg2 = getCircleRepeatForever("#sg_guqt__2_sa1_002.png",6,true)
	pImg2:setPosition(tBgPos)
	self.pLayCon:addView(pImg2,30)
	--第四层
	local pImg3 = MUI.MImage.new(sImg) --这里先临时全部统一用这个图片
	pImg3:setPosition(tPos)
	self:setImgScale(pImg3)
	self.pLayCon:addView(pImg3,40)


	--第五层
	local pImg4 = MUI.MImage.new(sImg) --这里先临时全部统一用这个图片
	pImg4:setPosition(tPos)
	self:setImgScale(pImg4)
	pImg4:setOpacity(13)
	self.pLayCon:addView(pImg4,50)
	self:showScaleRepeatForever(pImg4)
	--第六层
	self:showLightTx(tBgPos)
end

function DlgUnlockModel:setImgScale( pTarget )
	local pSize = cc.size(200, 160)
	local pSize2 = pTarget:getContentSize()
	local nLen = math.max(pSize2.width, pSize2.height)
	if nLen == pSize2.width then
		if nLen > pSize.width then
			pTarget:setScale(pSize.width/nLen)
		end
	else
		if nLen > pSize.height then
			pTarget:setScale(pSize.height/nLen)
		end
	end
end

--循环缩放
function DlgUnlockModel:showScaleRepeatForever( _pView )
	-- body
	local action1 = cc.FadeTo:create(0.6, 50)
	local action2 = cc.FadeTo:create(0.6, 13)
	local allActions = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
	_pView:runAction(allActions)
end

--展示光晕效果
function DlgUnlockModel:showLightTx( _tPos )
	-- body
	local pArm = MArmatureUtils:createMArmature(
		tNormalCusArmDatas["8"], 
		self.pLayCon, 
		60, 
		_tPos,
	    function ( _pArm )

	    end, Scene_arm_type.base)
	if pArm then
		pArm:play(-1)
	end
end

return DlgUnlockModel