-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-14 11:57:23 星期三
-- Description: 纣王试炼主页
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local LayImgLlabel = require("app.layer.activityb.zhouwangtrial.LayImgLlabel")
local LayZhouWangTrialMain = class("LayZhouWangTrialMain", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
end)


function LayZhouWangTrialMain:ctor(_tSize)
	-- body
	self:setContentSize(_tSize)
	self:myInit()
	parseView("layout_zhouwang_trial_main", handler(self, self.onParseViewCallback))
end
--解析布局回调事件
function LayZhouWangTrialMain:onParseViewCallback( pView )
	-- body
	
	self:addView(pView)
	self:setupViews()	
	self:onResume()
	 --注册析构方法
	self:setDestroyHandler("LayZhouWangTrialMain",handler(self, self.onDestroy))
end

-- --初始化参数
function LayZhouWangTrialMain:myInit()
	-- body
	self.tTips = {}
end

--初始化控件
function LayZhouWangTrialMain:setupViews( )
	-- body	
	self.pLayRoot 		= 	self:findViewByName("lay_root")
	self.pView 	  		= 	self:findViewByName("lay_view")
	self.pLayCenter 	= 	self:findViewByName("lay_center")--容纳时间显示
	self.pLayBot 		= 	self:findViewByName("lay_bot")
	self.pLayCont 		= 	self:findViewByName("lay_cont")

	self.pLbTitle 		= 	self:findViewByName("lb_title")--
	self.pLayPrize 		= 	self:findViewByName("lay_prize")
	self.pLayRewards 	= 	self:findViewByName("lay_rewards")

	self.pLayBtn 	= 	self:findViewByName("lay_btn")

	self.pLbTitle:setString(getConvertedStr(6, 10686))
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_BLUE, getConvertedStr(6, 10786))
	self.pBtn:onCommonBtnClicked(handler(self, self.onAgainstBtnCallBack))

	local tRewards = nil
	local pItem = getGoodsByTidFromDB(e_item_ids.zhouwangBox)	
	if pItem and pItem.sDropId then
		tRewards = getDropById(pItem.sDropId)		
		if not tRewards then
			tRewards = {}
		end
		local nItemCnt = #tRewards
		if nItemCnt > 6 then
			nItemCnt = 6
			--不显示物品数量
			for k, v in pairs(tRewards) do
				v.nCt = 0
			end			
		end
		local nHeight = self.pLayRewards:getHeight()
		local nWidth = (nItemCnt*108 + (nItemCnt)*2*10)*nHeight/108
		self.pLayRewards:setLayoutSize(nWidth, nHeight)
		self.pLayRewards:setPositionX((self.pLayPrize:getWidth() - nWidth)/2)
	end
	local pListView = gRefreshHorizontalList(self.pLayRewards, tRewards, 10, 10, true)	
	if not self.pRewardList then
		self.pRewardList = pListView
		self.pRewardList:setIsCanScroll(false)
	end
end

-- 修改控件内容或者是刷新控件数据
function LayZhouWangTrialMain:updateViews(  )
	-- body
	local pData = Player:getActById(e_id_activity.zhouwangtrial)
	if not pData then
		return
	end
	if not self.pItemTime then
		self.pItemTime = createActTime(self.pLayCenter,pData,cc.p(0,self.pLayCenter:getHeight() - 30))
	else
		self.pItemTime:setCurData(pData)
	end	
	for k, v in pairs(pData.sDesc) do
		if not self.tTips[k] then
			local pLay = LayImgLlabel.new()  		
			self.pLayPrize:addView(pLay, 10)
			self.tTips[k] = pLay
			self.tTips[k]:setPosition(0, self.pLayRewards:getPositionY()-pLay:getHeight()*k)
		end
		self.tTips[k]:setData(v)
	end	
end

function LayZhouWangTrialMain:onAgainstBtnCallBack( pView )
	-- body
	myprint("前往讨伐")
	sendMsg(ghd_world_dot_near_my_city, {nDotType = e_type_builddot.zhouwang})
	closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
	sendMsg(ghd_home_show_base_or_world, 2)--主城或世界跳转		
end

--析构方法
function LayZhouWangTrialMain:onDestroy(  )
	self:onPause()
end

-- 注册消息
function LayZhouWangTrialMain:regMsgs( )
	-- body	
    regMsg(self, gud_refresh_activity, handler(self, self.updateViews))    
end

-- 注销消息
function LayZhouWangTrialMain:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
end
--暂停方法
function LayZhouWangTrialMain:onPause( )
	-- body
	self:unregMsgs()
	
end

--继续方法
function LayZhouWangTrialMain:onResume( )
	-- body
	self:regMsgs()
	self:updateViews()
end

return LayZhouWangTrialMain
