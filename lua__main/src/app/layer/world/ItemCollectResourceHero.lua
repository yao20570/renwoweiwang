----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-04-18 17:31:20
-- Description: 采集资源 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemCollectResourceHero = class("ItemCollectResourceHero", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemCollectResourceHero:ctor( onHeroClicked )
	self.onHeroClicked = onHeroClicked
	--解析文件
	parseView("item_collect_resource_hero", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemCollectResourceHero:onParseViewCallback( pView )
	self.pView = pView
	pView:setViewTouched(true)
	pView:setIsPressedNeedScale(false)
	pView:setIsPressedNeedColor(false)
	pView:onMViewClicked(handler(self, self.onBgClicked))

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemCollectResourceHero",handler(self, self.onItemCollectResourceHeroDestroy))
end

-- 析构方法
function ItemCollectResourceHero:onItemCollectResourceHeroDestroy(  )
    self:onPause()
end

function ItemCollectResourceHero:regMsgs(  )
end

function ItemCollectResourceHero:unregMsgs(  )
end

function ItemCollectResourceHero:onResume(  )
	self:regMsgs()
end

function ItemCollectResourceHero:onPause(  )
	self:unregMsgs()
end

function ItemCollectResourceHero:setupViews(  )
	self.pTxtName = self:findViewByName("txt_name")

	--兵力
	self.pTxtTroops = self:findViewByName("txt_troops")
	self.pTxtState = self:findViewByName("txt_state")

	self.pImgSelected = self:findViewByName("img_selected")
	
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pImgCai = self:findViewByName("img_cai")
end

function ItemCollectResourceHero:updateViews(  )
	if not self.tData then
		return
	end

	--武将名字
	self.pTxtName:setString(self.tData.sName..getLvString(self.tData.nLv))
	setTextCCColor(self.pTxtName, getColorByQuality(self.tData.nQuality))

	local pIconHero = getIconHeroByType(self.pLayIcon,TypeIconHero.NORMAL,self.tData,TypeIconHeroSize.M)
	if not self.pIconHero then
		self.pIconHero = pIconHero
		self.pIconHero:setIconClickedCallBack(handler(self, self.onFillClicked))
		self.pIconHero:setIconIsCanTouched(true)
	end
	self.pIconHero:setHeroType()
	

	local pTroopsColor = _cc.green
	local nMaxTroops = self.tData:getProperty(e_id_hero_att.bingli)
	--空闲
	if self.nState ==  e_type_task_state.idle then
		--兵力不足
		local fTroopsRate = self.tData.nLt/nMaxTroops
		if fTroopsRate <= 0.1 then
			self.pTxtState:setString(getConvertedStr(3, 10067))
			setTextCCColor(self.pTxtState, _cc.red)
			self:setCheckBoxVisible(false)
			pTroopsColor = _cc.red
		else
			self.pTxtState:setString(getConvertedStr(3, 10078))
			setTextCCColor(self.pTxtState, _cc.green)
			self:setCheckBoxVisible(true)
		end
	else
		self.pTxtState:setString(getConvertedStr(3, 10062))
		setTextCCColor(self.pTxtState, _cc.yellow)
		self:setCheckBoxVisible(false)
	end

	--只有采集队列才显示
	if self.tData:getIsCollectQueue() then
		self.pImgCai:setVisible(true)
	else
		self.pImgCai:setVisible(false)
	end

	--兵力
	local tStr = {
		{text = getConvertedStr(3, 10124), color = cc.pwhite},
		{text = string.format("%s/%s", self.tData.nLt, nMaxTroops), color = cc.white},
	}
	self.pTxtTroops:setString(tStr)
end

--设置选框显示或者隐藏
function ItemCollectResourceHero:setCheckBoxVisible( bIsShow )
	self.pImgSelected:setVisible(bIsShow)
	self.bIsCheckBoxVisible = bIsShow
end

--兵力不足跳到
function ItemCollectResourceHero:onFillClicked( pView )
	local tObject = {} 
	tObject.nType = e_dlg_index.dlgherolineup --dlg类型
	if self.tData:getIsCollectQueue() then
		tObject.nTeamType = e_hero_team_type.collect
	end
	sendMsg(ghd_show_dlg_by_type,tObject)
end

--tData:武将数据
function ItemCollectResourceHero:setData( tData, nIndex)
	self.nIndex = nIndex
	self.tData = tData
	self.nState =  Player:getWorldData():getHeroState(self.tData.nId)
	self:updateViews()
end

--获取武将数据
function ItemCollectResourceHero:getHeroData()
	return self.tData
end

--更新兵力
function ItemCollectResourceHero:refreshRecruit(  )
	if not self.tData then
		return
	end
	self.tData = Player:getHeroInfo():getHero(self.tData.nId)	
	self.nState =  Player:getWorldData():getHeroState(self.tData.nId)
	self:updateViews()
end

--设置选中
function ItemCollectResourceHero:setSelected( bIsSelect )
	if bIsSelect then
		self.pImgSelected:setCurrentImage("#v2_img_gouxuan.png")
	else
		self.pImgSelected:setCurrentImage("#v2_img_gouxuankuang.png")
	end
end

--获取单选框是否显示
function ItemCollectResourceHero:getIsCheckBoxVisible()
	return self.bIsCheckBoxVisible
end

--点击背景回调
function ItemCollectResourceHero:onBgClicked( )
	if self:getIsCheckBoxVisible() then
		if self.onHeroClicked then
			self.onHeroClicked(self.nIndex)
		end
	end
end



return ItemCollectResourceHero


