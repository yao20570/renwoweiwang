----------------------------------------------------- 
-- author: maheng
-- updatetime: 2018-01-23 17:05:46
-- Description: 竞技场进攻方 or 防守方
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ActorVo = require("app.layer.playerinfo.ActorVo")
local MailFunc = require("app.layer.mail.MailFunc")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemArenaBattler = class("ItemArenaBattler", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType  1-左边 2-右边
function ItemArenaBattler:ctor( _nType )
	--解析文件
	self.nType=_nType or 1
	if self.nType==1 then
		parseView("item_arena_battler_left", handler(self, self.onParseViewCallback))
	elseif self.nType==2 then
		parseView("item_arena_battler_right", handler(self, self.onParseViewCallback))
	end

end

--解析界面回调
function ItemArenaBattler:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemArenaBattler",handler(self, self.onItemMailBattlerDestroy))
end

-- 析构方法
function ItemArenaBattler:onItemMailBattlerDestroy(  )
    self:onPause()
end

function ItemArenaBattler:regMsgs(  )
end

function ItemArenaBattler:unregMsgs(  )
end

function ItemArenaBattler:onResume(  )
	self:regMsgs()
end

function ItemArenaBattler:onPause(  )
	self:unregMsgs()
end

function ItemArenaBattler:setupViews(  )
	self.pLayRoot = self:findViewByName("default")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pLbName = self:findViewByName("lb_name")
	self.pLbPar1 = self:findViewByName("lb_par1")
	self.pLbPar2 = self:findViewByName("lb_par2")
	self.pLbPar3 = self:findViewByName("lb_par3")

	self.pImgFlag = self:findViewByName("img_flag")
end

function ItemArenaBattler:updatePlayer(  )	
	local tPlayerData = nil
	if self.nType == 1 then
		tPlayerData = self.tData.tAInfo
	else
		tPlayerData = self.tData.tDInfo
	end
	if tPlayerData then
		self:setVisible(true)
	else
		self:setVisible(false)
		return
	end
	self.pLbName:setSystemFontSize(22)
	setTextCCColor(self.pLbName, _cc.blue)
	self.pLbPar1:setSystemFontSize(20)
	self.pLbPar2:setSystemFontSize(20)
	self.pLbPar3:setSystemFontSize(20)	
	local pAvatar  = tPlayerData:getActorVo()
	if not self.pIcon then
		self.pIcon =  getIconGoodsByType(self.pLayIcon, TypeIconHero.NORMAL,type_icongoods_show.header, pAvatar, TypeIconHeroSize.M)	
		self.pIcon:setIconClickedCallBack(handler(self, self.onIconClicked))
	else
		self.pIcon:setCurData(pAvatar)
	end
	self.pIcon:setIconIsCanTouched(true)
	self.pImgFlag:setVisible(true)
	local sImgPath = WorldFunc.getCountryFlagImg(tPlayerData.nCountry)
	self.pImgFlag:setCurrentImage(sImgPath)

	--名字
	self.pLbName:setString(tPlayerData.sName..getLvString(tPlayerData.nLv), false)	
	--兵力
	local sStr1 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10718)},
		{color=_cc.white,text=self.tData:getCombat(self.nType)}
	}
	self.pLbPar1:setString(sStr1, false)

	--损兵
	local sStr2 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10719)},
		{color=_cc.white,text=self.tData:getLost(self.nType)}
	}	
	self.pLbPar2:setString(sStr2, false)
	--排名	
	if tPlayerData.nBr and tPlayerData.nAr then
		self.pLbPar3:setVisible(true)
		local sImgArrowPath = nil
		if tPlayerData.nBr > tPlayerData.nAr then
			sImgArrowPath = "#v1_img_xiangshangjiantou.png"
			self.pLbPar3:setString(string.format(getConvertedStr(6, 10837), tPlayerData.nAr))
			setTextCCColor(self.pLbPar3, _cc.green)
		else
			sImgArrowPath = "#v1_img_xiangxiajiantou.png"
			self.pLbPar3:setString(string.format(getConvertedStr(6, 10838), tPlayerData.nAr))
			setTextCCColor(self.pLbPar3, _cc.red)
		end
		if not self.pImgArrow then
			self.pImgArrow = MUI.MImage.new(sImgArrowPath)
			self.pLayRoot:addView(self.pImgArrow, 10)
		else
			self.pImgArrow:setCurrentImage(sImgArrowPath)
		end	
		if self.nType == 1 then
			self.pImgArrow:setPosition(self.pLbPar3:getPositionX() + self.pLbPar3:getWidth() + 10, self.pLbPar3:getPositionY()) 
		else
			self.pImgArrow:setPosition(self.pLbPar3:getPositionX() + 10, self.pLbPar3:getPositionY()) 
		end	
		local bShow = tPlayerData.nBr ~= tPlayerData.nAr 
		self.pLbPar3:setVisible(bShow)	
		self.pImgArrow:setVisible(false)
	end
