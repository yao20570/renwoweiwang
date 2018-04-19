-- ItemRealNameCheck.lua
---------------------------------------------
-- Author: wzy
-- Date: 2018-3-8 
-- 实名认证界面
---------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemRealNameCheck = class("ItemRealNameCheck", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemRealNameCheck:ctor()
	-- body
	self:myInit()
    --和手机绑定ItemPhoneBind共用一个UI文件
	parseView("dlg_phone_bind", handler(self, self.onParseViewCallback))
end


--解析布局回调事件
function ItemRealNameCheck:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	-- self:updateViews()
	self:regMsgs()
	--注册析构方法
	self:setDestroyHandler("ItemRealNameCheck",handler(self, self.onDestroy))
end

--初始化参数
function ItemRealNameCheck:myInit()
	self.pData = {} --数据
	self.pItemTime = nil --时间Item
end

-- 游戏恢复,这里只是一个临时的过度，用来控制数据别那么快加载而已
function ItemRealNameCheck:onEnterForeground(  )
    print("ItemRealNameCheck:onEnterForeground()")
    self:stopAllActions()
    doDelayForSomething(self,function (  )
        -- body
       self:onRealEnterForeground()
    end, 1)
end

-- 游戏恢复
function ItemRealNameCheck:onRealEnterForeground(  )
    print("ItemRealNameCheck:onRealEnterForeground()")
    if AccountCenter == nil then
    	return
    end
    -- 查询实名认证
	if device.platform == "android" then 		
        local className = "com/game/quickmgr/QuickMgr"
        local methodName = "doGetUserAge"
        local bRet, nAge = luaj.callStaticMethod(className, methodName, {}, "()I");             
        AccountCenter.rn_sdk_age = tonumber(nAge) or 0 -- 实名认证的年龄
        --print("实名认证年龄============================:".. nAge)

	elseif device.platform == "ios" then
        -- IOS通过onSDKRealNameAuthSuccess获取了年龄
        -- AccountCenter.rn_sdk_age
	end	

    if AccountCenter.rn_sdk_age >0 then
        self.pData:sendNet(1)	    --绑定
    end
end

--初始化控件
function ItemRealNameCheck:setupViews( )
	self.pLyTitle         = self:findViewByName("ly_title")
	--设置图片
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	--图片处说明
	self.pLbTips	  = self:findViewByName("lb_tips")
	--第二标题
	self.pLbSecTitle	  = self:findViewByName("lb_sec_title")
	--说明
	self.pLbDec	  = self:findViewByName("lb_dec")
	--第三标题
	self.pLbThirdTitle  = self:findViewByName("lb_third_title")
	--物品层
	self.pLayicon  = self:findViewByName("lay_icon")
	--按钮层
	self.pImgJianbian  = self:findViewByName("img_jianbian")
	self.pImgJianbian:setVisible(false)
	
	self.pLayBtn  = self:findViewByName("lay_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(1, 10308))
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	--设置banner图
	self:setBannerImg(TypeBannerUsed.ac_sjbd)

end

--点击兑换回调
function ItemRealNameCheck:onBtnClicked()
 	--打开实名认证界面
 	if self.pData.nState == 0 then
 		if device.platform == "android" then
	 		local className = "com/game/quickmgr/QuickMgr"
	        local methodName = "doOpenSmrz"
	        luaj.callStaticMethod(className, methodName, {1, ""}, "(ILjava/lang/String;)V");
	        
 		elseif device.platform == "ios" then
 			local param = {}
	        param.type = 1 -- 打开实名认证界面
	        local luaoc = require("framework.luaoc")
	        local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", 
	            "doOpenSmrz", param)
 		else
 			self.pData:sendNet(1)	--绑定
 		end
 	--物品领取
 	elseif self.pData.nState == 1 then
 		self.pData:sendNet(2)	    --领取

 	elseif self.pData.nState == 2 then
 		TOAST(getConvertedStr(3, 10214))

 	end
end


--设置banner图片 
function ItemRealNameCheck:setBannerImg(nType)
	if self.pLayBannerBg and nType then
		setMBannerImage(self.pLayBannerBg,nType)
	end
end


--修改控件内容或者是刷新控件数据
function ItemRealNameCheck:updateViews(  )
	if self.pData then

 		self.pLbDec:setString(self.pData.sDesc)
 		self.pLbSecTitle:setString(self.pData.sTitle)
 		self.pLbThirdTitle:setString(getConvertedStr(10, 10104))

 		if not self.pItemTime then
			self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
		end
		self.pItemTime:setCurData(self.pData)


 		local tCurDatas = getRewardItemsFromSever(self.pData.tGetAwards)
 		gRefreshHorizontalIcons(self.pLayicon, tCurDatas)

 		--未绑定
 		if self.pData.nState == 0 then
 			self.pBtn:updateBtnType(TypeCommonBtn.L_BLUE)
 			self.pBtn:updateBtnText(getConvertedStr(10,10104))
 		--已绑定
 		elseif self.pData.nState == 1 then
 			self.pBtn:updateBtnType(TypeCommonBtn.L_YELLOW)
 			self.pBtn:updateBtnText(getConvertedStr(10,10102))
 		--已领取
 		elseif self.pData.nState == 2 then
 			self.pBtn:setToGray(true)
 			self.pBtn:updateBtnText(getConvertedStr(10,10103))
 		end	
	end
end

--析构方法
function ItemRealNameCheck:onDestroy(  )
	self:unregMsgs()
end


-- 注册消息
function ItemRealNameCheck:regMsgs( )
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))
	regMsg(self, "ghd_APP_ENTER_FOREGROUND_EVENT", handler(self, self.onEnterForeground))
end

-- 注销消息
function ItemRealNameCheck:unregMsgs( )
	unregMsg(self, gud_refresh_activity)
	unregMsg(self, "ghd_APP_ENTER_FOREGROUND_EVENT")
end

-- 设置数据
function ItemRealNameCheck:setData(_data)
	if not _data then
		return
	end
	self.pData = _data
	self:updateViews()
end
 
--设置时间
function ItemRealNameCheck:setActTime()
	if self.pData and self.pItemTime then
		self.pItemTime:setCurData(self.pData)
	end
end

return ItemRealNameCheck

