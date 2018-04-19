----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-02-06 17:41:00
-- Description: 限时Boss奖励
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ItemTLBossAward = require("app.layer.tlboss.ItemTLBossAward")
local TLBossAward = class("TLBossAward", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)

local e_type_tab = {
	harm = 1,
	rank = 2,
}

function TLBossAward:ctor( _tSize )
    self:setContentSize(_tSize)
	--解析文件
	parseView("layout_tboss_award", handler(self, self.onParseViewCallback))
end

--解析界面回调
function TLBossAward:onParseViewCallback( pView )
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()
	self:selectTab(e_type_tab.harm)

	--注册析构方法
	self:setDestroyHandler("TLBossAward", handler(self, self.onTLBossAwardDestroy))
end

-- 析构方法
function TLBossAward:onTLBossAwardDestroy(  )
    self:onPause()
end

function TLBossAward:regMsgs(  )
end

function TLBossAward:unregMsgs(  )
end

function TLBossAward:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function TLBossAward:onPause(  )
	self:unregMsgs()

end

function TLBossAward:setupViews(  )
	local pTxtTab1 = self:findViewByName("txt_tab1")
	pTxtTab1:setString(getConvertedStr(3, 10812))
	local pTxtTab2 = self:findViewByName("txt_tab2")
	pTxtTab2:setString(getConvertedStr(3, 10835))
	self.pLayTab1 = self:findViewByName("lay_tab1")
	self.pLayTab2 = self:findViewByName("lay_tab2")
	self.pLayTab1 = self:findViewByName("lay_tab1")
	
	self.pLayTab1:setViewTouched(true)
	self.pLayTab1:setIsPressedNeedScale(false)
	self.pLayTab1:setIsPressedNeedColor(false)
	self.pLayTab1:onMViewClicked(function ( _pView )
	    self:selectTab(e_type_tab.harm)
	end)
	self.pLayTab2 = self:findViewByName("lay_tab2")
	self.pLayTab2:setViewTouched(true)
	self.pLayTab2:setIsPressedNeedScale(false)
	self.pLayTab2:setIsPressedNeedColor(false)
	self.pLayTab2:onMViewClicked(function ( _pView )
	    self:selectTab(e_type_tab.rank)
	end)

	self.pLayList = self:findViewByName("lay_listview")
end

function TLBossAward:updateViews(  )
end

--选择tab
function TLBossAward:selectTab( nIndex )
	if self.nCurrTab ~= nIndex then
		self.nCurrTab = nIndex
		if self.nCurrTab == e_type_tab.harm then
			self.pLayTab1:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		else
			self.pLayTab1:setBackgroundImage("#v2_btn_biaoqian_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
			self.pLayTab2:setBackgroundImage("#v2_btn_selected_hkoyp.png",{scale9 = true,capInsets=cc.rect(65,26, 1, 1)})
		end
		self:updateListView()
	end
end

--更新列表
function TLBossAward:updateListView(  )
	if not self.nCurrTab then
		return
	end
	if self.nCurrTab == e_type_tab.harm then
		self.tListData = clone(getBossInitData("hurtRankAwards"))
		local sKillDrop = getBossInitData("killDrop") 
		local tData = luaSplit(sKillDrop, ":")
		if tData then
			local nDropId = tonumber(tData[2])
			if nDropId then
				local tKillDrop = getDropById(nDropId)
				if tKillDrop then
					table.insert(self.tListData, 1, {tKillDrop = tKillDrop})
				end
			end
		end
	else
		self.tListData = getBossInitData("fightRankAwards")
	end	
	if not self.tListData then
		return
	end
	local nCnt = #self.tListData
	if not self.pListView then
		self.pListView = MUI.MListView.new {
            bgColor = cc.c4b(255, 255, 255, 250),
            viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
            itemMargin = {left =  0,
            right =  0,
            top = 0,
            bottom =  0},
            direction = MUI.MScrollView.DIRECTION_VERTICAL,
        }
        self.pLayList:addView(self.pListView)	
	    self.pListView:setItemCallback(function ( _index, _pView ) 	    	
		 	local pTempView = _pView
		    if pTempView == nil then
		        pTempView = ItemTLBossAward.new()  
		    end
		    pTempView:setCurData(self.tListData[_index])
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
end

return TLBossAward



