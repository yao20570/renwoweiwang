-- DlgWelcomeBack.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-04-12 12:00:00
-- 王者归来
---------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")
local ItemWelcomeBack = require("app.layer.activityb.welcomeback.ItemWelcomeBack")

local DlgWelcomeBack = class("DlgWelcomeBack", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgwelcomeback)
end)

function DlgWelcomeBack:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_welcome_back", handler(self, self.onParseViewCallback))
end

function DlgWelcomeBack:myInit(  )
	-- body
	self.tItemIcons = nil
	self.tActData  = {} --活动数据
end

--解析布局回调事件
function DlgWelcomeBack:onParseViewCallback( pView )
	-- body
	self:addContentTopSpace()
	self:addContentView(pView) --加入内容层
	self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgWelcomeBack",handler(self, self.onDlgWelcomeBackDestroy))
end

--初始化控件
function DlgWelcomeBack:setupViews()
	--设置标题
	self:setTitle(getConvertedStr(7, 10449))

	self.pLayRoot = self:findViewByName("default")
	self.pLayTopTime  = self:findViewByName("lay_top_time")
	self.pLayList = self:findViewByName("lay_con")

	--设置banner图
	self.pLayBannerBg = self:findViewByName("lay_banner_bg")
	setMBannerImage(self.pLayBannerBg,TypeBannerUsed.ac_ykzk)

end

--控件刷新
function DlgWelcomeBack:updateViews()
	self.tActData = Player:getActById(e_id_activity.welcomeback)
	if not self.tActData then
		self:closeDlg(false)
		return
	end
	local tConf = self.tActData.tConf
	local nItemCnt = table.nums(tConf)
	if(not self.pListView) then
		--列表层
		self.pListView = MUI.MListView.new{
	        viewRect = cc.rect(0, 0, self.pLayList:getWidth(), self.pLayList:getHeight()),
	        direction = MUI.MScrollView.DIRECTION_VERTICAL,
	        itemMargin = {
	        	left =  0,
	        	right =  0,
	        	top =  0,
	        	bottom = 10
	        },
		}
		self.pLayList:addView(self.pListView)
		self.pListView:setBounceable(true)
	    self.pListView:setItemCount(nItemCnt)      
	    self.pListView:setItemCallback(function ( _index, _pView )
	        local pTempView = _pView
	    	if pTempView == nil then
	        	pTempView = ItemWelcomeBack.new()                        
	        end
	        pTempView:setItemData(_index)
	        return pTempView
	    end)
	    --上下箭头
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow, true)
	    self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nItemCnt)
	end

	if not self.pActTime then
		--活动时间
		self.pActTime = createActTime(self.pLayTopTime,self.tActData,cc.p(0,0))
	else
		self.pActTime:setCurData(self.tActData)
	end
	if not self.tAc then
		self.tAc = Player:getActById(e_id_activity.welcomeback)
	end


end


--刷新界面
function DlgWelcomeBack:updateLayer()
	self:updateViews()	
end


--析构方法
function DlgWelcomeBack:onDlgWelcomeBackDestroy(  )
	-- body
	self:onPause()
end

--注册消息
function DlgWelcomeBack:regMsgs(  )
	-- body
	regMsg(self, gud_refresh_activity, handler(self, self.updateLayer))

end
--注销消息
function DlgWelcomeBack:unregMsgs(  )
	-- body
	unregMsg(self, gud_refresh_activity)

end
--暂停方法
function DlgWelcomeBack:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgWelcomeBack:onResume(_bReshow)
	-- body
	if(_bReshow and self.pListView) then
		-- 如果是重新显示，定位到顶部
		self.pListView:scrollToBegin()
	end
	self:updateViews()
	self:regMsgs()
end


return DlgWelcomeBack