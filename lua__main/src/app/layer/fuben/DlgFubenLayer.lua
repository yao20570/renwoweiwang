--
-- Author: liangzhaowei
-- Date: 2017-03-30 15:11:31
-- 副本主界面


local DlgBase = require("app.common.dialog.DlgBase")
-- local ViewBarUtils = require("app.common.viewbar.ViewBarUtils")

-- local ItemFubenSection = require("app.layer.fuben.ItemFubenSection")

local ItemFubenChapterList = require("app.layer.fuben.ItemFubenChapterList")
-- local ItemFubenMyArmy = require("app.layer.fuben.ItemFubenMyArmy")
-- local ItemAccoutList = require("app.layer.login.ItemAccoutList")


local DlgFubenLayer = class("DlgFubenLayer", function()
	return DlgBase.new(e_dlg_index.fubenlayer)
end)


function DlgFubenLayer:ctor()
	-- body
	self:myInit()

	parseView("dlg_fuben_layer", handler(self, self.onParseViewCallback))
end

--初始化参数
function DlgFubenLayer:myInit()
	-- body
	self.tImgLine 		= 		{} 		-- 路线
	self.tItemDrop = {} --item 
 	self.tItemPos = {} --位置

 	self.pFoundItem 		= nil 		-- 找到那一项
	self.bIsFoundItem 		= false 		-- 是否找到了
	self.pCurDropIndex 		= nil 		-- 当前拖拽的下标

	self.pScetionData = {} -- 章节数据

	self.tSectionList = {} -- 章节展示列表

	self.pNowSection = {} --当前章节数据
end

--初始化数据
function DlgFubenLayer:initData()
	self.pScetionData = Player:getFuben():getShowChapter() -- 初始化副本数据

	if self.pScetionData and table.nums(self.pScetionData)> 0 then
		table.sort(self.pScetionData,function (a,b)
			return a.nId > b.nId
		end)
	end

	self.tSectionList = self:getScetionList()
end

--解析布局回调事件
function DlgFubenLayer:onParseViewCallback( pView )

	self:addContentView(pView) --加入内容层
	self:setTitle(getConvertedStr(5, 10002)) --设置标题
	
	self:onResume()
end


-- 没帧回调 _index 下标 _pView 视图
function DlgFubenLayer:everyCallback( _index, _pView )
	local pView = _pView
	if not pView then
		pView = ItemFubenChapterList.new()
		pView:setViewTouched(false)
		pView:setIsPressedNeedScale(false)
		-- pView:onMViewClicked(handler(self,self.onViewClick))
	end

	if _index and self.tSectionList[_index] then
		pView:setCurData(self.tSectionList[_index])	
	end


	--新手引导点击副本第一章节中心点
	-- doDelayForSomething(self, function()
	-- 	-- body
	-- 	if table.nums(self.pScetionData) == 1 and _index == 1 then
	-- 		Player:getNewGuideMgr():setNewGuideFinger(pView, e_guide_finer.fuben_first_chapter)
	-- 	end
	-- end, 0.02)

	return pView
end

--view点击回调
-- function DlgFubenLayer:onViewClick(pView)

-- 	if not pView then
-- 		return
-- 	end

-- 	local tData = pView:getData()
-- 	if tData and tData.nId then
-- 	    local tObject = {}
-- 	    tObject.tData = tData.nId --章节id
-- 	    tObject.nType = e_dlg_index.fubenmap --dlg类型
-- 	    sendMsg(ghd_show_dlg_by_type,tObject)
-- 	end

-- 	--新手引导点击副本第一章节中心点完成
-- 	Player:getNewGuideMgr():setNewGuideFingerClicked(e_guide_finer.fuben_first_chapter)


-- end
function DlgFubenLayer:setupViews(  )
	-- body
	local pLayMain = self:findViewByName("ly_main")
	pLayMain:setIgonreOtherHeight(true)
end

-- 修改控件内容或者是刷新控件数据
function DlgFubenLayer:updateViews()
	-- body
	self:initData()

	gRefreshViewsAsync(self, 1, function ( _bEnd, _index )


		if _index == 1 then

			if not self.pLyList then
				self.pLyList = self:findViewByName("ly_list")
				self.pLyList:setClipping(false)
			end


			-- if not  self.pLbTitleTips then
			-- 	self.pLbTitleTips = self:findViewByName("lb_title")
			-- 	self.pLbTitleTips:setString(getConvertedStr(5, 10003))
			-- end

			self:refreshListView()
		end

	end)

end

-- 刷新listview
function DlgFubenLayer:refreshListView()
	if(not self.pScetionData) then
		return
	end


	local nListCnt = table.nums(self.tSectionList)
	if not self.pListView then
		self.pListView = createNewListView(self.pLyList,nil,nil,nil, 15, 1)
		local pUpArrow, pDownArrow = getUpAndDownArrow()
		self.pListView:setUpAndDownArrow(pUpArrow, pDownArrow)
		if nListCnt > 0  then
			self.pListView:setItemCount(nListCnt)
			self.pListView:setItemCallback(handler(self, self.everyCallback))
			self.pListView:reload(true)
		end
	else
		-- 重置长度
		self.pListView:setItemCount(nListCnt or 0) 
		self.pListView:notifyDataSetChange(true)
	end

end

--当前星级列表数据
function DlgFubenLayer:getScetionList()
	local tList = {}
	local tData = self.pScetionData

	if tData then
		--将列表分成2个2个为一组的列表
		tList = separateTable(tData, 2) 
	end

	return tList
end


--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgFubenLayer:onResume(_bReshow)
	-- body
	self:updateViews()
	self:regMsgs()
	
end

-- 注册消息
function DlgFubenLayer:regMsgs( )
	-- 注册副本信息刷新消息
	regMsg(self, gud_refresh_fuben, handler(self, self.refreshState))
end

-- 注销消息
function DlgFubenLayer:unregMsgs(  )
	-- 销毁副本信息刷新消息
	unregMsg(self, gud_refresh_fuben)
end

--刷新方法
function DlgFubenLayer:refreshState()
	-- body
	self:updateViews()
end

--暂停方法
function DlgFubenLayer:onPause( )
	-- body
	self:unregMsgs()
end


--析构方法
function DlgFubenLayer:onDestroy(  )
	self:onPause( )
end

return DlgFubenLayer