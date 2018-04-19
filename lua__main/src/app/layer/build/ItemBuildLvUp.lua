-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-04-24 14:39:55 星期一
-- Description: 建筑需求升级item
-----------------------------------------------------


local MCommonView = require("app.common.MCommonView")

local ItemBuildLvUp = class("ItemBuildLvUp", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemBuildLvUp:ctor(  )
	-- body
	self:myInit()
	parseView("item_build_lvup", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemBuildLvUp:myInit(  )
	-- body
	self.tCurData 			= 		nil 			--当前数据
	self.tResData 			= 		nil 			--需要的资源列表
end

--解析布局回调事件
function ItemBuildLvUp:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemBuildLvUp",handler(self, self.onItemBuildLvUpDestroy))
end

--初始化控件
function ItemBuildLvUp:setupViews( )
	-- body
	--线
	self.pLayLine 			= self:findViewByName("lay_line")
	--参数1
	self.pLbParam1 			= self:findViewByName("lb_param1")
	--参数2
	self.pLbParam2 			= self:findViewByName("lb_param2")
	--状态
	self.pImgState 			= self:findViewByName("img_state")
	--功能按钮
	self.pLayAction 		= self:findViewByName("lay_action")
	self.pBtnAction = getCommonButtonOfContainer(self.pLayAction,TypeCommonBtn.M_YELLOW,getConvertedStr(1,10089))
	self.pBtnAction:onCommonBtnClicked(handler(self, self.onBtnActionClicked))

	--0.8缩放
	setMCommonBtnScale(self.pLayAction,self.pBtnAction,0.8)

end

-- 修改控件内容或者是刷新控件数据
function ItemBuildLvUp:updateViews(  )
	-- body
	if self.tCurData then
		if self.tCurData.nType == e_build_uplimit_key.team then --建造队列
			unregUpdateControl(self)
			if self.tCurData.nValue == 0 then 			--有空闲队列
				self.pLbParam1:setString(getConvertedStr(1,10096))
				setTextCCColor(self.pLbParam1, _cc.green)
				self:setOtherMsg(true,"")
			elseif self.tCurData.nValue == 1 then 		--有可购买队列
				self.pLbParam1:setString(getConvertedStr(1,10096))
				setTextCCColor(self.pLbParam1, _cc.red)
				self:setOtherMsg(false,"")
				self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtnAction:updateBtnText(getConvertedStr(1,10098)) --开启
			elseif self.tCurData.nValue == -1 then 		--没空闲队列
				if self.tCurData.pBuild then
					self.pLbParam1:setString(self.tCurData.pBuild.sName .. getConvertedStr(1,10097),false)
					setTextCCColor(self.pLbParam1, _cc.green)
					self:setOtherMsg(false,formatTimeToHms(self.tCurData.pBuild:getBuildingFinalLeftTime()))
					self.pBtnAction:updateBtnType(TypeCommonBtn.M_BLUE)
					self.pBtnAction:updateBtnText(getConvertedStr(1,10099)) --加速
					--动态设置位置
					self.pLbParam2:setPositionX(self.pLbParam1:getPositionX() + self.pLbParam1:getWidth() + 20)
					--刷新进程
					regUpdateControl(self, handler(self, self.onUpdate))
				end
			end
		elseif self.tCurData.nType == e_build_uplimit_key.playerLv then --玩家等级
			self.pLbParam1:setString(getConvertedStr(1,10090))
			if Player:getPlayerInfo().nLv >= self.tCurData.nValue then
				self:setOtherMsg(true,getLvString(self.tCurData.nValue,false))
			else
				self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtnAction:updateBtnText(getConvertedStr(1,10100)) --升级
				self:setOtherMsg(false,getLvString(self.tCurData.nValue,false))
			end
		elseif self.tCurData.nType == e_build_uplimit_key.palaceLv then --王宫等级
			local pPalace = Player:getBuildData():getBuildById(e_build_ids.palace)
			if pPalace then
				self.pLbParam1:setString(pPalace.sName)
				if pPalace.nLv >= self.tCurData.nValue then
					self:setOtherMsg(true,getLvString(self.tCurData.nValue,false))
				else
					self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
					self.pBtnAction:updateBtnText(getConvertedStr(1,10101)) --跳转
					self:setOtherMsg(false,getLvString(self.tCurData.nValue,false))
				end
			end
		elseif self.tCurData.nType == e_build_uplimit_key.tong then --铜
			self.pLbParam1:setString(getConvertedStr(1,10091))
			if Player:getPlayerInfo().nCoin >= self.tCurData.nValue then
				self:setOtherMsg(true,getResourcesStr(self.tCurData.nValue))
			else
				self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtnAction:updateBtnText(getConvertedStr(1,10102)) --获取
				self:setOtherMsg(false,getResourcesStr(self.tCurData.nValue))
			end
		elseif self.tCurData.nType == e_build_uplimit_key.mu then --木
			self.pLbParam1:setString(getConvertedStr(1,10092))
			if Player:getPlayerInfo().nWood >= self.tCurData.nValue then
				self:setOtherMsg(true,getResourcesStr(self.tCurData.nValue))
			else
				self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtnAction:updateBtnText(getConvertedStr(1,10102)) --获取
				self:setOtherMsg(false,getResourcesStr(self.tCurData.nValue))
			end
		elseif self.tCurData.nType == e_build_uplimit_key.liang then --粮
			self.pLbParam1:setString(getConvertedStr(1,10093))
			if Player:getPlayerInfo().nFood >= self.tCurData.nValue then
				self:setOtherMsg(true,getResourcesStr(self.tCurData.nValue))
			else
				self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtnAction:updateBtnText(getConvertedStr(1,10102)) --获取
				self:setOtherMsg(false,getResourcesStr(self.tCurData.nValue))
			end
		elseif self.tCurData.nType == e_build_uplimit_key.tie then --铁
			self.pLbParam1:setString(getConvertedStr(1,10094))
			if Player:getPlayerInfo().nIron >= self.tCurData.nValue then
				self:setOtherMsg(true,getResourcesStr(self.tCurData.nValue))
			else
				self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
				self.pBtnAction:updateBtnText(getConvertedStr(1,10102)) --获取
				self:setOtherMsg(false,getResourcesStr(self.tCurData.nValue))
			end
		elseif self.tCurData.nType == e_build_uplimit_key.unfree then--工坊非空闲
			self.pLbParam1:setString(self.tCurData.nValue)
			setTextCCColor(self.pLbParam1, _cc.red)
			self.pBtnAction:updateBtnType(TypeCommonBtn.M_YELLOW)
			self.pBtnAction:updateBtnText(getConvertedStr(1,10101)) --跳转			
		end
	end
end

-- 析构方法
function ItemBuildLvUp:onItemBuildLvUpDestroy(  )
	-- body
	unregUpdateControl(self)
end

--设置当前数据
-- _tData = {
-- 	nType = nil, -- 类型：e_build_uplimit_key
-- 	nValue = nil -- 值：（int）
-- }
function ItemBuildLvUp:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end

function ItemBuildLvUp:setResList(_tRes)
	self.tResData = _tRes
end

--获得当前数据
function ItemBuildLvUp:getCurData(  )
	-- body
	return self.tCurData
end

--设置需求其他数据
--_bOk：是否满足（是==>绿色，否==>红色）
--_nValue：值（需要格式化）
function ItemBuildLvUp:setOtherMsg( _bOk, _nValue )
	-- body
	--图片状态和参数2颜色
	if _bOk then
		self.pLayAction:setVisible(false)
		setTextCCColor(self.pLbParam2, _cc.green)
		self.pImgState:setCurrentImage("#v1_img_zycz.png")
		self.pImgState:setVisible(true)
	else		
		self.pLayAction:setVisible(true)
		setTextCCColor(self.pLbParam2, _cc.red)
		self.pImgState:setCurrentImage("#v1_img_zybz.png")
		self.pImgState:setVisible(false)
	end
	self.pLbParam2:setString(_nValue or "")
end

--按钮点击事件
function ItemBuildLvUp:onBtnActionClicked( pView )
	-- body
	if self.tCurData then
		if self.tCurData.nType == e_build_uplimit_key.team then --建造队列
			if self.tCurData.nValue == 1 then 		--购买队列
				local tObject = {}
				tObject.nType = e_dlg_index.buildbuyteam --dlg类型
				sendMsg(ghd_show_dlg_by_type,tObject)
			elseif self.tCurData.nValue == -1 then 		--没空闲队列(加速)
				if self.tCurData.pBuild then
					local tObject = {}
					tObject.nFunType = 1
					tObject.nType = e_dlg_index.buildprop --dlg类型
					tObject.nCell = self.tCurData.pBuild.nCellIndex
					sendMsg(ghd_show_dlg_by_type,tObject)
				end
			end
		elseif self.tCurData.nType == e_build_uplimit_key.playerLv then --玩家等级
			local tObject = {}			
			tObject.nType = e_dlg_index.dlgplayerlvup
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nType == e_build_uplimit_key.palaceLv then --王宫等级
			--关闭当前界面，定位到基地上王宫的位置
			local pDlg = getDlgByType(e_dlg_index.buildlvup)
			if pDlg and pDlg.setCloseMsgType then
				--设置关闭后消息类型
				pDlg:setCloseMsgType(2)
			end
			--关闭升级建筑对话框界面
			closeDlgByType(e_dlg_index.buildlvup)
		elseif self.tCurData.nType == e_build_uplimit_key.tong then --铜
			local tObject = {}
			tObject.nType = e_dlg_index.getresource --dlg类型
			tObject.nIndex = 1
			tObject.tValue = self.tResData
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nType == e_build_uplimit_key.mu then --木
			local tObject = {}
			tObject.nType = e_dlg_index.getresource --dlg类型
			tObject.nIndex = 2
			tObject.tValue = self.tResData
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nType == e_build_uplimit_key.liang then --粮
			local tObject = {}
			tObject.nType = e_dlg_index.getresource --dlg类型
			tObject.nIndex = 4
			tObject.tValue = self.tResData
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nType == e_build_uplimit_key.tie then --铁
			local tObject = {}
			tObject.nType = e_dlg_index.getresource --dlg类型
			tObject.nIndex = 3
			tObject.tValue = self.tResData
			sendMsg(ghd_show_dlg_by_type,tObject)
		elseif self.tCurData.nType == e_build_uplimit_key.unfree then--工坊非空闲			
		    local tObject = {}--跳转到工坊
		    tObject.nType = e_dlg_index.atelier --dlg类型
		    sendMsg(ghd_show_dlg_by_type,tObject)	
		end
	end
end

--每秒刷新
function ItemBuildLvUp:onUpdate( )
	-- body
	if self.tCurData.nType == e_build_uplimit_key.team 
		and self.tCurData.nValue == -1
		and self.tCurData.pBuild then
		--剩余时间
		local fLeftTime = self.tCurData.pBuild:getBuildingFinalLeftTime()

		if fLeftTime > 0 then
			self.pLbParam2:setString(formatTimeToHms(fLeftTime))
		else
			self.pLbParam2:setString(formatTimeToHms(0))
			unregUpdateControl(self)
		end
	end
	
end

return ItemBuildLvUp