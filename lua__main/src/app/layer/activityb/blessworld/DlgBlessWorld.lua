--
-- Author: tanqian
-- Date: 2017-09-07 09:38:06
--活动福泽天下对话框
local ItemBlessGetReward = require("app.layer.activityb.blessworld.ItemBlessGetReward")
local DlgBase = require("app.common.dialog.DlgBase")
local DlgBlessWorld = class("DlgBlessWorld", function()
	return DlgBase.new(e_dlg_index.dlgblessworld)
end)

function DlgBlessWorld:ctor(  )
	-- body
	self:myInit()
	
	parseView("dlg_bless_world", handler(self, self.onParseViewCallback))

	
	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgBlessWorld",handler(self, self.onDestroy))
end

--初始化成员变量
function DlgBlessWorld:myInit()
	self.tActData = nil 
end

--解析布局回调事件
function DlgBlessWorld:onParseViewCallback( pView )
	-- body
	self.pView = pView
	self:addContentView(pView) --加入内容层
	self:addContentTopSpace()
	
end

--初始化控件
function DlgBlessWorld:setupViews( )
	--ly
	self.pLyTitle     			= 		self.pView:findViewByName("lay_title")
	self.pLyList     			= 		self.pView:findViewByName("lay_list")

	--img
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.fl_fztx)
	
	--描述
	self.pLbDesc 				= 		self.pView:findViewByName("txt_tips")

	--充值按钮
	local pLayBtn = self:findViewByName("lay_btn")
	self.pBtnConsume = getCommonButtonOfContainer(pLayBtn,TypeCommonBtn.L_YELLOW, getConvertedStr(8, 10001))
	self.pBtnConsume:onCommonBtnClicked(handler(self, self.onBtnClicked))

	


end

-- 修改控件内容或者是刷新控件数据
function DlgBlessWorld:updateViews()
	print("DlgBlessWorld 64")
	self.tActData = Player:getActById(e_id_activity.blessworld)
	if not self.tActData then
		self:closeDlg(false)
		return
	end

	-- if table.nums(self.tActData.tAllRewardInfo )> 0  then
	-- 	self.pListView:setItemCount(table.nums(self.tActData.tAllRewardInfo))
	-- 	self.pListView:setItemCallback(handler(self, self.onEveryCallback))
 --    end  

    if self.tActData.sName then
		self:setTitle(self.tActData.sName)
    end

    if self.tActData.sDesc then
    	self.pLbDesc:setString(self.tActData.sDesc)
    end  


	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLyTitle,self.tActData,cc.p(0,240))
	else
		self.pActTime:setCurData(self.tActData)
	end
	--添加列表
	if not self.pListView then


		local pSize = self.pLyList:getContentSize()
	    self.pListView = MUI.MListView.new{
	   	 	viewRect   = cc.rect(0, 0, pSize.width, pSize.height),
	   	 	direction  = MUI.MScrollView.DIRECTION_VERTICAL,
	   	 	itemMargin = {left =  0,
	             right =  0,
	             top =  0,
	             bottom =  10},
		}	
		self.pLyList:addView(self.pListView)

		self.pListView:setItemCount(table.nums(self.tActData.tAllRewardInfo))
		self.pListView:setItemCallback(handler(self, self.onEveryCallback))

	  	--上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
        self.pListView:reload()
    else
    	self.pListView:notifyDataSetChange(true)
	end

    -- --刷新listView
    -- if self.pListView:getItemCount() then
    --     if self.pListView:getItemCount() > 0 then
    --         self.pListView:removeAllItems()
    --     end
    --     if self.tActData.tAllRewardInfo then
    --     	-- self.tActData:resetSort()
    --         self.pListView:setItemCount(table.nums(self.tActData.tAllRewardInfo) or 0)
    --         self.pListView:reload()
    --     end
    -- end
end

--去充值按钮点击事件
function DlgBlessWorld:onBtnClicked(pView)
	-- body
	--跳转到充值界面
	local tObject = {}
	tObject.nType = e_dlg_index.dlgrecharge --dlg类型
	sendMsg(ghd_show_dlg_by_type,tObject)  
end
-- 每帧回调 _index 下标 _pView 视图
function DlgBlessWorld:onEveryCallback( _index, _pView )
    local pView = _pView
    if not pView then
        if self.tActData.tAllRewardInfo[_index] then
            pView = ItemBlessGetReward.new()
       
        end
        pView:setContentSize(cc.size(self.pListView:getContentSize().width, pView:getContentSize().height))
    end

    if _index and self.tActData then
 		pView:setData(self.tActData.tAllRewardInfo[_index])
    end


    return pView
end

--继续方法
function DlgBlessWorld:onResume()
	-- body
	self:updateViews()
	self:regMsgs()
	
end

-- 注册消息
function DlgBlessWorld:regMsgs( )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateViews))

end

-- 注销消息
function DlgBlessWorld:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)
end


--暂停方法
function DlgBlessWorld:onPause( )
	-- body
	self:unregMsgs()

	
end

-- 析构方法
function DlgBlessWorld:onDestroy(  )
	-- body
	self:onPause()
	local pActData = Player:getActById(e_id_activity.blessworld)

	if pActData and pActData:isGetAllReward() then --已经全部领取
		Player:removeActById(e_id_activity.blessworld)
		
	end

end
return DlgBlessWorld
