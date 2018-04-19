-- Author: liangzhaowei
-- Date: 2017-06-22 10:52:34
-- 活动模板b入口单个活动信息

local MCommonView = require("app.common.MCommonView")
local ItemActModleB = class("ItemActModleB", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemActModleB:ctor()
	-- body
	self:myInit()

	parseView("item_activity_modleb", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemActModleB",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActModleB:myInit()
	self.pData = {} --数据
	self.pIcon = nil --icon
	self.pHandler  = nil ----回调句柄
	self.bFirst = true --是否第一次加载
end

--解析布局回调事件
function ItemActModleB:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)	

	self:setupViews()
	-- self:updateViews()
end

--初始化控件
function ItemActModleB:setupViews()

	--ly
	self.pLyIcon = self:findViewByName("ly_icon")
	self.pLyRed = self:findViewByName("ly_red")
	-- self.pLyIcon:setBackgroundImage("sBgName")--改变背景图片
	
	--lb
	self.pLbTitle      = self:findViewByName("lb_title")
	self.pLbSecTitle   = self:findViewByName("lb_sec_title")
	self.pLbDesc       = self:findViewByName("lb_desc")
	setTextCCColor(self.pLbDesc,_cc.pwhite)
	setTextCCColor(self.pLbTitle,_cc.yellow)
	self.pLbRemainTime = self:findViewByName("lb_remain_time")
	setTextCCColor(self.pLbRemainTime,_cc.green)

	--img
	self.pImgBg = self:findViewByName("img_bg")
	self.pImgIcon = self:findViewByName("img_icon")


    self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
    self:onMViewClicked(handler(self,self.onGetClick))

end

-- 修改控件内容或者是刷新控件数据
function ItemActModleB:updateViews(  )
	if not self.pData then
       return
	end

	--活动名称
	if self.pData.sName then
		self.pLbTitle:setString(self.pData.sName)
	end
	--副标题
	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end

	--时间显示格式
	self.nTimeShowType = e_ac_time_type.normal
	if self.pData.getTimeShowType then
		self.nTimeShowType = self.pData:getTimeShowType()
	end
	--
	if self.nTimeShowType == e_ac_time_type.forerver then
		self.pLbDesc:setString(getConvertedStr(5, 10228))
	elseif self.nTimeShowType == e_ac_time_type.limit then
		self.pLbDesc:setString(getConvertedStr(3, 10702))
	else
		if self.pData.getStrActTimeYear and  self.pData:getStrActTimeYear(false) then
			self.pLbDesc:setString(self.pData:getStrActTimeYear(false))
		end
	end
		
	if self.pData.sIcon then
		self.pImgBg:setCurrentImage(self.pData.sIcon)
	end
	if self.pData.sIconBg then
		self.pImgIcon:setCurrentImage(self.pData.sIconBg)
	end

	--检测cd
	if self.nUpdateCdCheckId ~= self.pData.nId then
		self.nUpdateCdCheckId = self.pData.nId
		--倒计时检测开启
		if self.nTimeShowType == e_ac_time_type.forerver then
			unregUpdateControl(self)
		else
			regUpdateControl(self, handler(self, self.updateCd))
		end
	end

	--红点
	local nRedNum = self.pData:getRedNums()
	if nRedNum > 0 then
		showRedTips(self.pLyRed,0,1)
	else
		showRedTips(self.pLyRed,0,0)
	end
	--显示新
	if self.pData:getIsNew() then
		showActivityNewVisible(self, true, 0.8)
	else
		showActivityNewVisible(self, false)
	end
	-- 刷新一次数据
	self:refreshRemainTime()
end

--刷新剩余时间
function ItemActModleB:refreshRemainTime()
	if not self.pData then
       return
	end
	if self.nTimeShowType == e_ac_time_type.forerver then --永久时间
		self.pLbDesc:setString(getConvertedStr(5, 10228))
		self.pLbRemainTime:setVisible(false)
		unregUpdateControl(self)
	elseif self.nTimeShowType == e_ac_time_type.limit then --限时倒计时
		if self.pData.nId == e_id_activity.newgrowthfound then --结束要变永远
			if self.pData.getTimeShowType then
				self.nTimeShowType = self.pData:getTimeShowType() --下一秒就可能变永远
			end
		end
		--普通倒计时
		self.pLbRemainTime:setVisible(true)
		if self.pData.getRemainTime then
			self.pLbRemainTime:setString(self.pData:getRemainTime())
			self.pLbRemainTime:setPositionX(self.pLbDesc:getPositionX()+self.pLbDesc:getWidth()+10)
		end
	else--普通倒计时
		self.pLbRemainTime:setVisible(true)
		if self.pData.getRemainTime then
			self.pLbRemainTime:setString(self.pData:getRemainTime())
			self.pLbRemainTime:setPositionX(self.pLbDesc:getPositionX()+self.pLbDesc:getWidth()+10)
		end
	end
end



--析构方法
function ItemActModleB:onDestroy(  )
	unregUpdateControl(self)

end

--设置按钮回调
function ItemActModleB:setHandler(_handler)
	if _handler then
		self.pHandler  = _handler
	end
end

--获得按钮回调
function ItemActModleB:onGetClick()
	if self.pHandler and self.pData then
		self.pHandler(self.pData)
	end
end

--设置数据 _data
function ItemActModleB:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:updateViews()



	--self.pLbN:setString(self.pData.sName or "")
	

end




--时间更新函数
function ItemActModleB:updateCd()
	self:refreshRemainTime()
end

return ItemActModleB