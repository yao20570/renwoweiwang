-- ItemGrowFound.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-28 17:03:23 星期三
-- Description: 成长基金列表项
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemGrowFound = class("ItemGrowFound", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemGrowFound:ctor(_index)
	-- body	
	self:myInit(_index)	
	parseView("item_funds", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemGrowFound:myInit(_index)
	-- body
	self.idx = _index
	self.tCurData  = nil 				--当前数据
	self.bBuyed    = nil                --是否已购买基金
end

--解析布局回调事件
function ItemGrowFound:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemGrowFound",handler(self, self.onItemGrowFoundDestroy))
end

--初始化控件
function ItemGrowFound:setupViews()
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

	--未达到或未购买图片
	self.pImgNotGet  = self:findViewByName("img_notget")

	self.pLayGetBtn = self:findViewByName("lay_btn")
	--领取按钮
	self.pGetBtn = getCommonButtonOfContainer(self.pLayGetBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10086))
	self.pGetBtn:onCommonBtnClicked(handler(self, self.onGetBtnClicked))
	self.pGetBtn:setVisible(false)

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
	tConTable.fontSize = 20
	self.pLevelText =  createGroupText(tConTable)
	self.pLevelText:setAnchorPoint(cc.p(0.5, 0.5))
	self.pLayRoot:addView(self.pLevelText, 10)
	self.pLevelText:setPosition(125, 35)
end

-- 修改控件内容或者是刷新控件数据
function ItemGrowFound:updateViews()
	if not self.tCurData then return end
	local nReachLv = self.tCurData.lv
	self.pLbLevel:setString(nReachLv)
	setTextCCColor(self.pLbLevel, _cc.yellow)

	local roleLv = Player:getPlayerInfo().nLv
    self.pLevelText:setLabelCnCr(1, roleLv)
    self.pLevelText:setLabelCnCr(3, nReachLv)

    --奖励显示
    local tAward = self.tCurData.award[1]
    local tAwData = getItemResourceData(tAward.k)
    tAwData.nCt = tAward.v
    getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.itemnum, tAwData, TypeIconEquipSize.M)

    self.pImgNotGet:setVisible(false)

    --如果已领取
    if self.tCurData.nGet == 1 then
		self.pGetBtn:setVisible(true)
		self.pGetBtn:updateBtnText(getConvertedStr(7, 10087))
		self.pGetBtn:setBtnEnable(false)
    	return
    end

    --未购买
    if not self.bBuyed then
    	self.pImgNotGet:setCurrentImage("#v2_fonts_weigoumai.png")
    	self.pImgNotGet:setVisible(true)
    elseif self.bBuyed then
    	if roleLv >= nReachLv then
    		self.pGetBtn:setVisible(true)
    		self.pGetBtn:updateBtnText(getConvertedStr(7, 10086))
			self.pGetBtn:setBtnEnable(true)
    	else
    		self.pGetBtn:setVisible(false)
    		self.pImgNotGet:setCurrentImage("#v2_fonts_weidadao.png")
    		self.pImgNotGet:setVisible(true)
    	end
    end
end

--领取奖励按钮回调
function ItemGrowFound:onGetBtnClicked( pView )
	-- body
	if not self.bIsGetting then
		SocketManager:sendMsg("reqGetFoundsAwards", {self.tCurData.id}, function(__msg)
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
function ItemGrowFound:onItemGrowFoundDestroy()
	-- body
end

-- 设置单项数据
function ItemGrowFound:setItemData(_data, _bBuy)
  	self.tCurData = _data
	self.bBuyed = _bBuy
	self:updateViews()
end



return ItemGrowFound