-----------------------------------------------------
-- author: dengshulan
-- updatetime:  2017-11-23 11:12:33 星期四
-- Description: 重建资源田item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemRestructSuburb = class("ItemRestructSuburb", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nType：列表
function ItemRestructSuburb:ctor()
	-- body
	self:myInit()
	parseView("item_suburb", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemRestructSuburb:myInit(  )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function ItemRestructSuburb:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	-- self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemRestructSuburb",handler(self, self.onItemRestructSuburbDestroy))
end

--初始化控件
function ItemRestructSuburb:setupViews( )
	-- body
	self.pLayItem 			= 		self:findViewByName("item_suburb")

	--img
	self.pImgSuburb 		= 		self:findViewByName("img_suburb")

	--按钮
	self.pLayBtn  	 		= 		self:findViewByName("lay_btn")
	self.pBtnAction = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_YELLOW,getConvertedStr(7, 10251))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))

	--资源田名字
	self.pLbName 			= 		self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.white)
	--资源田介绍
	self.pLbDesc 			= 		self:findViewByName("lb_describe")
	setTextCCColor(self.pLbDesc, _cc.lgray)
	--资源田已建造
	self.pLbHasBuild 		= 		self:findViewByName("lb_hasbuild")
	setTextCCColor(self.pLbHasBuild, _cc.lgray)
	
end

-- 修改控件内容或者是刷新控件数据
function ItemRestructSuburb:updateViews(  )
	if not self.tCurData then return end
	if not self.pImgLabel then
		self.pImgLabel = MImgLabel.new({text="", size = 18, parent = self.pLayItem})
		self.pImgLabel:setImg("#v2_img_zjm_shijin.png", 1, "left")
		local pBtnSize = self.pLayBtn:getContentSize()
		self.pImgLabel:followPos("center", self.pLayBtn:getPositionX()+pBtnSize.width/2, self.pLayBtn:getPositionY()+pBtnSize.height+10, 5)
	end
	local nRebuildTime = 0  --改建时间根据改建等级, 读配表
	local tParam = luaSplitMuilt(getBuildParam("rebuildTime"), ";", ":", "-")
	if self.tBuildDatas.nLv >= tonumber(tParam[1][1]) and self.tBuildDatas.nLv <= tonumber(tParam[1][2]) then
		nRebuildTime = tonumber(tParam[2])
	end
	local str = {
		{text = formatTimeToHms(nRebuildTime), color = _cc.lgray}
	}
	self.pImgLabel:setString(str)
	self.pLbName:setString(self.tCurData.sName)
	self.pLbDesc:setString(self.tCurData.sDes)
	local tHasBuilds = Player:getBuildData():getSuburbOpenedById(self.tCurData.sTid)
	self.pLbHasBuild:setString(string.format(getConvertedStr(7, 10252), #tHasBuilds))

	self.pImgSuburb:setCurrentImage(self.tCurData.tShowData.img)
	self.pImgSuburb:setScale(0.7)
end


-- 析构方法
function ItemRestructSuburb:onItemRestructSuburbDestroy(  )
	-- body
end

--设置当前数据
--_nLv:改建的等级
function ItemRestructSuburb:setCurData(_data, _tBuildDatas)
	self.tCurData = _data
	self.tBuildDatas = _tBuildDatas
	self:updateViews()
end

--建造按钮点击事件
function ItemRestructSuburb:onActionClicked( pView )
	local tObj = {}

	local buildQueueId = 1 --建筑队列 1.默认队列 2.购买黄金队列
	local tUpingLists = Player:getBuildData():getBuildUpdingLists()
	if tUpingLists and table.nums(tUpingLists) > 0 then
		--判断是否已经开启第二条建造队列
		local nHad = Player:getBuildData().nHadSecondQue
		if table.nums(tUpingLists) == 1 and nHad then
			buildQueueId = 2
		elseif table.nums(tUpingLists) == 1 and not nHad then
			--需要开启黄金队列吗?
		end
	end
	tObj.nCell = self.tBuildDatas.nCellIndex
	tObj.nBuildId = self.tBuildDatas.sTid
	tObj.nType = 2 		--改建
	tObj.nRt = 0
	tObj.nToWhatBuildId = self.tCurData.sTid		--改建成哪种资源田id
	tObj.buildQueueId = buildQueueId
	tObj.sName = self.tCurData.sName
	sendMsg(ghd_more_action_build_msg, tObj)
end


return ItemRestructSuburb