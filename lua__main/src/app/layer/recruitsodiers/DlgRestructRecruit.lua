----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2018-4-2 17:28:37
-- Description: 改建募兵府界面
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemRestructCamp = require("app.layer.recruitsodiers.ItemRestructCamp")
local DlgRestructRecruit = class("DlgRestructRecruit", function()
	return DlgCommon.new(e_dlg_index.restructrecruit, 410, 70)
end)

--_nRecruitTp: 当前募兵类型(1步,2骑,3弓)
function DlgRestructRecruit:ctor(_nRecruitTp)
	self.nRecruitTp = _nRecruitTp
	self.tBuildData = Player:getBuildData():getBuildById(e_build_ids.mbf, true)
	parseView("restruct_suburb", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgRestructRecruit:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, false) --加入内容层,不要底部按钮层

	self:setTitle(getConvertedStr(7, 10418)) --建造募兵府

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRestructRecruit",handler(self, self.onDlgRestructRecruitDestroy))
end

-- 析构方法
function DlgRestructRecruit:onDlgRestructRecruitDestroy(  )
    self:onPause()
end

function DlgRestructRecruit:regMsgs(  )
end

function DlgRestructRecruit:unregMsgs(  )
end

function DlgRestructRecruit:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgRestructRecruit:onPause(  )
	self:unregMsgs()
end

function DlgRestructRecruit:setupViews(  )
	--资源建筑列表
	self.pLayList 			= 		self:findViewByName("lay_con2")
end

function DlgRestructRecruit:updateViews()
	if self.tBuildData == nil then return end

	local tBuild = Player:getBuildData()
	if self.tRecruitBuilds == nil then
		self.tRecruitBuilds = {}   --3个兵营
		for k, v in pairs(e_camp_ids) do
			local tData = tBuild:getBuildById(v, true)
			table.insert(self.tRecruitBuilds, tData)
		end
	end

	table.sort(self.tRecruitBuilds, function(a, b)
		return a.sTid < b.sTid
	end)

	local nListCnt = table.nums(self.tRecruitBuilds)

	--兵营建筑列表
	if not self.pListView then
		self.pListView = createNewListView(self.pLayList,nil,nil,nil, 0, 10)
    	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
    	--不可滑动
	    self.pListView:setIsCanScroll(false)
		self.pListView:setItemCount(nListCnt)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(false)
	end
end

function DlgRestructRecruit:onListViewItemCallBack( _index, _pView )
	-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemRestructCamp.new(_index)                        
        pTempView:setViewTouched(false)
        pTempView:setIsPressedNeedScale(false)
    end
	pTempView:setCurData(self.tRecruitBuilds[_index], self.tBuildData, _index)
    return pTempView
end



return DlgRestructRecruit