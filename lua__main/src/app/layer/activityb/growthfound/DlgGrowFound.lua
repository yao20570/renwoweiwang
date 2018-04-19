-- DlgGrowFound.lua
-----------------------------------------------------
-- author: dshulan
-- updatetime:  2017-06-28 11:50:23 星期三
-- Description: 成长基金窗口
-----------------------------------------------------


local DlgBase = require("app.common.dialog.DlgBase")
local ItemGrowFound = require("app.layer.activityb.growthfound.ItemGrowFound")
local DlgAlert = require("app.common.dialog.DlgAlert")

local DlgGrowFound = class("DlgGrowFound", function()
	-- body
	return DlgBase.new(e_dlg_index.dlggrowfound)
end)

function DlgGrowFound:ctor(  )
	-- body
	self:myInit()
	self:refreshData()
	parseView("dlg_grow_funds", handler(self, self.onParseViewCallback))
end

function DlgGrowFound:myInit(  )
	-- body
	self.tItemIcons = nil
	self.tActData  = {} --活动数据
end

function DlgGrowFound:refreshData()
	self.tActData = Player:getActById(e_id_activity.growthfound)
end

--解析布局回调事件
function DlgGrowFound:onParseViewCallback( pView )
	self:addContentTopSpace()
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgGrowFound",handler(self, self.onDlgGrowFoundDestroy))
end

--初始化控件
function DlgGrowFound:setupViews()
	--设置标题
	self:setTitle(getConvertedStr(7,10078))

	self.pLayRoot = self:findViewByName("default")
	self.pLyBlack = self:findViewByName("lay_black")

	self.pLayBuyBtn = self:findViewByName("lay_btn_buy")
	--购买按钮
	self.pBuyBtn = getCommonButtonOfContainer(self.pLayBuyBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10079))
	self.pBuyBtn:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))
	--加按钮特效
	self.pBuyBtn:showLingTx()

	--设置banner图
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	local pMBanner = setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_czjj)
	pMBanner:setMBannerOpacity(255*0.5)

	--已购买人数
	self.pLbBuy = self:findViewByName("lb_buy")
	self.pLbBuy:setString(getConvertedStr(7,10080))
	self.pLbBuyPlayer = self:findViewByName("lb_playernum")
	setTextCCColor(self.pLbBuyPlayer, _cc.blue)
	--购买花费
	self.pLbCost = self:findViewByName("lb_cost")
	self.pLbCost:setString(getConvertedStr(7, 10081))
	self.pLbMoney = self:findViewByName("lb_money")
	self.pLbMoney:setString(self.tActData.tCost[1].v)
	setTextCCColor(self.pLbMoney, _cc.yellow)

	--组合文字(VIP4以上玩家可购买成长基金)
	self.pTxtVipTip = self:findViewByName("txt_vip_tip")
	local tStr = {
	    {color=_cc.yellow,text=getConvertedStr(7, 10082)},
	    {color=_cc.yellow,text=tostring(self.tActData.nVip)},
	    {color=_cc.white,text=getConvertedStr(7, 10083)},
	}
	self.pTxtVipTip:setString(tStr)
	self.pTxtVipTip:setSystemFontSize(18)

	self.pLayList = self:findViewByName("lay_list")

end

--控件刷新
function DlgGrowFound:updateViews()
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	if not self.pLbHuangjin then
		self.pLbHuangjin = self:findViewByName("lb_huangjin")
		local nNeedCost = self.tActData.tCost[1].v
		self.pLbHuangjin:setString(nNeedCost*15)
		setTextCCColor(self.pLbHuangjin, _cc.yellow)
	end

	if(not self.pListView) then
		--列表层
		self.pListView = MUI.MListView.new{
	        viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {
	        	left =  0,
	        	right =  0,
	        	top =  8,
	        	bottom =  2
	        },
		}
		self.pLayList:addView(self.pListView)
		self.pListView:setBounceable(true)

	    local nItemCnt = table.nums(self.tActData.tAwards)
	    self.pListView:setItemCount(nItemCnt)      
	    self.pListView:setItemCallback(function ( _index, _pView )
	        local pTempView = _pView
	    	if pTempView == nil then
	        	pTempView = ItemGrowFound.new()                        
	        end
	        pTempView:setItemData(self.tActData.tAwards[_index], self.tActData.bOpen)
	        return pTempView
	    end)
	    --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
	    self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true)
	end
	
	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLyBlack,self.tActData,cc.p(0,0))
	else
		self.pActTime:setCurData(self.tActData)
	end
	--已购买人数
	self.pLbBuyPlayer:setString(self.tActData.nBuyPeople)
	--如果已购买
	if self.tActData.bOpen then
		self.pBuyBtn:updateBtnText(getConvertedStr(7, 10090))
		self.pBuyBtn:setBtnEnable(false)
		self.pBuyBtn:removeLingTx()
	end

end



--刷新界面
function DlgGrowFound:updateLayer()
	self:refreshData()
	self:updateViews()	
end

--购买按钮点击事件
function DlgGrowFound:onBuyBtnClicked(pView)
	local nMyVip=Player:getPlayerInfo().nVip
	local nLimitVip = self.tActData.nVip
	if nMyVip >= nLimitVip then			--vip等级达到要求才显示购买界面

		local tObject = {}
		tObject.nType = e_dlg_index.dlgbuygrowthfound --dlg类型
		tObject.tData = self.tActData 
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		local pDlg, bNew = getDlgByType(e_dlg_index.alert)
	    if(not pDlg) then
	        pDlg = DlgAlert.new(e_dlg_index.alert)
	    end
	    pDlg:setTitle(getConvertedStr(3, 10091))		
	    pDlg:setContent(getConvertedStr(6, 10513), _cc.white, 20, 400)
	    pDlg:setRightHandler(function (  )
	        local tObject = {}
	        tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	        sendMsg(ghd_show_dlg_by_type,tObject)  
	        pDlg:closeDlg(false)
	    end)
	    pDlg:showDlg(bNew)	
	end
end

--析构方法
function DlgGrowFound:onDlgGrowFoundDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgGrowFound:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateLayer))

end
--注销消息
function DlgGrowFound:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgGrowFound:onPause( )
	-- body
	self:unregMsgs()
	local pActData = Player:getActById(e_id_activity.growthfound)
	if pActData and pActData:hasGotAllAwards() then --已经领取全部奖励, 移除该活动
		Player:removeActById(e_id_activity.growthfound)
	end
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgGrowFound:onResume(_bReshow)
	-- body
	if(_bReshow and self.pListView) then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end


return DlgGrowFound