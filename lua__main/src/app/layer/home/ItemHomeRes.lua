-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-17 14:55:41 星期三
-- Description: 资源Item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local res_type = {
	coin = 1,
	wood = 2,
	food = 3,
	iron = 4,
}

local nNumJumpZorder = 99

local ItemHomeRes = class("ItemHomeRes", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemHomeRes:ctor( nType )
	-- body
	self:myInit()
	self.nType = nType or self.nType
	parseView("item_home_res", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemHomeRes:myInit(  )
	-- body
	self.nType 					= 	 		1 --类型
end

--解析布局回调事件
function ItemHomeRes:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemHomeRes",handler(self, self.onItemHomeResDestroy))
end

--初始化控件
function ItemHomeRes:setupViews( )
	-- body
	--图片
	self.pImg 			= 		self:findViewByName("img")
	--数量
	self.pLbValue 		= 		self:findViewByName("lb_value")
	setTextCCColor(self.pLbValue,_cc.dblue)

	if self.nType == res_type.coin then
		self.pImg:setCurrentImage("#v1_img_tongqian.png")
	elseif self.nType == res_type.wood then
		self.pImg:setCurrentImage("#v1_img_mucai.png")
	elseif self.nType == res_type.food then
		self.pImg:setCurrentImage("#v1_img_liangshi.png")
	elseif self.nType == res_type.iron then
		self.pImg:setCurrentImage("#v1_img_tiekuai.png")
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemHomeRes:updateViews(  )
	-- body
	self:updateValue()
end

-- 析构方法
function ItemHomeRes:onItemHomeResDestroy(  )
	-- body
end

--设置值
function ItemHomeRes:updateValue(  )
	-- body
	if self.nType == res_type.coin then
		self.pLbValue:setString(getResourcesStr(Player:getPlayerInfo().nCoin))

		--资源跳字
		-- if self.nPrevCoin then
		-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nCoin - self.nPrevCoin)
		-- 	if pLayArm then
		-- 		pLayArm:setPosition(60, 0)
		-- 		self:addView(pLayArm, nNumJumpZorder)
		-- 	end
		-- end
		-- self.nPrevCoin = Player:getPlayerInfo().nCoin

	elseif self.nType == res_type.wood then
		self.pLbValue:setString(getResourcesStr(Player:getPlayerInfo().nWood))

		-- --资源跳字
		-- if self.nPrevFood then
		-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nFood - self.nPrevFood)
		-- 	if pLayArm then
		-- 		pLayArm:setPosition(60, 0)
		-- 		self:addView(pLayArm, nNumJumpZorder)
		-- 	end
		-- end
		-- self.nPrevFood = Player:getPlayerInfo().nFood

	elseif self.nType == res_type.food then
		self.pLbValue:setString(getResourcesStr(Player:getPlayerInfo().nFood))

		-- --资源跳字
		-- if self.nPrevWood then
		-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nWood - self.nPrevWood)
		-- 	if pLayArm then
		-- 		pLayArm:setPosition(60, 0)
		-- 		self:addView(pLayArm, nNumJumpZorder)
		-- 	end
		-- end
		-- self.nPrevWood = Player:getPlayerInfo().nWood
	elseif self.nType == res_type.iron then
		self.pLbValue:setString(getResourcesStr(Player:getPlayerInfo().nIron))

		-- --资源跳字
		-- if self.nPrevIron then
		-- 	local pLayArm = showNumJump(Player:getPlayerInfo().nIron - self.nPrevIron)
		-- 	if pLayArm then
		-- 		pLayArm:setPosition(60, 0)
		-- 		self:addView(pLayArm, nNumJumpZorder)
		-- 	end
		-- end
		-- self.nPrevIron = Player:getPlayerInfo().nIron
	end
end

--获取文本
function ItemHomeRes:getResText(  )
	return self.pLbValue
end

--获取图片
function ItemHomeRes:getResImg(  )
	return self.pImg
end

--设置播放资源动画
function ItemHomeRes:playGetItem(  )

	-- if not self.pImgGetItem then
	-- 	local sImg = "#v1_img_liangshi.png"
	-- 	if self.nType == res_type.coin then
	-- 		sImg = "#v1_img_tongqian.png"
	-- 	elseif self.nType == res_type.wood then
	-- 		sImg = "#v1_img_mucai.png"
	-- 	elseif self.nType == res_type.food then
	-- 		sImg = "#v1_img_liangshi.png"
	-- 	elseif self.nType == res_type.iron then
	-- 		sImg = "#v1_img_tiekuai.png"
	-- 	end
	-- 	self.pImgGetItem = MUI.MImage.new(sImg)
	-- 	local fX =self.pImgGetItem:getContentSize().width/2
	-- 	local fY = self.pImgGetItem:getContentSize().height/2
	-- 	self.pImgGetItem:setPosition(fX, fY)
	-- 	self.pImg:addChild(self.pImgGetItem)
	-- 	self.pImgGetItem:setBlendFunc(MUI.GL_ONE, MUI.GL_ONE)
	-- end
	-- 时间      缩放     透明度   是否加亮
	-- 0秒       100%      100%       是
	-- 0.08秒    138%       60%       是
	-- 0.33秒    88%         0%       是
	self.pImgGetItem = self.pImg
	self.pImgGetItem:setScale(1)
	local pSeqAct = cc.Sequence:create({
			cc.ScaleTo:create(0, 0.9),
			cc.ScaleTo:create(0.05, 1.25),
			cc.ScaleTo:create(0.10, 0.95),
			cc.ScaleTo:create(0.13, 1.03),
			cc.ScaleTo:create(0.16, 1.00),
    	})
	self.pImgGetItem:runAction(pSeqAct)
end


return ItemHomeRes