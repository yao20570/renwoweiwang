-- Author: xiesite
-- Date: 2017-11-10 10:58:23
-- 武将队列item

local MCommonView = require("app.common.MCommonView")
local MRichLabel = require("app.common.richview.MRichLabel")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")

local ItemHeroInfo = class("ItemHeroInfo", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_index 下标  _tData 数据, isAddGod是否需要额外添加神将属性
--_isShowAttr 显示的是属性
function ItemHeroInfo:ctor(_tData, _tExData, _bIsAddGod, _isShowAttr)
	-- body
	self:myInit()

	self.tData = _tData
	self.tExData = _tExData or {}
	self.nExAtk = self.tExData[1] or 0
	self.nExDef = self.tExData[2] or 0
	self.nExTrp = self.tExData[3] or 0
	self.nExTotal = self.nExAtk + self.nExDef + self.nExTrp
	self.nIndex = _index or self.nIndex
	self.bIsAddGod = _bIsAddGod or false
	self.bShowAttr = _isShowAttr or false

	parseView("item_hero_info", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroInfo",handler(self, self.onDestroy))
end

--初始化参数
function ItemHeroInfo:myInit()
	-- body
	self.tData = {} --数据

end

--解析布局回调事件
function ItemHeroInfo:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())

	self:addView(pView)
	centerInView(self, pView)
 

	self:setupViews()
	self:updateViews()

end

--初始化控件
function ItemHeroInfo:setupViews( )
    local pView = self.pItemView
    local ly_frame = pView:getChildByName("ly_frame")

	self.pLyImg = pView:getChildByName("ly_img")

	self.pImgType = ly_frame:getChildByName("img_type")
	self.pLbName = ly_frame:getChildByName("lb_name")
	self.pImgFrame = ly_frame:getChildByName("img_frame")
	self.pImgGod = ly_frame:getChildByName("img_god")
	self.pImgGod:setVisible(false)

	self.pLayStars = ly_frame:getChildByName("lay_stars")
    self.tStars = {} --英雄星星
	for i=1,5 do
		local pImgStar = self.pLayStars:getChildByName("img_star"..i)
		self.tStars[i] = pImgStar
	end

    self.LyAttr =  ly_frame:getChildByName("ly_attr")
	self.tAttrValueLbs = {}	--属性栏基础属性
	self.tAttrValueAddLbs = {}--属性栏额外属性
	for i=1,3 do
		local lyAttrBar = self.LyAttr:getChildByName("ly_attr_bar"..i)

		local pLbAttr = lyAttrBar:getChildByName("lb_attr_"..i)
		pLbAttr:setString(getConvertedStr(5, 10024+i))

        local pLbAttrValue = lyAttrBar:getChildByName("lb_attr_value_"..i)
		self.tAttrValueLbs[i] = pLbAttrValue

        local pLbAttrAddValue = lyAttrBar:getChildByName("lb_attr_value_add_"..i)
		self.tAttrValueAddLbs[i] = pLbAttrAddValue
		setTextCCColor(pLbAttrAddValue, _cc.green)
	end
    
    self.LyTalent =  ly_frame:getChildByName("ly_talent")
    self.tLyBar = {} --英雄
	self.tLbBaseHeroInfo = {} --英雄基本资质
    self.tBaseBar = {} --英雄基本资质进度条
	self.tBaseValueLb = {} --英雄基本资质
    self.tBaseValueAddLb = {} --英雄资质增长值
    self.tArrow = {} --增长箭头
	for i=1,4 do
		local ly_bar = self.LyTalent:getChildByName("ly_bar"..i)
		self.tLyBar[i] = ly_bar
                
        local sStr = getConvertedStr(5, 10020+i-1)
        self.tLbBaseHeroInfo[i] = ly_bar:getChildByName("lb_info_n_"..i)
        self.tLbBaseHeroInfo[i]:setString(sStr);

        local pLyBar = ly_bar:getChildByName("bar_"..i)
		local pBarImg = "v2_bar_yellow_wjjj.png"
		self.tBaseBar[i] = MCommonProgressBar.new({bar = pBarImg, barWidth = 93, barHeight = 13})
		pLyBar:addView(self.tBaseBar[i],100)
		centerInView(pLyBar,self.tBaseBar[i])

        local pLbValue = ly_bar:getChildByName("lb_value_"..i)
		self.tBaseValueLb[i] = pLbValue

        local pLbValueAdd = ly_bar:getChildByName("lb_value_add_"..i)
		self.tBaseValueAddLb[i] = pLbValueAdd
		self.tBaseValueAddLb[i]:setVisible(false) --默认不显示
		setTextCCColor(pLbValueAdd, _cc.green)

        local pImgArrow = ly_bar:getChildByName("img_arrow_"..i)
		self.tArrow[i] = pImgArrow
		self.tArrow[i]:setVisible(false) --默认不显示
	end

--	for i=1,4 do
--		self.tLbBaseHeroInfo[i] = self:findViewByName("lb_info_n_"..i)
--		local sStr = getConvertedStr(5, 10020+i-1)
--		self.tLbBaseHeroInfo[i]:setString(sStr);
--	end

    

	
--	self.tBaseBar = {} --英雄基本资质进度条
--	for i=1,4 do
--		local pLyBar = self:findViewByName("bar_"..i)
--		local pBarImg = "v2_bar_yellow_wjjj.png"
--		self.tBaseBar[i] = MCommonProgressBar.new({bar = pBarImg, barWidth = 93, barHeight = 13})
--		pLyBar:addView(self.tBaseBar[i],100)
--		centerInView(pLyBar,self.tBaseBar[i])
--	end
    

--	self.tBaseValueLb = {} --英雄基本资质
--	for i=1,4 do
--		local pLbValue = self:findViewByName("lb_value_"..i)
--		self.tBaseValueLb[i] = pLbValue
--	end
    

--	self.tBaseValueAddLb = {} --英雄资质增长值
--	for i=1,4 do
--		local pLbValueAdd = self:findViewByName("lb_value_add_"..i)
--		self.tBaseValueAddLb[i] = pLbValueAdd
--		self.tBaseValueAddLb[i]:setVisible(false) --默认不显示
--		setTextCCColor(pLbValueAdd, _cc.green)
--	end
    

--	self.tArrow = {} --增长箭头
--	for i=1,4 do
--		local pImgArrow = self:findViewByName("img_arrow_"..i)
--		self.tArrow[i] = pImgArrow
--		self.tArrow[i]:setVisible(false) --默认不显示
--	end	
    

--	self.tStars = {} --英雄星星
--	for i=1,5 do
--		local pImgStar = self:findViewByName("img_star"..i)
--		self.tStars[i] = pImgStar
--	end
    

--	self.LyAttr =  self:findViewByName("ly_attr")
--	--属性栏属性名称
--	self.tAttrLbs = {}
--	for i=1,3 do
--		local pLbAttr = self:findViewByName("lb_attr_"..i)
--		pLbAttr:setString(getConvertedStr(5, 10024+i))
--	end
	    

--	--属性栏基础属性
--	self.tAttrValueLbs = {}
--	for i=1,3 do
--		local pLbAttrValue = self:findViewByName("lb_attr_value_"..i)
--		self.tAttrValueLbs[i] = pLbAttrValue
--	end	
    

--	--属性栏额外属性
--	self.tAttrValueAddLbs = {}
--	for i=1,3 do
--		local pLbAttrAddValue = self:findViewByName("lb_attr_value_add_"..i)
--		self.tAttrValueAddLbs[i] = pLbAttrAddValue
--		setTextCCColor(pLbAttrAddValue, _cc.green)
--	end	
    

--	self.pImgType = self:findViewByName("img_type")
--	self.pLbName = self:findViewByName("lb_name")
--	self.pImgFrame = self:findViewByName("img_frame")
--	self.pLyImg = self:findViewByName("ly_img")
--	self.pImgGod = self:findViewByName("img_god")
--	self.pImgGod:setVisible(false)

--	self.pLayStars = self:findViewByName("lay_stars")    

end

function ItemHeroInfo:updateStars()
	if not self.tData then
		return
	end
	local tSoulStar = self.tData.tSoulStar
	local nStar = tSoulStar.nSolidNum + tSoulStar.nHollowNum
	for i=1, 5 do
		if nStar < i then
			self.tStars[i]:setVisible(false)
		else
			self.tStars[i]:setVisible(true)
		end
		if i <= tSoulStar.nSolidNum then --实心
			self.tStars[i]:setCurrentImage("#v1_img_star5a.png")
		else 								--空心
			self.tStars[i]:setCurrentImage("#v1_img_star5b.png")
		end
	end
end


-- 修改控件内容或者是刷新控件数据
function ItemHeroInfo:updateViews(  )
	if not self.tData then
		return
	end
	if self.nIg or self.bIsAddGod then
		self.pImgGod:setVisible(true)
	else
		self.pImgGod:setVisible(false)
	end

 	--更新星级
	self:updateStars()
	--更新类型图标
	local strBingTypeImg = self.tData:getHeroKindImg(3)
	if strBingTypeImg then
		self.pImgType:setCurrentImage(strBingTypeImg)
	end
	--设置名字
	local nMaxNum = 4 --string.utf8len(self.tData.sName)
	-- if nMaxNum >= 4 then
	-- 	nMaxNum = 4
	-- end
	self.pLbName:setDimensions(24, 28 * nMaxNum)
	self.pLbName:setString(self.tData.sName)
	self.pLayStars:setPositionY(self.pLbName:getPositionY()-self.pLbName:getHeight() - self.pLayStars:getHeight()+20)
	if self.bShowAttr then
		self:showAttrs()
	else 
		self:showTalents()
	end

	--设置资质框
	local qualityPath = self.tData:getFrameByQuality()
	self.pImgFrame:setCurrentImage(qualityPath)
	--截图
	local tCutInfo =  self.tData:getCutInfo()
	local heroView = creatHeroDIYView(self.tData.sImg, cc.p(tCutInfo[1],tCutInfo[2]), tCutInfo[3], 1)
    --local heroView = creatHeroView(self.tData.sImg, 2)

	self.pLyImg:addChild(heroView)

end

-- 上阵按钮回调
function ItemHeroInfo:setHandler(_handler)
	-- body
	if _handler then
		self.pHandler = _handler
	end
end

--开启提示箭头
function ItemHeroInfo:showAddArrow(_data)
	if _data then
		for i = 1, 4 do
			if _data[i] and _data[i] > 0 then
				self.tArrow[i]:setVisible(true)
			else
				self.tArrow[i]:setVisible(false)
			end
		end
	else
		for i = 1, 4 do
			self.tArrow[i]:setVisible(false)
		end
	end
end

function ItemHeroInfo:hideAddArrow(_data)
	if self.tArrow then
		for i = 1, 4 do
			self.tArrow[i]:setVisible(false)
		end
	end
end

--析构方法
function ItemHeroInfo:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemHeroInfo:setCurData(_tData, _tExData)
	if not _tData then
		return
	end

	self.tData = _tData or {}
	self.tExData = _tExData or {}
	self.nExAtk = self.tExData[1] or 0
	self.nExDef = self.tExData[2] or 0
	self.nExTrp = self.tExData[3] or 0
	self.nExTotal = self.nExAtk + self.nExDef + self.nExTrp
end

function ItemHeroInfo:showAttrs()
	self.LyTalent:setVisible(false)
	self.LyAttr:setVisible(true)

	for i=1,3 do
		self.tAttrValueAddLbs[i]:setVisible(false)
	end	

	if self.bIsAddGod then
		local tAtts = luaSplit(getHeroInitData("godAttrs"), ";")
		for k,v in pairs(tAtts) do
			local tInfo = luaSplit(v, ":")
			if tonumber(tInfo[1]) == e_id_hero_att.gongji then
				self.tAttrValueAddLbs[1]:setVisible(true)
				self.tAttrValueAddLbs[1]:setString("+"..tonumber(tInfo[2]))

			elseif tonumber(tInfo[1]) == e_id_hero_att.fangyu then
				self.tAttrValueAddLbs[2]:setVisible(true)
				self.tAttrValueAddLbs[2]:setString("+"..tonumber(tInfo[2]))

			elseif tonumber(tInfo[1]) == e_id_hero_att.bingli then
				self.tAttrValueAddLbs[3]:setVisible(true)
				self.tAttrValueAddLbs[3]:setString("+"..tonumber(tInfo[2]))
			end
		end
	end

	for i=1,3 do
		local nVal = 0
		if i == 1 then
			nVal = self.tData.tAttDict[e_id_hero_att.gongji].nVal
		elseif i == 2 then
			nVal = self.tData.tAttDict[e_id_hero_att.fangyu].nVal 
		elseif i == 3 then
			nVal = self.tData.tAttDict[e_id_hero_att.bingli].nVal
		end
		self.tAttrValueLbs[i]:setString(nVal)
	end
end

function ItemHeroInfo:showTalents()

	self.LyTalent:setVisible(true)
	self.LyAttr:setVisible(false)

	for i=1,4 do
		self.tArrow[i]:setVisible(false) --默认不显示
	end	

	-- body
	local nExGodT = 0
	local nExGodA = 0
	local nExGodD = 0
	local nExGodR = 0

	nExGodT = nExGodA + nExGodD + nExGodR

	local nNum1 = self.tData:getNowTotalTalent()
	local nNum2 = self.tData.nTa 
	local nNum3 = self.tData.nTd
	local nNum4 = self.tData.nTr 
	local nExNums = 0
	if nNum1 == 0 then
		nNum1 = self.tData:getBaseTotalTalent()
		nExNums = self.tData:getTotalBaseTalent() -self.tData:getBaseTotalTalent() + self.nExTotal
	else
		nNum1 = self.tData:getBaseTotalTalent() 
		nExNums = self.tData:getNowTotalTalent() - self.tData:getBaseTotalTalent() + self.nExTotal
	end
	
	--初始总攻资质
	if nNum2 == 0 then
		nNum2 = self.tData.nBaseTalentAtk + self.tData.nInitTrainTalentAtk
	end
	nNum2 = nNum2 + self.nExAtk + nExGodA

	--初始总防
	if nNum3 == 0 then
		nNum3 = self.tData.nBaseTalentDef + self.tData.nInitTrainTalentDef
	end
	nNum3 = nNum3 + self.nExDef + nExGodD

	--初始总兵
	if nNum4 == 0 then
		nNum4 = self.tData.nBaseTalentTrp + self.tData.nInitTrainTalentTrp
	end
	nNum4 = nNum4 + self.nExTrp + nExGodR


	--基础资质
	for k,v in pairs(self.tBaseValueLb) do
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

	--额外资质
	if nExNums > 0 then
		local pLbEx = self.tBaseValueAddLb[1]
		pLbEx:setString("+"..nExNums)
		pLbEx:setVisible(true)
	else
		self.tBaseValueAddLb[1]:setVisible(false)
	end

	--资质进度条
	for k,v in pairs(self.tBaseBar) do
		local nCld = 0
		local nPar = 1
		if k == 1 then --总资质
			nCld = nNum1
			nPar = self.tData.nTalentLimitSum
		elseif k== 2 then --攻
			nCld = nNum2 
			nPar = self.tData.nTalentLimitAtk
		elseif k== 3 then --防
			nCld = nNum3
			nPar = self.tData.nTalentLimitDef
		elseif k== 4 then --兵
			nCld = nNum4
			nPar = self.tData.nTalentLimitTrp
		end
		v:setPercent(nCld/nPar*100)
	end
end

--_view废弃的view
--_cb特效播放完后的回调函数
--_end是否进阶完成
function ItemHeroInfo:showAdvanceTX(_view, _cb, _end)
	local sName = createAnimationBackName("tx/exportjson/", "sg_wjjj_kpgx_001")
	local pArm = ccs.Armature:create(sName)

	self:addChild(pArm,10)
	pArm:setPosition(cc.p(125,200))
	pArm:getAnimation():play("Animation1", 1)
	self:showAdvanceImage()

	pArm:getAnimation():setFrameEventCallFunc(function ( pBone, frameEventName ) 
		if frameEventName == "ydzsj001" then
			action1 = cc.MoveBy:create(0.25,cc.p(7,0))
			action2 = cc.MoveBy:create(0.25,cc.p(-300,0))
			action3 = cc.MoveBy:create(0.15,cc.p(3,0))
			if not _end then
				action1 = cc.MoveBy:create(0.25,cc.p(7,0))
				action2 = cc.MoveBy:create(0.25,cc.p(-300,0))
				action3 = cc.MoveBy:create(0.15,cc.p(3,0))
			else
				action1 = cc.MoveBy:create(0.25,cc.p(7,0))
				action2 = cc.MoveBy:create(0.25,cc.p(-154,0))
				action3 = cc.MoveBy:create(0.15,cc.p(3,0))
			end
			local actions = nil
			if _cb then
				actions = cc.Sequence:create(action1,action2,action3,cc.CallFunc:create(function() _cb() end))
			else
				actions = cc.Sequence:create(action1,action2,action3)
			end
			self:runAction(actions)
			if _view then
				local action4 = cc.DelayTime:create(0.3)
				local action5 = cc.MoveBy:create(0.25,cc.p(-350,0))
				local actions2 = cc.Sequence:create(action4,action5)

				_view:setToGray(true)
				_view:runAction(actions2)
			end			
		end

	end) 
end

function ItemHeroInfo:fadeIn()
	local action = cc.FadeIn:create(0.3)
	self:runAction(action)
end

--获得一张图片
--nType :1闪避 2：暴击
function ItemHeroInfo:showAdvanceImage()
	-- body
	local sNameImg = "#v1_fonts_jinjiechenggong.png"
	local pImg = MUI.MImage.new(sNameImg)
	self:addView(pImg)
	pImg:setPosition(cc.p(125,160))
	local action1 = cc.MoveBy:create(0.65,cc.p(0,100))
	pImg:runAction(cc.Sequence:create(action1,cc.CallFunc:create(function() pImg:removeFromParent(true) end)))
end

return ItemHeroInfo