end

function ItemArenaBattler:updateHero(  )
	-- body
	self.pImgFlag:setVisible(false)
	if self.pImgArrow then
		self.pImgArrow:setVisible(false)
	end
	self.pLbPar3:setVisible(false)
	local tHeroData = nil
	local tPlayerData = nil
	if self.nType == 1 then
		tHeroData = self.tData.tAf[self.nIndex - 1]
		tPlayerData = self.tData.tAInfo
	else
		tHeroData = self.tData.tDf[self.nIndex - 1]
		tPlayerData = self.tData.tDInfo
	end
	if tHeroData then
		self:setVisible(true)
	else
		self:setVisible(false)
		return
	end	
	local tHero = tHeroData:getHeroData()
	if tHero then
		self:setVisible(true)
	else
		self:setVisible(false)
		return
	end	
	self.pLbName:setSystemFontSize(20)
	setTextCCColor(self.pLbName, _cc.pwhite)
	self.pLbPar1:setSystemFontSize(18)	
	self.pLbPar2:setSystemFontSize(18)
	if not self.pIcon then
		self.pIcon = getIconHeroByType(self.pLayIcon, TypeIconHero.NORMAL, tHero , TypeIconHeroSize.M) 	
	else
		self.pIcon:setCurData(tHero)
	end
	self.pIcon:setIconIsCanTouched(false)
	self.pIcon:setHeroType()
			
	--名字
	self.pLbName:setString(tPlayerData.sName, false)
	local sStr1 = {
		{color=_cc.pwhite,text=tHero.sName},
		{color=_cc.blue,text=getLvString(tHeroData.nLv, false)}
	}
	self.pLbPar1:setString(sStr1, false)
	setTextCCColor(self.pLbPar1, _cc.pwhite)
	local sStr2 = {
		{color=_cc.pwhite,text=getConvertedStr(6, 10722)},
		{color=_cc.white,text=tHeroData.nKill}
	}
	self.pLbPar2:setString(sStr2, false)
end

function ItemArenaBattler:updateViews(  )
	-- body	
	self:setVisible(self.tData ~= nil)
	if not self.tData then
		return
	end
	if self.nShowType == 1 then--显示玩家
		self:updatePlayer()
	else--显示武将
		self:updateHero()
	end	
end

--设置数据
function ItemArenaBattler:setCurData( _tData, _index, _nShowType, bIconTouch)
	-- body	
	self.nShowType = _nShowType or 1	
	self.tData = _tData 
	self.nIndex = _index or 1
	self:updateViews()
	if bIconTouch == false then
		self:setIconTouched(false)
	end
end

function ItemArenaBattler:setIconTouched(_bTouched)
	self.pIcon:setIconIsCanTouched(_bTouched)
end

function ItemArenaBattler:onIconClicked(  )
	-- body
	local tPlayerData = nil
	if self.nType == 1 then
		tPlayerData = self.tData.tAInfo
	else
		tPlayerData = self.tData.tDInfo
	end
	if tPlayerData and tPlayerData.nPlayerId then
		SocketManager:sendMsg("checkArenaPlayer", {tPlayerData.nPlayerId}) --刷新竞技场幸运列表	
	end	
end

return ItemArenaBattler


