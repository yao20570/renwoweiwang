-- Author: maheng
-- Date: 2018-03-24 17:07:22
-- 上阵武将item

local MCommonView = require("app.common.MCommonView")
local HeroInfoLabel = require("app.layer.hero.HeroInfoLabel")

local ItemArenaLineupHero = class("ItemArenaLineupHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--  _tData 数据 _nNums 顺序
function ItemArenaLineupHero:ctor(_tData, _nNums)
	-- body
	self:myInit()


	self.tData = _tData
	self.nNUms = _nNums or 0
	self.nListType=_listType or 1

	parseView("item_arena_lineup_hero", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemArenaLineupHero",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemArenaLineupHero:myInit()
	-- body
	self.tData = {} --数据

end

--解析布局回调事件
function ItemArenaLineupHero:onParseViewCallback( pView )

	self.pItemView = pView
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:onResume()
end

--初始化控件
function ItemArenaLineupHero:setupViews( )

	self.pLyHeroMain = self:findViewByName("lay_hero_info")
	self.pLyBtn =  self:findViewByName("lay_btn")	
	self.pLbAccount = self:findViewByName("lb_account")	
	--ly
	--资质数据显示
	self.tLyTalentInfo = {}
	for i=1,3 do
		self.tLyTalentInfo[i] = HeroInfoLabel.new(2)
		self.pLyHeroMain:addView(self.tLyTalentInfo[i],10)
		if(i == 1) then
			self.tLyTalentInfo[i]:setPosition(140, 65)
		elseif(i == 2) then
			self.tLyTalentInfo[i]:setPosition(290, 65)
		elseif(i == 3) then
			self.tLyTalentInfo[i]:setPosition(140, 30)			
		end
	end

	-- --武将名称,vip等级
	self.pTextNa =  MUI.MLabel.new({text="", size=22})
	self.pLyHeroMain:addView(self.pTextNa,10)
    self.pTextNa:setAnchorPoint(cc.p(0,0.5))
	self.pTextNa:setPosition(140,102)

	
	self.pBtnUp = getCommonButtonOfContainer(self.pLyBtn,TypeCommonBtn.M_BLUE,getConvertedStr(7,10314),false)	
	self.pBtnUp:onCommonBtnClicked(handler(self, self.onClicked))

	--说明文字
	

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	-- self:onMViewClicked(handler(self, self.onHero))

end

-- 修改控件内容或者是刷新控件数据
function ItemArenaLineupHero:updateViews(  )

	if not self.tData then
		return
	end

	if(not self.pLyIcon) then
		self.pLyIcon = self:findViewByName("lay_icon")
	end

	if type(self.tData) == "table" then
		self.pLyHeroMain:setVisible(true)
		self.pLbAccount:setVisible(false)
		self.pIcon  =  getIconHeroByType(self.pLyIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(handler(self, self.onHero))
				
		local pHero = Player:getHeroInfo():getHero(self.tData.nId)
		local nRedNum = 0
		if pHero and pHero:getBaseSc() > self.tData:getBaseSc() then			
			nRedNum = 1
		end		

		showRedTips(self.pLyBtn, 0, nRedNum, 2)
		--隐藏红点
		showRedTips(self.pIcon,0,0,2)
		--攻击
		if self.tLyTalentInfo[1] then
			self.tLyTalentInfo[1]:setCurDataEx(getAttrUiStr(e_id_hero_att.gongji), self.tData:getAtkMax())
		end
		--防御
		if self.tLyTalentInfo[2] then
			self.tLyTalentInfo[2]:setCurDataEx(getAttrUiStr(e_id_hero_att.fangyu), self.tData:getDefMax())
		end
		--兵力
		if self.tLyTalentInfo[3] then
			self.tLyTalentInfo[3]:setCurDataEx(getAttrUiStr(e_id_hero_att.bingli), self.tData:getTroopsMax())
		end

		-- --等级文本刷新
		local tStr = {
			{text=self.tData.sName, color=getC3B(getColorByQuality(self.tData.nQuality))},
			{text=getLvString(self.tData.nLv), color=getC3B(getColorByQuality(self.tData.nQuality))},
		}
		self.pTextNa:setString(tStr)

		self.pIcon:setHeroType()

		self.pBtnUp:setBtnVisible(true)
	else
		self.pBtnUp:setBtnVisible(false)
		self.pIcon  =  getIconHeroByType(self.pLyIcon, self.tData, nil, TypeIconHeroSize.L)
		self.pIcon:setIconClickedCallBack(handler(self, self.onHero))

		self.pLbAccount:setVisible(true)
		self.pLyHeroMain:setVisible(false)
		if self.tData == TypeIconHero.ADD then
			self.pLbAccount:setString(getConvertedStr(5, 10101))

			--如果没有可上阵武将.将加号变灰
			if not Player:getHeroInfo():bHaveHeroUpByTeam(self.nTeamType) then 
				self.pIcon:stopAddImgAction()
			else
				self.pIcon:setIconBgToGray(false)
			end
		else
			if self.nNUms then
				local nTnStr = "" 
				local nTnId = 1
				if self.nNUms == 3 then
					nTnId   =  3010 --中级科技id
				elseif self.nNUms == 4 then
					nTnId   =  3020 --高级科技id
				end
				self.tTechnology = getGoodsByTidFromDB(nTnId)
				if self.tTechnology then
					nTnStr = self.tTechnology.sName
				end 
				if nTnStr and (nTnStr~= "") then
					nTnStr = string.format(getConvertedStr(5, 10102),nTnStr)
					self.pLbAccount:setString(nTnStr)
				end
			end
		end
	end
end

--红点提示
function ItemArenaLineupHero:refreshRedNums()
	if not self.tData or not self.pIcon or type(self.tData) ~= "table" then
		return
	end
end


-- 更换武将按钮点击响应
function ItemArenaLineupHero:onClicked(pView)

	--选择武将界面
	local tObject = {}
	tObject.nType = e_dlg_index.selecthero --dlg类型
	tObject.tData = self.tData
	tObject.nTeamType = e_hero_team_type.arena
	sendMsg(ghd_show_dlg_by_type,tObject)
end

-- 英雄按钮点击回调
function ItemArenaLineupHero:onHero(pView)
	if type(self.tData) == "table"  then
		local tObject = {} 
		tObject.tData = self.tData --当前武将数据
		tObject.nType = e_dlg_index.selecthero --dlg类型
		tObject.nTeamType = e_hero_team_type.arena
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		--存在添加回调就添加英雄回调
		if self.tData == TypeIconHero.ADD then
			local tObject = {}
			tObject.nType = e_dlg_index.selecthero --dlg类型
			tObject.nTeamType = e_hero_team_type.arena
			sendMsg(ghd_show_dlg_by_type,tObject)
		else
			local nTipIndex = 1
			if self.nNUms == 3 then
				nTipIndex = 10060
			elseif self.nNUms == 4 then
				nTipIndex = 10061
			end
			local tObject = {
			    nType = e_dlg_index.lockherotip, --dlg类型
			    tData = self.tTechnology,
			    sStr = getTextColorByConfigure(getTipsByIndex(nTipIndex))
			}
			sendMsg(ghd_show_dlg_by_type, tObject)
		end
	end
end


-- 注册消息
function ItemArenaLineupHero:regMsgs( )
	-- 注册武将进阶状态刷新消息
	-- regMsg(self, ghd_advance_hero_rednum_update_msg, handler(self, self.refreshRedNums))
end

-- 注销消息
function ItemArenaLineupHero:unregMsgs(  )
	--注销武将进阶状态刷新消息
	-- unregMsg(self, ghd_advance_hero_rednum_update_msg)
end


--暂停方法
function ItemArenaLineupHero:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function ItemArenaLineupHero:onResume( )
	-- body
	self:regMsgs()
end
--析构方法
function ItemArenaLineupHero:onDestroy(  )
	self:onPause()
	-- body
end

--设置数据 _data
function ItemArenaLineupHero:setCurData(_tData, _nIdx)
	if not _tData then
		return
	end
	self.tData = _tData or {}
	self.nNUms = _nIdx or self.nNUms
	self:updateViews()
end

function ItemArenaLineupHero:getData(  )
	-- body
	return self.tData
end

--获取Icon层
function ItemArenaLineupHero:getIconLayer(  )
	-- body
	if self.pLyIcon then
		return self.pLyIcon
	else
		return nil
	end
end


return ItemArenaLineupHero