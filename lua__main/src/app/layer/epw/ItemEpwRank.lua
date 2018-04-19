-----------------------------------------------------
-- author: zhangnianfeng
-- updatetime:  2018-03-27 10:01:0 星期二
-- Description: 皇城战 伤害排名
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemEpwRank = class("ItemEpwRank", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemEpwRank:ctor( )
	-- body	
	self:myInit()	
	parseView("item_epw_rank", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemEpwRank:myInit()
end

--解析布局回调事件
function ItemEpwRank:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemEpwRank",handler(self, self.onItemEpwRankDestroy))
end

--初始化控件
function ItemEpwRank:setupViews( )
	self.pImgRank = self:findViewByName("img_rank")
	self.pTxtRank = self:findViewByName("txt_rank")
	self.pTxtCountry = self:findViewByName("txt_country")
	self.pTxtName = self:findViewByName("txt_name")
	self.pTxtScore = self:findViewByName("txt_harm")

	self:setIsPressedNeedScale(false)                      
	self:setViewTouched(true)
	self:onMViewClicked(handler(self, self.onClick))
end

-- 修改控件内容或者是刷新控件数据
function ItemEpwRank:updateViews( )
	if not self.tData then
		return
	end
	--当前排名
	local nRank = self.tData.x
	if nRank == 1 then
		self.pTxtRank:setVisible(false)
		self.pImgRank:setVisible(true)
		self.pImgRank:setCurrentImage("#v1_img_paixingbang1.png")
	elseif nRank == 2 then
		self.pTxtRank:setVisible(false)
		self.pImgRank:setVisible(true)
		self.pImgRank:setCurrentImage("#v1_img_paixingbang2.png")
	elseif nRank == 3 then
		self.pTxtRank:setVisible(false)
		self.pImgRank:setVisible(true)
		self.pImgRank:setCurrentImage("#v1_img_paixingbang3.png")
	else
		self.pImgRank:setVisible(false)
		self.pTxtRank:setString(nRank)
		self.pTxtRank:setVisible(true)
	end

	--国家
	local nCountry = self.tData.c
	self.pTxtCountry:setString(getCountryShortName(nCountry))
	setTextCCColor(self.pTxtCountry, getColorByCountry(nCountry))

	--名字
	self.pTxtName:setString(self.tData.n)	

	--积分
	self.pTxtScore:setString(self.tData.qa)
end

-- 析构方法
function ItemEpwRank:onItemEpwRankDestroy( )
end

function ItemEpwRank:setData( tData )
	self.tData = tData
	self:updateViews()
end

function ItemEpwRank:onClick(  )
	if not self.tData then
		return
	end

	local pMsgObj = {}
	pMsgObj.nplayerId = self.tData.nPlayerId
	pMsgObj.bToChat = false
	--发送获取其他玩家信息的消息
	sendMsg(ghd_get_playerinfo_msg, pMsgObj)
end

return ItemEpwRank