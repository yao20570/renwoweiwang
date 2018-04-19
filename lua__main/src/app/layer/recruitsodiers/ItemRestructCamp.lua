-----------------------------------------------------
-- author: dengshulan
-- updatetime:  2018-4-2 19:42:40 星期一
-- Description: 重建募兵府item
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemRestructCamp = class("ItemRestructCamp", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--nType：列表
function ItemRestructCamp:ctor(_index)
	-- body
	self:myInit(_index)
	parseView("item_suburb", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemRestructCamp:myInit( _index )
	-- body
	self.tCurData 		= 	 nil 		--当前数据
end

--解析布局回调事件
function ItemRestructCamp:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemRestructCamp",handler(self, self.onItemRestructCampDestroy))
end

--初始化控件
function ItemRestructCamp:setupViews( )
	-- body
	self.pLayItem 			= 		self:findViewByName("item_suburb")
	self.pImgBg 			= 		self:findViewByName("img_bg")
	self.pImgBg:setFlippedY(true)
	self.pImgBg:setVisible(true)
	self.pImgLine1 			= 		self:findViewByName("img_line1")
	self.pImgLine1:setVisible(false)
	-- self.pImgLine2 			= 		self:findViewByName("img_line2")
	-- self.pImgLine2:setVisible(true)

	--img
	self.pImgSuburb 		= 		self:findViewByName("img_suburb")
	self.pImgSuburb:setPositionX(0)

	--按钮
	self.pLayBtn  	 		= 		self:findViewByName("lay_btn")
	self.pBtnAction = getCommonButtonOfContainer(self.pLayBtn,TypeCommonBtn.M_YELLOW,getConvertedStr(7, 10251))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onActionClicked))

	local nPosX = 180

	--资源田名字
	self.pLbName 			= 		self:findViewByName("lb_name")
	setTextCCColor(self.pLbName, _cc.blue)
	self.pLbName:setPositionX(nPosX)
	--资源田介绍
	self.pLbDesc 			= 		self:findViewByName("lb_describe")
	setTextCCColor(self.pLbDesc, _cc.lgray)
	self.pLbDesc:setPositionX(nPosX)
	--资源田已建造
	self.pLbHasBuild 		= 		self:findViewByName("lb_hasbuild")
	setTextCCColor(self.pLbHasBuild, _cc.lgray)
	self.pLbHasBuild:setPositionX(nPosX)
	
end

-- 修改控件内容或者是刷新控件数据
function ItemRestructCamp:updateViews(  )
	if not self.tCurData then return end
	if not self.pImgLabel then
		self.pImgLabel = MImgLabel.new({text="", size = 18, parent = self.pLayItem})
		self.pImgLabel:setImg("#v1_img_shizhong02.png", 1, "left")
		local pBtnSize = self.pLayBtn:getContentSize()
		self.pImgLabel:followPos("center", self.pLayBtn:getPositionX()+pBtnSize.width/2, self.pLayBtn:getPositionY()+pBtnSize.height+6, 5)
		setTextCCColor(self.pImgLabel, _cc.red)
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
	self.pImgLabel:showImg()

	if self.tBuildDatas.nLv == 0 then
		self.pImgLabel:hideImg()
		self.pImgLabel:setString("")
	end

	self.pBtnAction:updateBtnType(TypeCommonBtn.M_BLUE)
	
	if self.tBuildDatas.nRecruitTp == self.nIndex then
		self.pImgLabel:hideImg()
		self.pImgLabel:setString(getConvertedStr(7, 10420))
		self.pBtnAction:setBtnEnable(false)
	else
		if self.tBuildDatas.nLv > 0 then
			self.pImgLabel:showImg()
		end
		self.pBtnAction:setBtnEnable(true)
	end

	local sName = ""
	if self.tCurData.sTid == e_build_ids.infantry then
		sName = getConvertedStr(1, 10081)..getConvertedStr(7, 10439) --步兵募兵府
	elseif self.tCurData.sTid == e_build_ids.sowar then
		sName = getConvertedStr(1, 10082)..getConvertedStr(7, 10439) --骑兵募兵府
	elseif self.tCurData.sTid == e_build_ids.archer then
		sName = getConvertedStr(1, 10083)..getConvertedStr(7, 10439) --弓兵募兵府
	end
	self.pLbName:setString(sName)
	self.sName = sName

	self.pImgSuburb:setScale(0.5)
	
	self.pLbDesc:setString(self.tCurData.sDes)

	self.pImgSuburb:setCurrentImage(self.tCurData.tShowData.img)
end


-- 析构方法
function ItemRestructCamp:onItemRestructCampDestroy(  )
	-- body
end

--设置当前数据
--_nLv:改建的等级
function ItemRestructCamp:setCurData(_data, _tBuildDatas, _index)
	self.tCurData = _data
	self.tBuildDatas = _tBuildDatas
	self.nIndex 		= 	 _index
	self:updateViews()
end

--建造按钮点击事件
function ItemRestructCamp:onActionClicked( pView )
	if self.tBuildDatas.nRecruitTp == nil then
		SocketManager:sendMsg("reqBuildRecruitHouse",
			{self.tBuildDatas.sTid,self.tBuildDatas.nCellIndex,self.nIndex,self.sName},
			handler(self, self.onBuildResponse))
	else
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
		tObj.buildQueueId = buildQueueId
		tObj.nType = 2 		--改建
		tObj.nCell = self.tBuildDatas.nCellIndex
		tObj.nRt = self.nIndex 		--募兵府士兵类型 1.步兵 2.骑兵 3.弓兵
		tObj.nBuildId = self.tBuildDatas.sTid
		tObj.sName = self.sName
		sendMsg(ghd_more_action_build_msg, tObj)
	end
end

function ItemRestructCamp:onBuildResponse( __msg, __oldMsg )
	-- if __msg.head.type == MsgType.reqBuildRecruitHouse.id then
	-- 	if __msg.head.state == SocketErrorType.success then
	-- 		closeDlgByType(e_dlg_index.restructrecruit)
	-- 		if __oldMsg[4] then
	-- 			TOAST(string.format(getConvertedStr(7, 10419), __oldMsg[4])) --"xx开始建造"
	-- 		end
 --        end
	-- end
	closeDlgByType(e_dlg_index.restructrecruit)
end

return ItemRestructCamp