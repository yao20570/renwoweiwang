-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-15 11:30:40 星期一
-- Description: 任务 item 项目  TypeTaskItemSize（大小类型） 600*130 570*130
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")
local MCommonProgressBar = require("app.common.progressbar.MCommonProgressBar")
local ItemResPrize = require("app.layer.task.ItemResPrize")

local TaskItem = class("TaskItem", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--_nType：TypeTaskItemSize（大小类型）
function TaskItem:ctor( _nType )
	-- body
	self:myInit(_nType)
	if self.nSizeType == TypeTaskItemSize.N then
		parseView("task_info_layer_normal", handler(self, self.onParseViewCallback))
	elseif self.nSizeType == TypeTaskItemSize.H then
		parseView("task_info_layer_height", handler(self, self.onParseViewCallback))
	end
	
end

--初始化成员变量
function TaskItem:myInit( _nType )
	-- body
	self.nSizeType 			= 	_nType or self.nSizeType  --item大小 	
	self.tCurData 			= 	nil 				--当前数据	
	self.nHandler 			= 	nil 				--回调事件
	self.bIsIconCanTouched 	= 	false 				--	
end

--解析布局回调事件
function TaskItem:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("TaskItem",handler(self, self.onTaskItemDestroy))
end

--初始化控件
function TaskItem:setupViews( )
	-- body
	self.pLayRoot = self:findViewByName("root")
	--任务描述名字
	self.pLbName 			= 		self:findViewByName("lb_task")
	if self.nSizeType == TypeTaskItemSize.N then
		setTextCCColor(self.pLbName, _cc.pwhite)
	elseif self.nSizeType == TypeTaskItemSize.H then
		setTextCCColor(self.pLbName, _cc.blue)
	end
	--icon
	self.pLayIcon 			= 		self:findViewByName("lay_icon")
	self.pLayIcon:setViewTouched(self.bIsIconCanTouched)
	local data = nil
	self.pIconImg = MUI.MImage.new("ui/daitu.png")	
	self.pLayIcon:addView(self.pIconImg, 10)
	centerInView(self.pLayIcon, self.pIconImg)

	--self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, nil, TypeIconGoodsSize.M)
	--self.pIcon:setIconIsCanTouched(self.bIsIconCanTouched)	
	--按钮层
	self.pLayBtn 			= 		self:findViewByName("lay_right_btn")
	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, getConvertedStr(6, 10216))	
	self.pBtn:onCommonBtnClicked(handler(self, self.onBtnClicked))

	self.pImgYLQ = self:findViewByName("img_yilingqu")
	self.pImgYLQ:setVisible(false)
	--进度条背景
	self.pLayBarBg 			= 		self:findViewByName("lay_bar_bg")
	self.pProgressBar 		= 		MCommonProgressBar.new({bar = "v1_bar_yellow_9.png",barWidth = 300, barHeight = 14})
	self.pLayBarBg:addView(self.pProgressBar, 10)
	centerInView(self.pLayBarBg, self.pProgressBar)		
	--固定标签
	self.pLbTip1 			= 		self:findViewByName("lb_tip_1")
	setTextCCColor(self.pLbTip1, _cc.white)
	self.pLbTip1:setString(getConvertedStr(6, 10218))

	self.tRichGroup = {}
	local x = self.pLbTip1:getPositionX() + self.pLbTip1:getWidth()
	local y = 18
	for i = 1, 4 do
		local pItemResPrize = ItemResPrize.new(true)
		y = self.pLbTip1:getPositionY() - pItemResPrize:getHeight()/2
		pItemResPrize:setPosition(x + (i-1)*90, y)
		self.pLayRoot:addView(pItemResPrize, 10)
		self.tRichGroup[i] = pItemResPrize		
	end		
	--进度分数标签
	self.pLbProgress 		= 		self:findViewByName("lb_progress")
	setTextCCColor(self.pLbProgress, _cc.white)
	self.pLbProgress:setString("")	

end

-- 修改控件内容或者是刷新控件数据
function TaskItem:updateViews( )
	-- body
	if self.tCurData and self.tCurData.nGtype then
		if self.tCurData.nGtype == e_type_goods.type_task then
			self:updateMissionInfo()			
		elseif self.tCurData.nGtype == e_type_goods.type_daily then
			self:updateDailyTaskInfo()			
		elseif self.tCurData.nGtype == e_type_goods.type_country_task then
			self:updateCountryTaskInfo()			
		end 
	else
		self:setVisible(false)				
	end
end

function TaskItem:updateMissionInfo(  )--任务
	-- body
	self:setVisible(true)	

	--self.pIcon:setCurData(self.tCurData)	
	self.pIconImg:setCurrentImage(getTaskTxIconByType(self.tCurData.nType))	
	
	self.pLbName:setString(self.tCurData.sName)
	self.pProgressBar:setPercent(self.tCurData.nCurNum/self.tCurData.nTargetNum*100)
	self.pLbProgress:setString(self.tCurData.nCurNum.."/"..self.tCurData.nTargetNum)
	local tdropitems = getDropById(self.tCurData.nDropId)		
	for k, v in pairs(self.tRichGroup) do			
		if tdropitems[k] then
			v:setCurData(tdropitems[k])				
		else
			v:setCurData(nil)
		end
		if k > 1 then
			local pPreres = self.tRichGroup[k - 1]
			if pPreres then
				v:setPositionX(pPreres:getPositionX() + pPreres:getWidth() + 20)
			end				
		end
	end
	--任务是否已经完成
	self.pBtn:setBtnEnable(true)
	if self.tCurData.nIsFinished == 1 then--只区分是否完成
		self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
		self.pBtn:updateBtnText(getConvertedStr(6, 10217))
		self.pBtn:setVisible(true)
	else
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(getConvertedStr(6, 10216))
		local nMode = tonumber(self.tCurData.nMode or 0)
		if  nMode == e_task_modes.zxrw then
			self.pBtn:setVisible(false)
		else
			self.pBtn:setVisible(true)
		end
	end	
	--是否显示前往按钮特效
	local bShowBtnEff = false--是否显示前往按钮特效
	local pMainTaskData = Player:getPlayerTaskInfo():getCurAgencyTask()
	if pMainTaskData and pMainTaskData.nMode == e_task_modes.zxrw then
		local tParam = luaSplitMuilt(pMainTaskData.sLinked, ":", "|")
		if tParam and tParam[2] then
			for k, v in pairs(tParam[2]) do
				local nID = tonumber(v or 0)
				if nID == self.tCurData.sTid then
					bShowBtnEff = true
					break
				end
			end
		end    
	end
	self:showGotoBtnTx(bShowBtnEff)	
end

function TaskItem:updateDailyTaskInfo( )--每日目标
	-- body		
	self:setVisible(true)	

	-- self.pIcon:setCurData(self.tCurData)	
	self.pIconImg:setCurrentImage(getTaskTxIconByType(self.tCurData.nType))	
	
	self.pLbName:setString(self.tCurData.sName)
	self.pProgressBar:setPercent(self.tCurData.nCurNum/self.tCurData.nTargetNum*100)
	self.pLbProgress:setString(self.tCurData.nCurNum.."/"..self.tCurData.nTargetNum)
	local tdropitems = getDropById(self.tCurData.nDropId)		
	for k, v in pairs(self.tRichGroup) do			
		if tdropitems[k] then
			v:setCurData(tdropitems[k])				
		else
			v:setCurData(nil)
		end
		if k > 1 then
			local pPreres = self.tRichGroup[k - 1]
			if pPreres then
				v:setPositionX(pPreres:getPositionX() + pPreres:getWidth() + 20)
			end				
		end
	end
	--任务是否已经完成
	self.pBtn:setBtnEnable(true)
	self.pImgYLQ:setVisible(false)	
	if self.tCurData.nIsFinished == 1 then--已完成		
		if self.tCurData.nIsGetPrize == 1 then --已领取		
			self.pImgYLQ:setVisible(true)
			self.pBtn:setVisible(false)							
		else
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(6, 10217))
			self.pBtn:setVisible(true)			
		end
	else--未完成		
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(getConvertedStr(6, 10216))
		self.pBtn:setVisible(true)					
	end
end

function TaskItem:updateCountryTaskInfo(  )--国家限时任务
	-- body
	self:setVisible(true)	

	--self.pIcon:setCurData(self.tCurData)	
	self.pIconImg:setCurrentImage(getTaskTxIconByType(self.tCurData.nType))	
	
	self.pLbName:setString(self.tCurData.sName)
	self.pProgressBar:setPercent(self.tCurData.nCurNum/self.tCurData.nTargetNum*100)
	self.pLbProgress:setString(self.tCurData.nCurNum.."/"..self.tCurData.nTargetNum)
	local tdropitems = getDropById(self.tCurData.nDropId)		
	for k, v in pairs(self.tRichGroup) do			
		if tdropitems[k] then
			v:setCurData(tdropitems[k])				
		else
			v:setCurData(nil)
		end
		if k > 1 then
			local pPreres = self.tRichGroup[k - 1]
			if pPreres then
				v:setPositionX(pPreres:getPositionX() + pPreres:getWidth() + 20)
			end				
		end
	end
	--任务是否已经完成
	self.pBtn:setBtnEnable(true)
	self.pImgYLQ:setVisible(false)
	if self.tCurData.nIsFinished == 1 then--已完成
		if self.tCurData.nIsGetPrize == 0 then --未领取
			self.pBtn:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtn:updateBtnText(getConvertedStr(6, 10217))
			self.pBtn:setVisible(true)
		else
			self.pImgYLQ:setVisible(true)
			self.pBtn:setVisible(false)
		end
	else--未完成
		self.pBtn:updateBtnType(TypeCommonBtn.M_BLUE)
		self.pBtn:updateBtnText(getConvertedStr(6, 10216))
		local nMode = tonumber(self.tCurData.nMode or 0)
		if  nMode == e_task_modes.zxrw then
			self.pBtn:setVisible(false)
		else
			self.pBtn:setVisible(true)
		end
	end		
end

--隐藏底部背景图
function TaskItem:hideDiBg()
	-- body
	if self.pLayRoot then
		self.pLayRoot:setBackgroundImage("ui/daitu.png",{scale9 = true, capInsets=cc.rect(63,65, 1, 1)})
	end
end
-- 析构方法
function TaskItem:onTaskItemDestroy(  )
	-- body
end

function TaskItem:setCurData( _data )
	-- body
	self.tCurData = _data
	self:updateViews()
end

function TaskItem:getData(  )
	-- body
	return self.tCurData
end

--设置点击事件回到
function TaskItem:setClickCallBack( _handler)
	-- body
	self.nHandler = _handler
end

--按钮点击回调
function TaskItem:onBtnClicked( pView )
	-- body
	if self.nHandler then
		self.nHandler(self.tCurData)
	end	
end
--icon点击属性设置
function TaskItem:setIsIconCanTouched( _biscan )
	-- body
	self.bIsIconCanTouched = _biscan or false
	self:updateViews()
end
--Icon
function TaskItem:showGotoBtnTx( bShow )
	-- body
	local bIsShow = bShow or false
	if not self.pBtn or not self.tCurData then
		return 
	end
	if self.tCurData.nIsFinished ~= 1 then
		if bIsShow == true then
			self.pBtn:showLingTx()
		else
			self.pBtn:removeLingTx()
		end
	end
	
end

return TaskItem