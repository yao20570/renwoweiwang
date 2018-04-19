----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-16 18:10:00
-- Description: 皇城战 战况
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemImperialWarState = require("app.layer.imperialwar.ItemImperialWarState")
local ImperialWarState = class("ImperialWarState", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

function ImperialWarState:ctor(  )
	--解析文件
	parseView("layout_imperial_war_state", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ImperialWarState:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	self:selectTab(e_imperwar_tab.server)

	--注册析构方法
	self:setDestroyHandler("ImperialWarState", handler(self, self.onImperialWarStateDestroy))
end

-- 析构方法
function ImperialWarState:onImperialWarStateDestroy(  )
    self:onPause()
    if b_close_imperialwar then
    else
    	local nSysCityId = Player:getImperWarData():getCurrImperialWarId()
    	SocketManager:sendMsg("stopImperWarPush",{1, nSysCityId})
    end
end

function ImperialWarState:regMsgs(  )
	regMsg(self, ghd_imperialwar_fight_refresh, handler(self, self.onFightRefresh))
end

function ImperialWarState:unregMsgs(  )
	unregMsg(self, ghd_imperialwar_fight_refresh)
end

function ImperialWarState:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ImperialWarState:onPause(  )
	self:unregMsgs()
end

function ImperialWarState:setupViews(  )
	local pTxtTab1 = self:findViewByName("txt_tab1")
	pTxtTab1:setString(getConvertedStr(3, 10928))
	local pTxtTab2 = self:findViewByName("txt_tab2")
	pTxtTab2:setString(getConvertedStr(3, 10929))
	local pTxtTab3 = self:findViewByName("txt_tab3")
	pTxtTab3:setString(getConvertedStr(3, 10930))

	self.pLayTab1 = self:findViewByName("lay_tab1")
	self.pLayTab1:setViewTouched(true)
	self.pLayTab1:setIsPressedNeedScale(false)
	self.pLayTab1:setIsPressedNeedColor(false)
	self.pLayTab1:onMViewClicked(function ( _pView )
	    self:selectTab(e_imperwar_tab.server)
	end)
	self.pLayTab2 = self:findViewByName("lay_tab2")
	self.pLayTab2:setViewTouched(true)
	self.pLayTab2:setIsPressedNeedScale(false)
	self.pLayTab2:setIsPressedNeedColor(false)
	self.pLayTab2:onMViewClicked(function ( _pView )
	    self:selectTab(e_imperwar_tab.country)
	end)
	self.pLayTab3 = self:findViewByName("lay_tab3")
	self.pLayTab3:setViewTouched(true)
	self.pLayTab3:setIsPressedNeedScale(false)
	self.pLayTab3:setIsPressedNeedColor(false)
	self.pLayTab3:onMViewClicked(function ( _pView )
	    self:selectTab(e_imperwar_tab.mine)
	end)

	self.pLayList = self:findViewByName("lay_middle")

	if b_close_imperialwar then
		local pLayTop = self:findViewByName("lay_top")
		pLayTop:setVisible(false)
		--没有数据提示
		local tLabel = {
		    str = getConvertedStr(3, 10220),
		}
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self:addView(pNullUi,9)
		centerInView(self, pNullUi)
    end
end

function ImperialWarState:updateViews(  )
	self:updateListView()
end

--选择tab
function ImperialWarState:selectTab( nIndex )
	if self.nCurrTab ~= nIndex then
		self.nCurrTab = nIndex
		if self.nCurrTab == e_imperwar_tab.server then
			self.pLayTab1:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab3:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		elseif self.nCurrTab == e_imperwar_tab.country then
			self.pLayTab1:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab3:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		else
			self.pLayTab1:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab3:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		end
		self:updateListView()
	end
end

--更新列表
function ImperialWarState:updateListView( )
	if b_close_imperialwar then
		return
	end
	self.tListData = Player:getImperWarData():getImperWarFights(self.nCurrTab)
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 5,
            bottom =  5},
            direction = MUI.MScrollView.DIRECTION_VERTICAL,
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemImperialWarState.new()  
		    end
		    pTempView:setData(self.tListData[_index])
		    return pTempView
		end)
		--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)			
		self.pListView:setItemCount(nCnt)
		self.pListView:reload(false)		
	else
		self.pListView:notifyDataSetChange(false, nCnt)		
	end
	self:setDefInfo(nCnt <= 0)
end

function ImperialWarState:setDefInfo( _bShow )
	local bShow = _bShow or false
	--没有数据提示
	local tLabel = {
	    str = getConvertedStr(3, 10220),
	}
	if not self.pNullUi then
		local pNullUi = getLayNullUiImgAndTxt(tLabel)
		pNullUi:setIgnoreOtherHeight(true)
		self.pLayList:addView(pNullUi)
		centerInView(self.pLayList, pNullUi)
		self.pNullUi = pNullUi
	end
	self.pNullUi:setVisible(bShow)
end

function ImperialWarState:onFightRefresh( sMsgName, pMsgObj )
	if pMsgObj then
		local tFight = pMsgObj
		local tTab = {}
		tTab[e_imperwar_tab.server] = true
		local nInfluence = Player:getPlayerInfo().nInfluence
		if tFight:getAtk():getCountry() == nInfluence or
			tFight:getDef():getCountry() == nInfluence then
			tTab[e_imperwar_tab.country] = true
		end
		local sMyName = Player:getPlayerInfo().sName
		if tFight:getAtk():getName() == sMyName or
			tFight:getDef():getName() == sMyName then
			tTab[e_imperwar_tab.mine] = true
		end
		if tTab[self.nCurrTab] then
			self:updateListView()
		end
	else
		self:updateListView()
	end
end


return ImperialWarState



