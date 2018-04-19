----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-14 10:45:39
-- Description: 通用获取奖励面板
-----------------------------------------------------
local MDialog = require("app.common.dialog.MDialog")
local IconGoods = require("app.common.iconview.IconGoods")
local DlgGetReward = class("DlgGetReward", function()
	return MDialog.new()
end)

--tData = {
-- 	sTitle, --标题文本
--  sDesc,  --描述（可以是数组）
-- 	sBanner, --横条文本
-- 	tGoods, --物品数据
-- 	nHandler, --回调
-- }

function DlgGetReward:ctor( _eDlgType, tData )
	self:myInit(tData)
	self.eDlgType = _eDlgType or e_dlg_index.getreward
	parseView("dlg_get_reward", handler(self, self.onParseViewCallback))
	self:setName(UIAction.TAG_SMALL_DLG)
end

function DlgGetReward:myInit( tData )
	self.tData = tData
end

--解析布局回调事件
function DlgGetReward:onParseViewCallback( pView )
	-- body
	self.pComDlgView = pView
	self:setContentView(self.pComDlgView)
	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("DlgGetReward",handler(self, self.onDlgGetRewardDestroy))
end

--初始化控件
function DlgGetReward:setupViews(  )--标题
	self.pLayView = self:findViewByName("view")
	self.pTxtTitle = self:findViewByName("txt_title")

	self.pTxtDesc = self:findViewByName("txt_desc")

	local pImgBtnClose = self:findViewByName("img_btn_close")
	pImgBtnClose:setViewTouched(true)
	pImgBtnClose:setIsPressedNeedScale(false)
	pImgBtnClose:onMViewClicked(handler(self, self.closeDlg))

	self.pLbTip = self:findViewByName("lb_tip")
	self.pLbTip:setString(getConvertedStr(6, 10210)) --点击屏幕任意位置关闭
	setTextCCColor(self.pLbTip, _cc.pwhite)

end

--设置标题
function DlgGetReward:setTitle(_str)
	-- body
	self.pTxtTitle:setString(_str)
end

--控件刷新
function DlgGetReward:updateViews(  )
	if not self.tData then
		return
	end

	--标题
	self.pTxtTitle:setString(self.tData.sTitle)

	--描述
	self.pTxtDesc:setString(self.tData.sDesc)

	if not self.pBtnSubmit then
		local pLayBtnSubmit = self:findViewByName("lay_btn_submit")
		self.pBtnSubmit = getCommonButtonOfContainer(pLayBtnSubmit, TypeCommonBtn.M_YELLOW, getConvertedStr(6, 10336))
		self.pBtnSubmit:onCommonBtnClicked(handler(self, self.onSubmitClicked))
	end

	if not self.pLayGoods then
		self.pLayGoods = self:findViewByName("lay_goods")
		self.pLineIcons = {}
		-- self.nLayGoodsWidth = self.pLayGoods:getContentSize().width
		-- self.nLayGoodsHeight = self.pLayGoods:getContentSize().height

		-- --一行最大数量
		-- self.nIconWidth = 120
		-- self.pLineIcons = {}
		-- for i=1,4 do
		-- 	local pLineIcon = MUI.MLayer.new()
		-- 	pLineIcon:setContentSize(self.nIconWidth, 120)
		-- 	self.pLayGoods:addView(pLineIcon)
		-- 	table.insert(self.pLineIcons, pLineIcon)
		-- end
	end

	--物品数据
	local nItemCntMax = 4
	local nGoodsNum = #self.tData.tGoods
	if nGoodsNum > nItemCntMax  then
		nGoodsNum = nItemCntMax
	end
	local nScale = 0.8
	local nIconW = 108*nScale
	local nDis = 26
	local nStart = (self.pLayGoods:getContentSize().width - nIconW*nGoodsNum - (nGoodsNum - 1)*nDis)/2
	for i = 1, nItemCntMax do
		if not self.pLineIcons[i] then
			local pIcon = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum)
			pIcon:setScale(nScale)			
			self.pLayGoods:addView(pIcon)
			self.pLineIcons[i] = pIcon
		end
		self.pLineIcons[i]:setPosition(nStart + (nDis + nIconW)*(i - 1), 25)
		if self.tData.tGoods[i] then
			self.pLineIcons[i]:setCurData(self.tData.tGoods[i])
			self.pLineIcons[i]:setVisible(true)
		else
			self.pLineIcons[i]:setVisible(false)
		end
	end
	-- if nGoodsNum > #self.pLineIcons then
	-- 	--列表
	-- 	if self.pListView then
	-- 		self.pListView:setVisible(true)
	-- 	end
	-- 	for i=1,#self.pLineIcons do
	-- 		self.pLineIcons[i]:setVisible(false)
	-- 	end
	-- 	self.pListView = gRefreshHorizontalList(self.pLayGoods, self.tData.tGoods)
	-- else
	-- 	--居中
	-- 	if self.pListView then
	-- 		self.pListView:setVisible(false)
	-- 	end
	-- 	for i=1,#self.pLineIcons do
	-- 		self.pLineIcons[i]:setVisible(false)
	-- 	end
	-- 	local nNum = math.min(#self.pLineIcons, nGoodsNum)
	-- 	local nX = 150
	-- 	if nGoodsNum == 4 then
	-- 		nX = 0
	-- 	else
	-- 		nX = 150
	-- 	end		
	-- 	local nW = (self.nLayGoodsWidth - nX) / nNum
	-- 	for i=1,nNum do
	-- 		local X = nX + (i - 1) * nW + nW / 2 - self.nIconWidth/2
	-- 		if self.pLineIcons[i] then
	-- 			local pIcon = getIconGoodsByType(self.pLineIcons[i], TypeIconGoods.HADMORE, type_icongoods_show.itemnum, self.tData.tGoods[i], TypeIconGoodsSize.M)
	-- 			self.pLineIcons[i]:setPositionX(X)
	-- 			self.pLineIcons[i]:setVisible(true)
	-- 		end
	-- 	end
	-- end
end

--析构方法
function DlgGetReward:onDlgGetRewardDestroy(  )
end

--点击确定回调
function DlgGetReward:onSubmitClicked( pView )
	if self.tData then
		if self.tData.nHandler then
			self.tData.nHandler()
		end
	end
	self:closeDlg(false)
end

--设置数据
function DlgGetReward:__setData( tData )
	self.tData = tData
	self:updateViews()
end

return DlgGetReward