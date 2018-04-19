-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-05-25 11:17:53
-- Description: 英雄基础参数界面
-----------------------------------------------------
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local MRichLabel = require("app.common.richview.MRichLabel")

local DlgHeroParameter = class("DlgHeroParameter", function()
	return DlgCommon.new(e_dlg_index.dlgheroparameter)
end)

function DlgHeroParameter:ctor(_tData)
	-- body
	self:myInit()
	self.tHeroData = _tData 

	self:initData()
	self:setTitle(getConvertedStr(5, 10015))
	parseView("dlg_hero_parameter", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroParameter:myInit(  )
	-- body
	self.tHeroData = nil --英雄数据
	self.pRichViewTips1 = nil --富文本1
	self.pRichViewTips2 = nil --富文本2
end

--初始化数据
function DlgHeroParameter:initData()

	if not self.tHeroData then
       return
	end

end

--解析布局回调事件
function DlgHeroParameter:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView

	-- local fScale = 0.8
	-- local pVg = MUI.MLayer.new()
	-- pVg:setContentSize(pView:getContentSize())
	-- pView:setScale(0.8)
	-- pVg:addView(pView)
	-- centerInView(pVg,pView)
	-- pParentView:addView(pVg)



	self:addContentView(pView) --加入内容层

	-- self.pSelectView:setScale(0.86)
	-- self:addContentView(self.pSelectView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroParameter",handler(self, self.onDestroy))
end

--初始化控件
function DlgHeroParameter:setupViews( )

	--ly-----------------------------------
	self.pLyContent = self:findViewByName("ly_content") --内容层


		--等级进度条 
	self.pLyLvBg				= 		self:findViewByName("ly_bar_1")
	self.pBarLv 				= 		MCommonProgressBar.new({bar = "v1_bar_yellow_4.png",barWidth = 108, barHeight = 8})
	self.pLyLvBg:addView(self.pBarLv,100)
	centerInView(self.pLyLvBg,self.pBarLv)

	self.pLyContent:setAnchorPoint(0,0)
	self.pLyContent:setPosition(4,0)

		--资质数据显示
	self.tTalentInfo = {}
	for i=1,3 do
		local pView = self:findViewByName("ly_att_"..i)
		self.tTalentInfo[i] = ItemHeroInfoLb.new(i)
		pView:addView(self.tTalentInfo[i],100)
	end
	


	self.tEquipIcon = {}
	for i=1,6 do
		local pLyEquip = self:findViewByName("ly_equip_"..i)
		pLyEquip:setZOrder(2)
		self.tEquipIcon[i] = getIconEquipByType(pLyEquip, TypeIconEquip.ADD, i, nil, TypeIconGoodsSize.L)
	end

	--lb--------------------------------
	self.pLHeroName = self:findViewByName("lb_hero_name") --英雄名字
	self.pLHeroName:setZOrder(99)


	--纯文字
	self.pLbL1 = self:findViewByName("lb_l_1") --
	self.pLbL2 = self:findViewByName("lb_l_2") --
	self.pLbL3 = self:findViewByName("lb_l_3") --
	self.pLbL4 = self:findViewByName("lb_l_4") --

	self.pLbM1 = self:findViewByName("lb_m_1") -- 攻资质
	self.pLbM2 = self:findViewByName("lb_m_2") -- 防资质
	self.pLbM3 = self:findViewByName("lb_m_3") -- 兵资质
	setTextCCColor(self.pLbM1, _cc.blue)
	setTextCCColor(self.pLbM2, _cc.blue)
	setTextCCColor(self.pLbM3, _cc.blue)

	self.pLbR1 = self:findViewByName("lb_r_1") --

	self.pLbAt = self:findViewByName("lb_at") -- 
	self.pLbDe = self:findViewByName("lb_de") --
	self.pLbSo = self:findViewByName("lb_so") --

	self.pLbL1:setString(getConvertedStr(5, 10020))
	self.pLbL2:setString(getConvertedStr(5, 10021))
	self.pLbL3:setString(getConvertedStr(5, 10022))
	self.pLbL4:setString(getConvertedStr(5, 10023))
	self.pLbR1:setString(getConvertedStr(5, 10024))
	self.pLbAt:setString(getConvertedStr(5, 10021))
	self.pLbDe:setString(getConvertedStr(5, 10022))
	self.pLbSo:setString(getConvertedStr(5, 10023))

	--img
	self.pImgShuxing = self:findViewByName("img_shuxing") --属性背景图
	self.pImgbg2 = self:findViewByName("img_bg2") --属性背景图
	self.pImgbg2:setVisible(true)
	self.pImgbg2:setZOrder(1)




	--创建能力分布图
	local nAttScale = self.tHeroData.nTa / getHeroInitData("initAttrNum") --攻击比例
	local nDefScale = self.tHeroData.nTd / getHeroInitData("initAttrNum") --防御比例
	local nTrpScale = self.tHeroData.nTr / getHeroInitData("initAttrNum") --兵力比例

	--中心点(65,37)
	--顶点(65,108)
	--左下点(3,2)
	--右下点(126,2)
	local tPoint = {{65- 63*nDefScale,37-35*nDefScale},{65,37+nAttScale*72},{65+nTrpScale*61,37-35*nTrpScale}}
	local tColor = {fillColor = cc.c4f(171/255,151/255,95/255,179/255),
    borderWidth  = 1,
    borderColor  = cc.c4f(171/255,151/255,95/255,179/255)} 

	self.pNodePolygon =  display.newPolygon(tPoint,tColor)
	self.pImgShuxing:addChild(self.pNodePolygon,100)



	if not self.pRichViewTips1 then
	    --总资质
		local nTotalVal = 0
		local nBaseVal = self.tHeroData:getBaseTotalTalent()
		local nExVal = 0
		local strTips1 = nil
		nExVal = self.tHeroData:getExTotalTalent()
	    strTips1 = {
	    	{color=_cc.blue,text=nBaseVal},
	    	{color=_cc.green,text="+"..nExVal},
	    }



	    self.pRichViewTips1 = MRichLabel.new({str=strTips1, fontSize=20, rowWidth=100})
	    self.pRichViewTips1:setPosition(95,165)
	    self.pRichViewTips1:setAnchorPoint(cc.p(0,0.5))
	    self.pLyContent:addView(self.pRichViewTips1,10)
		--todo
	end
    

	if not self.pRichViewTips2 then
	    --等级富文本
	    local strTips2 = {
	    	{color=_cc.blue,text=tostring(self.tHeroData.nLv)},
	    	{color=_cc.white,text="/"..Player:getPlayerInfo().nLv},
	    }

	    self.pRichViewTips2 = MRichLabel.new({str=strTips2, fontSize=20, rowWidth=100})
	    self.pRichViewTips2:setPosition(547,165)
	    self.pRichViewTips2:setAnchorPoint(cc.p(0.5,0.5))
	    self.pLyContent:addView(self.pRichViewTips2,10)
	end



end




-- 修改控件内容或者是刷新控件数据
function DlgHeroParameter:updateViews()

	if not self.tHeroData then
		return
	end

	if self.tHeroData.sName then
		self.pLHeroName:setString(self.tHeroData.sName)
	end

	--总资质刷新
	if self.pRichViewTips1 then

		--基础资质
		-- local nTotalVal = self.tHeroData:getNowTotalTalent()
		-- local nBaseVal = self.tHeroData.nBaseTalentSum
		-- local nExVal = nTotalVal - nBaseVal
		local nBaseVal = self.tHeroData:getBaseTotalTalent()
		local nExVal = self.tHeroData:getExTotalTalent()
		self.pRichViewTips1:updateLbByNum(1,tostring(nBaseVal))

		--额外资质
		if nExVal > 0 then
			self.pRichViewTips1:updateLbByNum(2,"+"..nExVal)
		end
	end

	--等级文本刷新
	if self.pRichViewTips2 then

		--英雄等级
		self.pRichViewTips2:updateLbByNum(1,tostring(self.tHeroData.nLv))
		--主公等级
		self.pRichViewTips2:updateLbByNum(2,"/"..Player:getPlayerInfo().nLv)
	end

	--等级进度条
	self.pBarLv:setPercent(self.tHeroData.nLv/Player:getPlayerInfo().nLv*100)


	self.pLbM1:setString(self.tHeroData.nTa)--攻资质
	self.pLbM2:setString(self.tHeroData.nTd)--防资质
	self.pLbM3:setString(self.tHeroData.nTr)--兵资质


	--刷新属性
	for k,v in pairs(self.tTalentInfo) do
		local tData = self.tHeroData.tAttList[k]
		if tData then
			v:setCurData(tData)
		end
	end


end


-- 析构方法
function DlgHeroParameter:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroParameter:regMsgs( )
	-- body
end

-- 注销消息
function DlgHeroParameter:unregMsgs(  )
	-- body
end


--暂停方法
function DlgHeroParameter:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgHeroParameter:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgHeroParameter