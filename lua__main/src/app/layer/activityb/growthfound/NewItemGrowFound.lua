-- NewItemGrowFound.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2018-1-5 14:37:33 星期五
-- Description: 新版成长基金列表项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local NewItemGrowFound = class("NewItemGrowFound", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function NewItemGrowFound:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("new_item_funds", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function NewItemGrowFound:myInit(_index)
	-- body
	self.idx = _index
	self.tCurData  = nil 				--当前数据
	self.bBuyed    = nil                --是否已购买基金
end

--解析布局回调事件
function NewItemGrowFound:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("NewItemGrowFound",handler(self, self.onNewItemGrowFoundDestroy))
end

--初始化控件
function NewItemGrowFound:setupViews()
	-- body
	self.pLayRoot    = self:findViewByName("default")
	self.pLbLvb      = self:findViewByName("lb_lvb")
	self.pLbLvb:setString(getConvertedStr(7, 10084))
	self.pLbLva      = self:findViewByName("lb_lva")
	self.pLbLva:setString(getConvertedStr(7, 10085))

	--背景
	local pLayBg = self:findViewByName("lay_bg")
	setGradientBackground(pLayBg)
	
	--等级
	self.pLbLevel    = self:findViewByName("lb_lv")
	setTextCCColor(self.pLbLevel, _cc.green)

	--可获得..黄金
	self.pLbCanget	= MUI.MLabel.new({text = "", size = 20})
	self.pLayRoot:addView(self.pLbCanget, 10)
	self.pLbCanget:setPosition(120, 40)

	--未达到或未购买图片
	self.pImgNotGet  = self:findViewByName("img_notget")

	self.pLayGetBtn = self:findViewByName("lay_btn")
	--领取按钮
	self.pGetBtn = getCommonButtonOfContainer(self.pLayGetBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	self.pGetBtn:onCommonBtnClicked(handler(self, self.onGetBtnClicked))

	--奖励图标层
	self.pLayIcon    = self:findViewByName("lay_icon")

	--组合文字(主公等级/到达等级)
	local tConTable = {}
	--文本
	tConTable.tLabel= {
		{Player:getPlayerInfo().nLv, getC3B(_cc.green)},
		{"/", getC3B(_cc.pwhite)},
		{30, getC3B(_cc.pwhite)},
	}
	tConTable.fontSize = 22
	self.pLevelText = self.pGetBtn:setBtnExText(tConTable) --createGroupText(tConTable)
	
	self.pGetBtn:setVisible(false)
	self.pLevelText:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function NewItemGrowFound:updateViews()
	if not self.tCurData then return end

	local nReachLv = self.tCurData.lv
	self.pLbLevel:setString(nReachLv)
	local roleLv = Player:getPlayerInfo().nLv

    --奖励显示
    local tAward = self.tCurData.ob[1]
    local tAwData = getItemResourceData(tAward.k)
    tAwData.nCt = tAward.v
    getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, tAwData, TypeIconEquipSize.M)

    local str = {
    	{text = getConvertedStr(7, 10288), color = _cc.pwhite}, --可获得
    	{text = tAward.v, color = _cc.yellow},
    	{text = getConvertedStr(7, 10036), color = _cc.pwhite} --黄金
	}
    self.pLbCanget:setString(str)

    self.pImgNotGet:setVisible(false)
    self.pGetBtn:removeLingTx()

    --如果已领取
    if self.tCurData.nGet == 1 then
		self.pGetBtn:setVisible(true)
		self.pGetBtn:updateBtnText(getConvertedStr(7, 10087))
		self.pGetBtn:setBtnEnable(false)
    else
	    --未购买
	    if not self.bBuyed then
	    	self.pImgNotGet:setCurrentImage("#v2_fonts_weigoumai.png")
	    	self.pImgNotGet:setVisible(true)
	    	self.pGetBtn:setVisible(false)
	    elseif self.bBuyed then
	    	if roleLv >= nReachLv then
	    		self.pGetBtn:setVisible(true)
	    		self.pGetBtn:updateBtnText(getConvertedStr(7, 10086))
	    		self.pGetBtn:showLingTx()
				self.pGetBtn:setBtnEnable(true)
	    	else
	    		self.pGetBtn:setVisible(false)
	    		self.pImgNotGet:setCurrentImage("#v2_fonts_weidadao.png")
	    		self.pImgNotGet:setVisible(true)
	    	end
	    end

    end

    if self.bBuyed then
	    self.pLevelText:setLabelCnCr(1, roleLv)
	    self.pLevelText:setLabelCnCr(3, nReachLv)
		self.pLevelText:setVisible(true)
	else
		self.pLevelText:setVisible(false)
	end
end

--领取奖励按钮回调
function NewItemGrowFound:onGetBtnClicked( pView )
	-- body
	if not self.bIsGetting then
		SocketManager:sendMsg("reqGetNewFoundsAwards", {self.tCurData.id, self.nBelongVip}, function(__msg)
			-- body
			-- dump(__msg.body, "领取成长基金奖励 ==")
			if __msg.head.state == SocketErrorType.success then
				showGetAllItems(__msg.body.ob, 1)
			end
			self.bIsGetting = false
		end)
	end
	self.bIsGetting = true
end

-- 析构方法
function NewItemGrowFound:onNewItemGrowFoundDestroy()
	-- body
end

-- 设置单项数据
--_nVip:属于vip几的奖励
function NewItemGrowFound:setItemData(_data, _bBuy, _nVip)
  	self.tCurData = _data
	self.bBuyed = _bBuy
	self.nBelongVip = _nVip
	self:updateViews()
end



return NewItemGrowFound