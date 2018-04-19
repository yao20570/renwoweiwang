-----------------------------------------------------
-- author: liangzhaowei
-- Date: 2017-04-25 11:00:17
-- Description: 英雄属性
-----------------------------------------------------

-- local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgBase = require("app.common.dialog.DlgBase")

local ItemHeroInfoLb = require("app.layer.hero.ItemHeroInfoLb")
local StarAttrLayer = require("app.layer.hero.StarAttrLayer")

local DlgHeroInfo = class("DlgHeroInfo", function()
	return DlgBase.new(e_dlg_index.heroinfo)
end)

--_bShowBaseData:从icon头像点击进来的属性不显示额外资质
function DlgHeroInfo:ctor(_tData, _bShowBaseData)
	-- body
	self:myInit()
	self.tData = _tData
	self.bShowBaseData = _bShowBaseData

	self:initData()
	self:setTitle(getConvertedStr(5, 10019))
	parseView("dlg_hero_info", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function DlgHeroInfo:myInit(  )
	-- body
	self.tData = nil
end

--初始化数据
function DlgHeroInfo:initData()

	if not self.tData then
       return
	end

end

--解析布局回调事件
function DlgHeroInfo:onParseViewCallback( pView )
	-- body
	self.pSelectView = pView
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgHeroInfo",handler(self, self.onDestroy))
end

--初始化控件
function DlgHeroInfo:setupViews( )


end



-- 修改控件内容或者是刷新控件数据
function DlgHeroInfo:updateViews()
	if not self.tData then
       return
	end

	gRefreshViewsAsync(self, 6, function ( _bEnd, _index )
		if(_index == 1) then

			--ly
			--属性
			if not self.tLyTalent then
				self.tLyTalent = {}
				for i=1,11 do
					local pView = self:findViewByName("ly_talent_"..i)
					self.tLyTalent[i] = ItemHeroInfoLb.new(i)
					pView:addView(self.tLyTalent[i],100)
				end
			end

			--设置属性内容
			for k,v in pairs(self.tLyTalent) do
				if self.tData.tAttList[k] then
					v:setCurData(self.tData.tAttList[k])
				end
			end
			--攻击
			if self.tLyTalent[1] then
				local nValue = math.floor(self.tData:getBasePropertyByAndLv(e_id_hero_att.gongji, self.tData.nLv))
				local nValueEx = self.tData:getAtkMax() - nValue
				if self.bShowBaseData then
					if nValueEx > 0 then
						nValue = self.tData:getAtkMax()
						nValueEx = 0
					end
				end
				self.tLyTalent[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), nValue, nValueEx)
			end
			--防御
			if self.tLyTalent[2] then
				local nValue = math.floor(self.tData:getBasePropertyByAndLv(e_id_hero_att.fangyu, self.tData.nLv))
				local nValueEx = self.tData:getDefMax() - nValue
				if self.bShowBaseData then
					if nValueEx > 0 then
						nValue = self.tData:getDefMax()
						nValueEx = 0
					end
				end
				self.tLyTalent[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), nValue, nValueEx)
			end
			--兵力
			if self.tLyTalent[3] then
				local nValue = math.floor(self.tData:getBasePropertyByAndLv(e_id_hero_att.bingli, self.tData.nLv))
				local nValueEx = self.tData:getTroopsMax() - nValue
				if self.bShowBaseData then
					if nValueEx > 0 then
						nValue = self.tData:getTroopsMax()
						nValueEx = 0
					end
				end
				self.tLyTalent[3]:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), nValue, nValueEx)
			end

			if not self.pLbInfoName then
				self.pLyMain	    = 		self.pSelectView:findViewByName("dlg_hero_info")
				self.pLbInfoName	= 		self.pSelectView:findViewByName("lb_info_name")
				self.pLbHeroLife	= 		self.pSelectView:findViewByName("lb_hero_life")
				self.pLyContent  	= 		self.pSelectView:findViewByName("ly_main_my")
				self.pLyBottom 		= 		self.pSelectView:findViewByName("ly_content")
				self.pLyContent:setZOrder(10)
				self.pLbInfoName:setString(getConvertedStr(5, 10019))
				self.pLbHeroLife:setString(getConvertedStr(5, 10029))
				self.pLbDesc		= 		self.pSelectView:findViewByName("lb_desc")
				setTextCCColor(self.pLbDesc,_cc.pwhite)
				self.pLbName		= 		self.pSelectView:findViewByName("lb_name")
				--资质
				self.pLbInfo		= 		self.pSelectView:findViewByName("lb_info")
				-- self.pLbStarName	= 		self.pSelectView:findViewByName("lb_star_name")
				self.pImgSoldierTy	= 		self.pSelectView:findViewByName("img_soldier_ty")--兵种图片
				self.pImgIg			= 		self.pSelectView:findViewByName("img_ig")        --神将图标

				-- self.pLyHeroBg    	= 		self.pSelectView:findViewByName("img_hero_bg")--英雄背景
			    self.pLyHeroBg = creatHeroView(self.tData.sImg)
    			self.pLyHeroBg:setPosition(0, 551)
    			self.pLyMain:addView(self.pLyHeroBg,0)

				-- self.pLbStarName:setString(getConvertedStr(5, 10238))
			end
			-- --武将形象
			-- if self.tData.sImg then
			-- 	self.pLyHeroBg:setCurrentImage(self.tData.sImg)
			-- end
			--武将名字
			if self.tData.sName then
				self.pLbName:setString(self.tData.sName..getLvString(self.tData.nLv,true))
			end
			if not self.pAttrStart then
				self.pAttrStart 	=		StarAttrLayer.new(0, 0.8)	
				self.pLyBottom:addView(self.pAttrStart, 11)					
			end
			--武将星级
			-- if self.tData.nStar then
			-- 	self.pAttrStart:updateStar(self.tData.nStar)
			-- end
			if self.tData.tSoulStar then
				self.pAttrStart:updateSoulStar(self.tData.tSoulStar)
			end
			self.pAttrStart:setPosition((self.pLyBottom:getWidth() - self.pAttrStart:getWidth())/2, 433)	

			--武将兵种图标
			if self.tData:getHeroKindImg(2) then
				self.pImgSoldierTy:setCurrentImage(self.tData:getHeroKindImg(2))
			end

			if self.tData.nIg == 1 then
				self.pImgIg:setVisible(true)
			else
				self.pImgIg:setVisible(false)
			end

			--武将信息
			if self.tData:getBaseTotalTalent() then
				local nExTalent = self.tData:getExTotalTalent()
				local tStr = {
				{text = getConvertedStr(5, 10256)..self.tData:getBaseTotalTalent(),color =_cc.white},
				{text = "+"..nExTalent, color = _cc.green},
				}
				self.pLbInfo:setString(tStr)
			end


			
			--武将生平
			if self.tData.sDes then
				self.pLbDesc:setString(self.tData.sDes)
			end




			
		elseif(_index == 2) then

		elseif(_index == 4) then
		end
	end)


end

-- 析构方法
function DlgHeroInfo:onDestroy(  )
	-- body
	self:onPause()
end

-- 注册消息
function DlgHeroInfo:regMsgs( )
	-- body
end

-- 注销消息
function DlgHeroInfo:unregMsgs(  )
	-- body
end


--暂停方法
function DlgHeroInfo:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function DlgHeroInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
	
end

return DlgHeroInfo