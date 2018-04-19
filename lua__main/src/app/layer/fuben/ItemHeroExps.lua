-- Author: liangzhaowei
-- Date: 2017-05-02 14:27:56
-- 英雄经验升级item

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemHeroExps = class("ItemHeroExps", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local ADDTIME = 2/0.01 --目前是两秒

--_index 下标 _type 类型
function ItemHeroExps:ctor()
	-- body
	self:myInit()

	parseView("item_fuben_result_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemHeroExps",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemHeroExps:myInit()
	self.nNowLv = nil --当前等级
	self.nAddPercent =  1 --每次添加的百分比
	self.bPlayEffect = false --是否已经播放音效
end

--解析布局回调事件
function ItemHeroExps:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemHeroExps:setupViews( )
	--ly         	
	self.pLyIcon = self:findViewByName("ly_hero")
	self.pLyBar = self:findViewByName("ly_bar")
	self.pLyBar:setVisible(false)


	self.pBarLv = 	nil
	self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_1.png",barWidth = 106, barHeight = 14})
	self.pLyBar:addView(self.pBarLv,100)
	centerInView(self.pLyBar,self.pBarLv)


	self.pLbN = self:findViewByName("lb_name")
	-- self.pLbN:setPositionX(self.pLbN:getPositionX() - 4)

	setTextCCColor(self.pLbN, _cc.blue)
	self.pLbLv = self:findViewByName("lb_lv")
	-- self.pLbLv:setPositionX(self.pLbLv:getPositionX() + 10)


	self.pLayBottomBg = self:findViewByName("lay_bottom_bg")

	self.pLbN:setVisible(false)
	self.pLbLv:setVisible(false)
	self.pLayBottomBg:setVisible(false)
end

-- 修改控件内容或者是刷新控件数据
function ItemHeroExps:updateViews(  )

	if not self.pData then
		return
	end


	self.pLbN:setVisible(true)
	self.pLbLv:setVisible(true)
	self.pLayBottomBg:setVisible(true)

	local id = self.pData.h
	if self.pData.hs then
		id = self.pData.hs.t
	end
	self.pHeroData = getHeroDataById(id)
	if self.pData.hs then
		self.pHeroData.nIg = self.pData.hs.ig
	end
	self.pLyBar:setVisible(true)



	if self.pHeroData then
		self.pIcon = getIconHeroByType(self.pLyIcon, TypeIconHero.NORMAL, self.pHeroData, TypeIconHeroSize.L)
		if self.pData.a then
			local nLeftNums = self.pData.a
			if nLeftNums > 0  then
				self.pIcon:setExInfo("+"..formatCountToStr(nLeftNums),_cc.green)
			elseif nLeftNums == 0 then
				 if self.pData.fl and Player:getPlayerInfo().nLv == self.pData.fl  then
					self.pIcon:setExInfo(getConvertedStr(5, 10105),_cc.yellow)
				 end
			end
		end
		self.pIcon:setHeroType()
		--lb
		self.pLbN:setString(self.pHeroData.sName or "")
		setTextCCColor(self.pLbN,getColorByQuality(self.pHeroData.nQuality)) --取英雄品质显示名字

		local nLength, nCntEn, nCntCn = getUtf8StringCount(self.pHeroData.sName)
		if nCntCn == 2 then
			self.pLbN:setScale(1)
			self.pLbN:setPositionX(self.pLbN:getPositionX() +8)
			self.pLbLv:setPositionX(self.pLbLv:getPositionX() - 12)

		elseif nCntCn == 3 then
			self.pLbN:setScale(1)
			self.pLbN:setPositionX(self.pLbN:getPositionX() +1)
			self.pLbLv:setPositionX(self.pLbLv:getPositionX() - 3)
		elseif nCntCn == 4 then
			self.pLbN:setScale(0.8)
			self.pLbLv:setPositionX(self.pLbLv:getPositionX() - 3)
		end
	end



	-- self.pLbLv:setString("Lv."..self.pData.fl) --等级

	--进度条
	self:updateBar(self.pData)
end

--析构方法
function ItemHeroExps:onDestroy(  )
	self:stopAllActions()
	self.bHasPlayUp = false
	-- body
end

--设置数据 _data
function ItemHeroExps:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}


	self:updateViews()


end

--设置icon类型 _nType 英雄类型
function ItemHeroExps:setIConType(_nType)
	if _nType then
		local pIcon =  getIconHeroByType(self.pLyIcon, _nType, nil, TypeIconHeroSize.L)
			if _nType == TypeIconHero.ADD then
				--如果没有可上阵武将.将加号变灰
				if not Player:getHeroInfo():bHaveHeroUp() then 
					pIcon:stopAddImgAction()
				end
				pIcon:setRedTipState(0)
			end
		pIcon:setIconClickedCallBack(function ()
			--应策划要求不做跳转
		end)
	end
end

--刷新进度条
function ItemHeroExps:updateBar(_tData)
	if not _tData then
		return
	end

	if not self.pHeroData then
		return
	end

	local nPercentVal =  _tData.e/self.pHeroData:getLastLvAllExp(_tData.l) --比例值
	-- --满级时,替换满级的进度条
	if nPercentVal == 1 and (Player:getPlayerInfo().nLv == _tData.fl ) then
		self.pBarLv:setBarImage("ui/bar/v1_bar_yellow_5.png")
	else
		self.pBarLv:setBarImage("ui/bar/v1_bar_blue_1.png")
	end

	self.nPerCent = math.ceil(nPercentVal*100)

	self.pBarLv:setPercent(self.nPerCent)
	self:stopAllActions()


	local nFinlPercent = 0
	if _tData.l == _tData.fl then --当前等级相等时
		self:getFinalExpPercent()
		self.pLbLv:setString("Lv.".._tData.l) --等级
	else --需要跨越等级时
		self.nNowLv = _tData.l or 0
		self.nLastPercent = 100
		self:setBarPercent()
		self.pLbLv:setString("Lv.".._tData.l) --等级

		self.nAddPercent = ((_tData.fl - _tData.l)*100 -  self.nPerCent + self:getFinalPerentVal())/ADDTIME
		
		if self.nAddPercent < 1 then
			self.nAddPercent = 1
		end
	end

end

--显示升级过程 
function ItemHeroExps:setBarPercent()

	local fDelayTime = 0.01
	self.pBarLv:setPercent(self.nPerCent)
	if self.nPerCent < self.nLastPercent then
		self.nPerCent = self.nPerCent +self.nAddPercent
	    self:runAction( -- 延时调用
			cc.Sequence:create(cc.DelayTime:create(fDelayTime),
			cc.CallFunc:create(handler(self, self.setBarPercent))))
	else
		if self.nNowLv then
			if self.nNowLv < self.pData.fl then
				if not self.bHasPlayUp then
					playUpDefenseArm(self.pIcon)--显示升级特效
					self.bHasPlayUp = true
				end
			end
			if (self.nNowLv+1) < self.pData.fl then --如果还没有达到最后的等级
				self.nNowLv = self.nNowLv +1
				self.nPerCent = self.nAddPercent
				self.nLastPercent = 100
				self:playUpEffect()
				self:setBarPercent()
				self.pLbLv:setString("Lv."..self.nNowLv) --等级
			else
				self:playUpEffect()
				self.pLbLv:setString("Lv."..self.pData.fl) --等级
				self.nNowLv = nil
				self.nPerCent = self.nAddPercent
				self:getFinalExpPercent()
			end
			
		end
	end
end

--播放音效
function ItemHeroExps:playUpEffect()
	if not self.bPlayEffect then
		self.bPlayEffect = true
		Sounds.playEffect(Sounds.Effect.lvup)
	end
end



--获得最终级比例
function ItemHeroExps:getFinalExpPercent()

	if not self.pHeroData then
		return
	end

	local nFinlPercent = self:getFinalPerentVal()
	
	self.nLastPercent = nFinlPercent --最终的比例
	self:setBarPercent()

	--如果是升级到最后
	if nFinlPercent == 100 and (Player:getPlayerInfo().nLv == self.pData.fl ) then
		self.pBarLv:setBarImage("ui/bar/v1_bar_yellow_5.png")
	end

end

--获得最终比例值
function ItemHeroExps:getFinalPerentVal()

	local nFinlPercent = 0
	if self.pData and self.pData.z and self.pData.fl then
		nFinlPercent = math.ceil(self.pData.z/self.pHeroData:getLvExpByLv(self.pData.fl)*100)
	end

	return nFinlPercent

end


return ItemHeroExps