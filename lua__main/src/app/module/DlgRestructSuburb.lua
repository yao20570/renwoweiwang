----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-11-22 20:34:37
-- Description: 改建资源田界面
-----------------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local ItemRestructSuburb = require("app.module.ItemRestructSuburb")
local DlgRestructSuburb = class("DlgRestructSuburb", function()
	return DlgCommon.new(e_dlg_index.restructsuburb, 405, 70)
end)

--_nType:默认是资源田, 2是募兵府 
function DlgRestructSuburb:ctor(_nBuildCell, _nReType)
	self.nBuildCell = _nBuildCell
	self.nReType = _nReType
	self.tBuildData = Player:getBuildData():getSuburbByCell(_nBuildCell)
	parseView("restruct_suburb", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgRestructSuburb:onParseViewCallback( pView )
	self.pView = pView
	self:addContentView(pView, false) --加入内容层,不要底部按钮层

	if self.nReType == 2 then
		self:setTitle(getConvertedStr(7, 10418)) --募兵府
	else
		self:setTitle(getConvertedStr(7, 10250)) --资源田
	end

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgRestructSuburb",handler(self, self.onDlgRestructSuburbDestroy))
end

-- 析构方法
function DlgRestructSuburb:onDlgRestructSuburbDestroy(  )
    self:onPause()
end

function DlgRestructSuburb:regMsgs(  )
end

function DlgRestructSuburb:unregMsgs(  )
end

function DlgRestructSuburb:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function DlgRestructSuburb:onPause(  )
	self:unregMsgs()
end

function DlgRestructSuburb:setupViews(  )
	--资源建筑列表
	self.pLayList = self:findViewByName("lay_content")

end

function DlgRestructSuburb:updateViews()
	if self.tBuildData == nil then return end

	local tBuild = Player:getBuildData()
	if self.tSuburbBuilds == nil then
		self.tSuburbBuilds = {}   --其他3个资源田
		for k, v in pairs(e_suburb_ids) do
			if v ~= self.tBuildData.sTid then
				local tData = tBuild:getSuburbById(v)
				table.insert(self.tSuburbBuilds, tData)
			end
		end
	end
	table.sort(self.tSuburbBuilds, function(a, b)
		return a.sTid < b.sTid
	end)

	local nListCnt = table.nums(self.tSuburbBuilds)

	--资源建筑列表
	if not self.pListView then
		self.pListView = createNewListView(self.pLayList,nil,nil,nil, 0, 0)
    	self.pListView:setItemCallback(handler(self, self.onListViewItemCallBack))
    	self.pListView:setPositionY(10)
    	--不可滑动
	    self.pListView:setIsCanScroll(false)
		self.pListView:setItemCount(nListCnt)
		self.pListView:reload(true)
	else
		self.pListView:notifyDataSetChange(true, nListCnt)
	end
end

function DlgRestructSuburb:onListViewItemCallBack( _index, _pView )
	-- body
    local pTempView = _pView
    if pTempView == nil then
        pTempView = ItemRestructSuburb.new()                        
        pTempView:setViewTouched(false)
        pTempView:setIsPressedNeedScale(false)
    end
	pTempView:setCurData(self.tSuburbBuilds[_index], self.tBuildData)
    return pTempView
end



return DlgRestructSuburb