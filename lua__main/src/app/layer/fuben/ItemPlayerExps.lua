-- Author: zhangnianfeng
-- Date: 2018-01-18 14:27:56
-- 英雄经验升级item

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemPlayerExps = class("ItemPlayerExps", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

local ADDTIME = 2/0.01 --目前是两秒

--_index 下标 _type 类型
function ItemPlayerExps:ctor()
	-- body
	self:myInit()

	parseView("item_fuben_result_player", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemPlayerExps",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemPlayerExps:myInit()
	self.nNowLv = nil --当前等级
	self.nAddPercent =  1 --每次添加的百分比
	self.bPlayEffect = false --是否已经播放音效
	-- self.nTopLv = tonumber(getGlobleParam("levelLimit"))
end

--解析布局回调事件
function ItemPlayerExps:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
end

--初始化控件
function ItemPlayerExps:setupViews( )
	--ly         	
	self.pLyIcon = self:findViewByName("ly_hero")
	self.pLyBar = self:findViewByName("ly_bar")
	self.pLyBar:setVisible(false)


	self.pBarLv = 	nil
	self.pBarLv = MCommonProgressBar.new({bar = "v1_bar_blue_1.png",barWidth = 106, barHeight = 14})
	self.pLyBar:addView(self.pBarLv,100)
	centerInView(self.pLyBar,self.pBarLv)

	local tActorVo = Player:getPlayerInfo():getActorVo()
	self.pIcon = getIconGoodsByType(self.pLyIcon, TypeIconHero.NORMAL,type_icongoods_show.header, tActorVo, TypeIconHeroSize.L)
	self.pIcon:setIconIsCanTouched(false)

	self.pLbLv = self:findViewByName("lb_name")
	self.pTxtExp = self:findViewByName("txt_exp")
	setTextCCColor(self.pTxtExp, _cc.green)
end

-- 修改控件内容或者是刷新控件数据
function ItemPlayerExps:updateViews(  )

	if not self.pData then
		return
	end

	self.pLyBar:setVisible(true)

	--增加的经验
	local nLeftNums = self.pData.e --e	Long	增加的经验
	self.pTxtExp:setString("+"..formatCountToStr(nLeftNums))
	
	if nLeftNums > 0 then
		--进度条
		self:updateBar(self.pData)
	else
		self:showNotChangeExp(self.pData)
	end
end

--析构方法
function ItemPlayerExps:onDestroy(  )
	self:stopAllActions()
	self.bHasPlayUp = false
	-- body
end

function ItemPlayerExps:showNotChangeExp( _tData )
	-- body

	self.nPerCent = self:getFinalPerentVal()--math.ceil(nPercentVal*100)

	self.pBarLv:setPercent(self.nPerCent)
	self.pLbLv:setString(getConvertedStr(3, 10705) .. getLvString(_tData.al)) --等级

end

--设置数据 _data:AvaAddExpVo
function ItemPlayerExps:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	self:updateViews()
end

-- --设置icon类型 _nType 英雄类型
-- function ItemPlayerExps:setIConType(_nType)
-- 	if _nType then
-- 		local pIcon =  getIconHeroByType(self.pLyIcon, _nType, nil, TypeIconHeroSize.L)
-- 			if _nType == TypeIconHero.ADD then
-- 				--如果没有可上阵武将.将加号变灰
-- 				if not Player:getHeroInfo():bHaveHeroUp() then 
-- 					pIcon:stopAddImgAction()
-- 				end
-- 			end
-- 		pIcon:setIconClickedCallBack(function ()
-- 			--应策划要求不做跳转
-- 		end)
-- 	end
-- end

--刷新进度条
function ItemPlayerExps:updateBar(_tData)
	if not _tData then
		return
	end

	local nPrevExp = _tData.be -- 升级前经验
	local nPrevLv = _tData.bl --之前的等级
	
	local tLvUp = getAvatarLvUpByLevel(nPrevLv)
	if not tLvUp then
		return
	end
	local nPercentVal = math.floor(nPrevExp / tLvUp.exp)--比例值

	-- -- --满级时,替换满级的进度条
	-- if nPercentVal >= 1 and (nPrevLv >= self.nTopLv ) then
	-- 	self.pBarLv:setBarImage("ui/bar/v1_bar_yellow_5.png")
	-- else
	-- 	self.pBarLv:setBarImage("ui/bar/v1_bar_blue_1.png")
	-- end

	self.nPerCent = math.ceil(nPercentVal*100)
	self.pBarLv:setPercent(self.nPerCent)
	self:stopAllActions()

	local nLastLv = _tData.al --升级后的等级

	local nFinlPercent = 0
	if nPrevLv == nLastLv then --当前等级相等时
		self:getFinalExpPercent()
		self.pLbLv:setString(getConvertedStr(3, 10705) .. getLvString(nPrevLv)) --等级
	else --需要跨越等级时
		self.nNowLv = nPrevLv or 0
		self.nLastPercent = 100
		self:setBarPercent()
		self.pLbLv:setString(getConvertedStr(3, 10705) .. getLvString(nPrevLv)) --等级

		self.nAddPercent = ((nLastLv - nPrevLv)*100 -  self.nPerCent + self:getFinalPerentVal())/ADDTIME
		
		if self.nAddPercent < 1 then
			self.nAddPercent = 1
		end
	end



end

--显示升级过程 
function ItemPlayerExps:setBarPercent()
	local fDelayTime = 0.01
	self.pBarLv:setPercent(self.nPerCent)
	if self.nPerCent < self.nLastPercent then
		self.nPerCent = self.nPerCent +self.nAddPercent
	    self:runAction( -- 延时调用
			cc.Sequence:create(cc.DelayTime:create(fDelayTime),
			cc.CallFunc:create(handler(self, self.setBarPercent))))
	else
		local nLastLv = self.pData.al --升级后的等级
		if self.nNowLv then
			if self.nNowLv < nLastLv then
				if not self.bHasPlayUp then
					playUpDefenseArm(self.pIcon, nil, 10)--显示升级特效
					self.bHasPlayUp = true
				end
			end
			if (self.nNowLv+1) < nLastLv then --如果还没有达到最后的等级
				self.nNowLv = self.nNowLv +1
				self.nPerCent = self.nAddPercent
				self.nLastPercent = 100
				self:playUpEffect()
				self:setBarPercent()
				self.pLbLv:setString(getConvertedStr(3, 10705) .. getLvString(self.nNowLv)) --等级
			else
				self:playUpEffect()
				self.pLbLv:setString(getConvertedStr(3, 10705) .. getLvString(nLastLv)) --等级
				self.nNowLv = nil
				self.nPerCent = self.nAddPercent
				self:getFinalExpPercent()
			end
			
		end
	end
end

--播放音效
function ItemPlayerExps:playUpEffect()
	if not self.bPlayEffect then
		self.bPlayEffect = true
		Sounds.playEffect(Sounds.Effect.lvup)
	end
end



--获得最终级比例
function ItemPlayerExps:getFinalExpPercent()

	if not self.pData then
		return
	end

	local nFinlPercent = self:getFinalPerentVal()
	self.nLastPercent = nFinlPercent --最终的比例
	self:setBarPercent()

	-- --如果是升级到最后
	-- if nFinlPercent == 100 and (self.pData.al >= self.nTopLv ) then
	-- 	self.pBarLv:setBarImage("ui/bar/v1_bar_yellow_5.png")
	-- end
end

--获得最终比例值
function ItemPlayerExps:getFinalPerentVal()

	local nFinlPercent = 0
	if self.pData and self.pData.ae and self.pData.al then
		local tLvUp = getAvatarLvUpByLevel(self.pData.al)
		if tLvUp then
			nFinlPercent = math.ceil(self.pData.ae/tLvUp.exp*100)
		end
	end

	return nFinlPercent

end

--设置名字+等级
function ItemPlayerExps:setNameStr(  )
	-- body
end

return ItemPlayerExps