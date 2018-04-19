-- Author: liangzhaowei
-- Date: 2017-06-21 14:51:40
-- 活动a模板pa版 (517*1066)

local MCommonView = require("app.common.MCommonView")
local ItemActPlugAccount = require("app.layer.activitya.ItemActPlugAccount")


local ItemActContent = class("ItemActContent", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数 _nId
function ItemActContent:ctor(_nId)
	-- body
	self:myInit()


	parseView("dlg_activity_pa", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemActContent",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemActContent:myInit()
	self.pData = {} --数据
	self.nCnType = 1 --内容版本
	self.pItemTime = nil --时间Item
	self.pMHandler = nil --中间按钮回调
	self.pImgAccount = nil --标题说明图片
end

--解析布局回调事件
function ItemActContent:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)


	self:setupViews()
end

--初始化控件
function ItemActContent:setupViews( )


	--ly         
	self.pLyDesc = self:findViewByName("ly_desc")
	self.pLyBtnM = self:findViewByName("ly_btn_m")
	self.pLyTitle= self:findViewByName("ly_title")

	
	--lb
	self.pLbSecTitle  = self:findViewByName("lb_sec_tile")
	self.pLbDescTitle = self:findViewByName("lb_desc_title")
	self.pLbDescCn    = self:findViewByName("lb_desc_cn")

	self.DescPosY 	= self.pLbDescCn:getPositionY()

	--img
	self.pLayBannerBg = self:findViewByName("ly_title")


	self.pBtnM = getCommonButtonOfContainer(self.pLyBtnM, TypeCommonBtn.L_YELLOW, getConvertedStr(5, 10196))
	self.pBtnM:onCommonBtnClicked(handler(self, self.onMiddleClicked))
	
end

--设置中间按钮文字
function ItemActContent:setMBtnText(_str)
	-- body
	if _str then
		if self.pBtnM then
			self.pBtnM:updateBtnText(_str)
		end
	end
end

--设置中间按钮文字
function ItemActContent:setMBtnType(_type)
	-- body
	if _type then
		if self.pBtnM then
			self.pBtnM:updateBtnType(_type)
		end
	end
end

--设置中间按钮回调
function ItemActContent:setMHandler(_handler)
	if _handler then
		self.pMHandler = _handler
	end
end

--中间按钮回调
function ItemActContent:onMiddleClicked(pView)
	if self.pMHandler then
    	self.pMHandler()
	end

end

-- 修改控件内容或者是刷新控件数据
function ItemActContent:updateViews()
	self:refreshView()
end

--刷新内容
function ItemActContent:refreshView()
	if not self.pData then
		return
	end

	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLyTitle,self.pData,cc.p(0,170))
	end
	self.pItemTime:setCurData(self.pData)

	if self.pData.sTitle then
		self.pLbSecTitle:setString(self.pData.sTitle)
	end

	--永久活动不显示时间
	if self.pData.nType == 3 then --永久活动
		self.pLbDescTitle:setString("")
		self.pLbDescCn:setPositionY(self.DescPosY + 50)
	else
		if self.pData.getStrActTimeYear then
			self.pLbDescTitle:setString(self.pData:getStrActTimeYear(true))
			self.pLbDescCn:setPositionY(self.DescPosY)
		end
	end
	-- dump(self.pData)
	if self.pData.sDesc then
		self.pLbDescCn:setString(self.pData.sDesc)
	end

	--设置banner图
	if self.pData.nId == 1003 then --副本掉落
		self:setBannerImg(TypeBannerUsed.ac_fbdl)
	elseif self.pData.nId == 1004 then --工坊加速
		self:setBannerImg(TypeBannerUsed.ac_gfjs)
	elseif self.pData.nId == 1006 then --经验翻倍
		self:setBannerImg(TypeBannerUsed.ac_jyfb)
	elseif self.pData.nId == 1007 then --乱军加速
		self:setBannerImg(TypeBannerUsed.ac_ljjs)
	elseif self.pData.nId == 1013 then --乱军迁城
		self:setBannerImg(TypeBannerUsed.ac_ljqc)
	elseif self.pData.nId == 1014 then --采集加量
		self:setBannerImg(TypeBannerUsed.ac_cjjl)
	elseif self.pData.nId == 1016 then --乱军图纸
		self:setBannerImg(TypeBannerUsed.ac_ljtz)
	elseif self.pData.nId == 1017 then --物产加速
		self:setBannerImg(TypeBannerUsed.ac_wcjs)
	elseif self.pData.nId == 1018 then --乱军资源
		self:setBannerImg(TypeBannerUsed.ac_ljzy)
	elseif self.pData.nId == 1029 then --神兵暴击
		self:setBannerImg(TypeBannerUsed.ac_sbbj)
	elseif self.pData.nId == 1030 then --王宫采集
		self:setBannerImg(TypeBannerUsed.ac_afgcj)
	elseif self.pData.nId == 1032 then --体力折扣
		self:setBannerImg(TypeBannerUsed.ac_tlzk)
	elseif self.pData.nId == 1028 then --免费召唤
		self:setBannerImg(TypeBannerUsed.ac_mfzh)
	end
end

--析构方法
function ItemActContent:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemActContent:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	self:refreshView()


end

--获取类型
function ItemActContent:getType()
	if self.nCnType then
		return self.nCnType 
	else
		return 0
	end
end

--设置banner图片 
function ItemActContent:setBannerImg(nType)
	if self.pLayBannerBg and nType then
		setMBannerImage(self.pLayBannerBg,nType)
	end
end

--添加说明图片
function ItemActContent:addAccountImg(_strImg)
	-- body
	--默认工坊加速的图片
	if not self.pImgAccount then
		self.pImgAccount = ItemActPlugAccount.new()
		self.pLyTitle:addView( self.pImgAccount, 2 )
		self.pImgAccount:setPosition(7,7)
	end

	if not _strImg then
		return
	end
	self.pImgAccount:setAccountImg(_strImg)

end


--设置时间
function ItemActContent:setActTime()
	if self.pData and self.pItemTime then
		self.pItemTime:setCurData(self.pData)
	end
end


return ItemActContent