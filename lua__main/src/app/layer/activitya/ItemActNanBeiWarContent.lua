----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-30 09:27:47
-- Description: 南征北战类似模块
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local ItemActPlugAccount = require("app.layer.activitya.ItemActPlugAccount")
local ItemActGetReward =  require("app.layer.activitya.ItemActGetReward")

local ItemActNanBeiWarContent = class("ItemActNanBeiWarContent", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

--创建函数
function ItemActNanBeiWarContent:ctor()
	self.pItemTime = nil --时间Item
	self.pImgAccount = nil --标题说明图片
	--解析
	parseView("dlg_activity_nanbeiwar", handler(self, self.onParseViewCallback))
	--注册析构方法
	self:setDestroyHandler("ItemActNanBeiWarContent",handler(self, self.onItemActNanBeiWarContentDestroy))	
end

--解析布局回调事件
function ItemActNanBeiWarContent:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

function ItemActNanBeiWarContent:onItemActNanBeiWarContentDestroy( )
	self:onPause()
end



--初始化控件
function ItemActNanBeiWarContent:setupViews( )

	self.pLyTitle = self:findViewByName("ly_title")
	self.pLySecTitle  = self:findViewByName("ly_sec_tile")
	
	--lb
	self.pLbSecTitle  = self:findViewByName("lb_sec_tile")
	self.pLbDescTitle = self:findViewByName("lb_desc_title")
	self.pLayDesc 	  = self:findViewByName("lay_desc")
	self.pLbDescCn    = self:findViewByName("lb_act_desc")
	
	--img
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")

	--滚动列
	self.pLayContent   = self:findViewByName("lay_content")

	self.pLayConBg     = self:findViewByName("ly_con")   

	--底层
	self.pLayBottom    = self:findViewByName("lay_bottom")    
	self.pLayBottom:setVisible(false)

	self.pLaySpace 		= self:findViewByName("lay_space_2")
end

--设置数据 _data
function ItemActNanBeiWarContent:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}

	--设置banner图
	if self.pData.nId == e_id_activity.nanbeiwar then --南征北战
		self:setBannerImg(TypeBannerUsed.ac_nzbz)
	elseif self.pData.nId == e_id_activity.sevendaylog then --七天签到
		self:setBannerImg(TypeBannerUsed.ac_qtqd)
	elseif self.pData.nId == e_id_activity.dayrebate then --每日返利
		self:setBannerImg(TypeBannerUsed.ac_mrfl)
	elseif self.pData.nId == e_id_activity.consumegift then --消费好礼
		self:setBannerImg(TypeBannerUsed.ac_sfhl)
	elseif self.pData.nId == e_id_activity.totalrecharge then --累计充值
		self:setBannerImg(TypeBannerUsed.ac_ljcz)
	elseif self.pData.nId == e_id_activity.doubleegg then --双旦活动
		self:setBannerImg(TypeBannerUsed.ac_sdhd)
	elseif self.pData.nId == e_id_activity.onlinewelfare then --在线福利
		self:setBannerImg(TypeBannerUsed.ac_zxfl)
	elseif self.pData.nId == e_id_activity.rechargesign then --充值签到
		self:setBannerImg(TypeBannerUsed.ac_czqd)
	elseif self.pData.nId == e_id_activity.equipmake then --装备打造
		self:setBannerImg(TypeBannerUsed.ac_zbdz)
	elseif self.pData.nId == e_id_activity.fubenpass then --副本推进
		self:setBannerImg(TypeBannerUsed.ac_sdhd)
	elseif self.pData.nId == e_id_activity.playerlvup then --主公升级
		self:setBannerImg(TypeBannerUsed.ac_sdhd)
	elseif self.pData.nId == e_id_activity.equiprefine then --装备洗炼
		self:setBannerImg(TypeBannerUsed.ac_sdhd)
	elseif self.pData.nId == 1041 then --打造蓝装
		self:setBannerImg(TypeBannerUsed.ac_dzlz)
	elseif self.pData.nId == e_id_activity.artifactmake then --神器升级
		self:setBannerImg(TypeBannerUsed.ac_sdhd)
	elseif self.pData.nId == e_id_activity.herocollect then --武将收集
		self:setBannerImg(TypeBannerUsed.ac_wjsj)
	elseif self.pData.nId == e_id_activity.attackvillage then --攻城拔寨	
		self:setBannerImg(TypeBannerUsed.ac_gcbz)
	elseif self.pData.nId == e_id_activity.regress then --回归有礼	
		self:setBannerImg(TypeBannerUsed.ac_hgyl)
	end
end

--设置banner图片 
function ItemActNanBeiWarContent:setBannerImg(nType)
	if self.pLayBannerBg and nType then
		setMBannerImage(self.pLayBannerBg,nType)
	end
end

--设置时间
function ItemActNanBeiWarContent:setActTime()
	if self.pData and self.pItemTime then
		self.pItemTime:setCurData(self.pData)
	end
end

--添加说明图片
function ItemActNanBeiWarContent:addAccountImg(_strImg, _pos)
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
	if _pos then
		self.pImgAccount:setPosition(_pos)
	else
		self.pImgAccount:setPosition(7,7)
	end

end

function ItemActNanBeiWarContent:setDesc(_tDesc)
    print("ItemActNanBeiWarContent:setDesc(_tDesc) : ", _tDesc)
    if _tDesc then
        self.pLayDesc:setVisible(true)
        local tDimensions = self.pLbDescCn:getDimensions()
		self.pLbDescCn:setDimensions(tDimensions.width, 0)
		self.pLbDescCn:setString(_tDesc)        
        local tNewDescSize = self.pLbDescCn:getContentSize()
        local tBgSize = self.pLayDesc:getContentSize()
        local nSpace = 10 -- 上下边距        
        self.pLayDesc:setLayoutSize(tBgSize.width, tNewDescSize.height + nSpace * 2)
        self.pLbDescCn:setPositionY(tNewDescSize.height / 2 + nSpace)        
	end
end

return ItemActNanBeiWarContent