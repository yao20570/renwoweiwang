
-- Author: liangzhaowei
-- Date: 2017-05-04 17:09:22
-- 招募英雄详情

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemShogunSigleHero = require("app.layer.shogun.ItemShogunSigleHero")
local ItemBuyHeroInfo = class("ItemBuyHeroInfo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_pData 英雄数据
function ItemBuyHeroInfo:ctor(_pData)
	-- body
	self:myInit()

	self.pData  = _pData or {}

	parseView("item_fuben_buy_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemBuyHeroInfo",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemBuyHeroInfo:myInit()
	self.pData = {} -- 英雄数据
end

--解析布局回调事件
function ItemBuyHeroInfo:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--lb
	self.pLbTitle = self:findViewByName("lb_title")
	-- self.pLbEx = self:findViewByName("lb_ex")
	-- self.pLbEx:setZOrder(11)
	-- setTextCCColor(self.pLbEx, _cc.green)

	self.tLbBaseHeroInfo = {} --英雄基本资质
	for i=1,4 do
		self.tLbBaseHeroInfo[i] = self:findViewByName("lb_baseinfo_"..i)
	end

	--ly
	self.pLyHero = self:findViewByName("ly_hero")
	self.pLyHero:setZOrder(11)
	self.tBaseBar = {} --英雄基本资质进度条
	for i=1,4 do
		local pLyBar = self:findViewByName("ly_bar_"..i)
		local pBarImg = "v1_bar_green_4.png"
		if i == 1 then
			pBarImg = "v1_bar_yellow_6.png"
		end
		self.tBaseBar[i] = MCommonProgressBar.new({bar = pBarImg, barWidth = 79, barHeight = 8})
		pLyBar:addView(self.tBaseBar[i],100)
		centerInView(pLyBar,self.tBaseBar[i])
	end

	self.pImgBg = self:findViewByName("img_bg")


	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemBuyHeroInfo:setupViews()
	if not self.pData then
		return 
	end
	-- self.pLbTitle:setString(self.pData.sName)

	--创建icon
	-- if not self.pIcon then
	-- 	self.pIcon = getIconHeroByType(self.pLyHero, TypeIconHero.NORMAL, self.pData, TypeIconHeroSize.L)
	-- end
	--创建武将半身像
	if not self.pHeroView then
		local nType = 1
		self.pHeroView = ItemShogunSigleHero.new(nType)
		self.pLyHero:addView(self.pHeroView, 10)
		--设置为已拥有状态
		self.pData.nHave = 1
		self.pHeroView:setCurData(self.pData)
	end

end

-- 修改控件内容或者是刷新控件数据
function ItemBuyHeroInfo:updateViews(  )
	local pImgStr = getHeroGetBgByQuality(self.pData.nQuality)
	self.pImgBg:setCurrentImage(pImgStr, {scale9 = true, capInsets=cc.rect(59,179, 1, 1)})

	local nNum1 = self.pData:getNowTotalTalent()
	local nNum2 = self.pData.nTa 
	local nNum3 = self.pData.nTd
	local nNum4 = self.pData.nTr 


	local nExNums = 0
	if nNum1 == 0 then
		nNum1 = self.pData:getBaseTotalTalent()
		nExNums = self.pData:getTotalBaseTalent() -self.pData:getBaseTotalTalent()
	else
		nNum1 = self.pData:getBaseTotalTalent()
		nExNums = self.pData:getNowTotalTalent() -self.pData:getBaseTotalTalent()
	end

	--初始总攻资质
	if nNum2 == 0 then
		nNum2 = self.pData.nBaseTalentAtk + self.pData.nInitTrainTalentAtk
	end

	--初始总防
	if nNum3 == 0 then
		nNum3 = self.pData.nBaseTalentDef + self.pData.nInitTrainTalentDef
	end

	--初始总兵
	if nNum4 == 0 then
		nNum4 = self.pData.nBaseTalentTrp + self.pData.nInitTrainTalentTrp
	end


	--基础资质
	for k,v in pairs(self.tLbBaseHeroInfo) do
		local str = ""
		if k == 1 then --总资质
			str = str..nNum1 
		elseif k== 2 then --攻
			str = str..nNum2 
		elseif k== 3 then --防
			str = str..nNum3 
		elseif k== 4 then --兵
			str = str..nNum4 
		end
		v:setString(str,false)
	end


	-- if nExNums > 0 then
		-- self.pLbEx:setString("+"..nExNums)
		-- self.pLbEx:setVisible(true)
		-- self.pLbEx:setPositionX(self.tLbBaseHeroInfo[1]:getWidth()+self.tLbBaseHeroInfo[1]:getPositionX())
	-- else
		-- self.pLbEx:setVisible(false)
	-- end

	--资质进度条
	for k,v in pairs(self.tBaseBar) do
		local nCld = 0
		local nPar = 1
		if k == 1 then --总资质
			nCld = nNum1
			nPar = self.pData.nTalentLimitSum
		elseif k== 2 then --攻
			nCld = nNum2 
			nPar = self.pData.nTalentLimitAtk
		elseif k== 3 then --防
			nCld = nNum3
			nPar = self.pData.nTalentLimitDef
		elseif k== 4 then --兵
			nCld = nNum4
			nPar = self.pData.nTalentLimitTrp
		end
		v:setPercent(nCld/nPar*100)
	end


end

--析构方法
function ItemBuyHeroInfo:onDestroy(  )
	-- body
end

--设置数据 _tData
function ItemBuyHeroInfo:setCurData(_tData)

end


return ItemBuyHeroInfo