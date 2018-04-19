--------------------------------------------
-- Author: dengshulan
-- Date: 2018-01-17 14:13:37 星期三
-- 查看已装备信息
--------------------------------------------

local DlgCommon = require("app.common.dialog.DlgCommon")
local EquipInfoLayer = require("app.module.EquipInfoLayer")

local DlgEquipInfo = class("DlgEquipInfo", function ()
	return DlgCommon.new(e_dlg_index.dlgequipinfo, nil, 200)
end)

--构造
--_nDefaultIndex：默认选择哪一项
function DlgEquipInfo:ctor(sUuid, nKind, nHeroId)	
	-- body
	self:myInit(sUuid, nKind, nHeroId, tHeroData)	
	parseView("dlg_equip_info", handler(self, self.onParseViewCallback))
end

en_operate_type = {
	takeoff 	= 1, --卸下
	change 		= 2, --更换
	share 		= 3, --分享
	strengthen  = 4, --强化
	refine 		= 5, --洗炼	
}

--初始化成员变量
function DlgEquipInfo:myInit(sUuid, nKind, nHeroId, tHeroData)
	-- body	
	self.sUuid = sUuid
	self.nKind = nKind
	self.nHeroId = nHeroId

	self.tCurData = nil
	self.tBtnGroup = {}
	self.tLayRedtipGroup = {}

	self.bIsStrengthen = false
	self.bIsRefine = false

	self.tOperations = {}
end
  
--解析布局回调事件
function DlgEquipInfo:onParseViewCallback( pView )
	-- body
	self:addContentView(pView, false, 200)
	self:setupViews()
	self:onResume()
	 --注册析构方法
    self:setDestroyHandler("DlgEquipInfo",handler(self, self.onDlgEquipInfoDestroy))
end

--初始化控件
function DlgEquipInfo:setupViews()
	-- body
	--设置标题 装备信息
	self:setTitle(getConvertedStr(7, 10312))
	self.pLayEquip = self:findViewByName("lay_equip_info")
end

-- 修改控件内容或者是刷新控件数据
function DlgEquipInfo:updateViews()
	-- body
	if not self.sUuid then
		return
	end
	--装备
	local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
	if tEquipVo then
		if not self.pEquipInfoLayer then
			self.pEquipInfoLayer = EquipInfoLayer.new()
			self.pLayEquip:addView(self.pEquipInfoLayer, 10)
		end
		self.pEquipInfoLayer:setCurData(tEquipVo)
	end
	self.tEquipVo = tEquipVo
	--按钮
	self:updateBtnOperations()
end


--接收服务端发回的登录回调
function DlgEquipInfo:onGetDataFunc( __msg )
    if  __msg.head.state == SocketErrorType.success then 
        if __msg.head.type == MsgType.reqEquipTakeOff.id then--卸下装备       		
			self:closeCommonDlg()
        end
    else
        --弹出错误提示语
        TOAST(SocketManager:getErrorStr(__msg.head.state))
    end

end

--底部5个按钮
function DlgEquipInfo:updateBtnOperations(  )
	-- body
	self.tOperations = {}
	for v = 1, 5 do
		local tOperate = nil
		if v == en_operate_type.takeoff then --卸下
			tOperate = {}
			tOperate.bEnable = true
			tOperate.nBtnType = TypeCommonBtn.M_RED
			tOperate.sTitle = getConvertedStr(7, 10313)
			tOperate.nHandler = handler(self, function ( ... )
				-- body
				local bIsWillFull = Player:getEquipData():isEquipWillFull(1)
				if bIsWillFull then
					sendMsg(ghd_equipBag_fulled_msg)
					return
				end
				SocketManager:sendMsg("reqEquipTakeOff", {self.sUuid, self.nHeroId}, handler(self, self.onGetDataFunc))
			end)
		elseif v == en_operate_type.change then --更换装备
			tOperate = {}
			tOperate.bEnable = true
			tOperate.nBtnType = TypeCommonBtn.M_BLUE
			tOperate.sTitle = getConvertedStr(7, 10314)
			tOperate.nHandler = handler(self, function ( ... )
				local tObject = {
				    nType = e_dlg_index.equipbag, --dlg类型, 装备背包
				    nKind = self.nKind,
				    sUuid = self.sUuid,
				    nHeroId = self.nHeroId,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
				self:closeCommonDlg()
			end)
		elseif v == en_operate_type.share then --分享
			tOperate = {}
			tOperate.bEnable = true
			tOperate.nBtnType = TypeCommonBtn.M_BLUE
			tOperate.sTitle = getConvertedStr(7, 10069)
			
			tOperate.nHandler = handler(self, function ( ... )
				-- body
				local tEquipVo = Player:getEquipData():getEquipVoByUuid(self.sUuid)
				local tEquipData = tEquipVo:getConfigData()
				if tEquipVo then
					openShare(self.tBtnGroup[3], e_share_id.equip, {"c^g_"..tEquipData.sTid,tEquipVo:getSolidStarNum()},
	 				self.sUuid)
				end
			end)
		elseif v == en_operate_type.strengthen then --强化
			tOperate = {}
			if getIsReachOpenCon(20, false) then
				tOperate.bEnable = true
			else
				tOperate.bEnable = false
			end
			tOperate.nBtnType = TypeCommonBtn.M_YELLOW
			tOperate.sTitle = getConvertedStr(7, 10315)
			tOperate.nHandler = handler(self, function ( ... )
				-- body
				--去洗炼铺强化界面
				local tObject = {
				    nType = e_dlg_index.smithshop,
				    nFuncIdx = n_smith_func_type.strengthen,
				    sUuid = self.sUuid,
				    nHeroId = self.nHeroId,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)
				self:closeCommonDlg()
			end)
		elseif v == en_operate_type.refine then --洗炼
			tOperate = {}
			if getIsReachOpenCon(21, false) then
				tOperate.bEnable = true
			else
				tOperate.bEnable = false
			end
			tOperate.nBtnType = TypeCommonBtn.M_YELLOW
			tOperate.sTitle = getConvertedStr(7, 10316)
			tOperate.nHandler = handler(self, function ( ... )
				--去洗炼铺洗炼界面
				local tObject = {
				    nType = e_dlg_index.smithshop,
				    nFuncIdx = n_smith_func_type.train,
				    sUuid = self.sUuid,
				    nHeroId = self.nHeroId,
				}
				sendMsg(ghd_show_dlg_by_type, tObject)  
				self:closeCommonDlg()
			end)
		end		
		if tOperate then
			table.insert(self.tOperations, tOperate)
		end		 
	end

	for i = 1, 5 do
		local tOperate = self.tOperations[i]
		local playRedtip = self:findViewByName("lay_redtip_"..i)
		self.tLayRedtipGroup[i] = playRedtip
		local playbtn = self:findViewByName("lay_btn_"..i)
		if not self.tBtnGroup[i] and tOperate then				
			local pBtn = getCommonButtonOfContainer(playbtn, tOperate.nBtnType, tOperate.sTitle, false)			
			self.tBtnGroup[i] = pBtn		
		end
		if self.tBtnGroup[i] then
			if tOperate then
				self.tBtnGroup[i]:setVisible(true)
				self.tBtnGroup[i]:setBtnEnable(tOperate.bEnable)
				self.tBtnGroup[i]:setButton(tOperate.nBtnType, tOperate.sTitle)
				self.tBtnGroup[i]:onCommonBtnClicked(tOperate.nHandler) 
			else
				self.tBtnGroup[i]:setVisible(false)
			end
		end
	end
	--更换按钮红点
	if self.tBtnGroup[en_operate_type.change] then
		--获取更好的装备
		local tBettleEquipVos = Player:getEquipData():getHeroBetterEquipVos(self.nHeroId)
		local nRedNum = 0
		for i = 1, #tBettleEquipVos do
			local tEquipData = tBettleEquipVos[i]:getConfigData()
			if tEquipData then
				if tEquipData.nKind == self.nKind then
					nRedNum = nRedNum + 1
					break
				end
			end
		end
		showRedTips(self.tLayRedtipGroup[en_operate_type.change], 0, nRedNum)
	end
	--强化按钮红点
	if self.tBtnGroup[en_operate_type.strengthen] then
		--设置无效状态下点击回调事件
		self.tBtnGroup[en_operate_type.strengthen]:onCommonBtnDisabledClicked(function()
			getIsReachOpenCon(20)
		end)
		local nRedNum = 0
		if getIsReachOpenCon(20, false) and self.tEquipVo then
			if Player:getEquipData():isCanStrengthen(self.tEquipVo) then
				nRedNum = nRedNum + 1
			end
		end
		showRedTips(self.tLayRedtipGroup[en_operate_type.strengthen], 0, nRedNum)
	end
	--洗炼按钮红点
	if self.tBtnGroup[en_operate_type.refine] then
		--设置无效状态下点击回调事件
		self.tBtnGroup[en_operate_type.refine]:onCommonBtnDisabledClicked(function()
			getIsReachOpenCon(21)
		end)
		local nRedNum = 0
		if getIsReachOpenCon(21, false) and self.tEquipVo then
			if Player:getEquipData():isCanRefine(self.tEquipVo) then
				nRedNum = nRedNum + 1
			end
		end
		showRedTips(self.tLayRedtipGroup[en_operate_type.refine], 0, nRedNum)
	end
end


--析构方法
function DlgEquipInfo:onDlgEquipInfoDestroy()
	self:onPause()
end

-- 注册消息
function DlgEquipInfo:regMsgs( )
	-- body
end

-- 注销消息
function DlgEquipInfo:unregMsgs(  )
	-- body
end


--暂停方法
function DlgEquipInfo:onPause( )
	-- body
	self:unregMsgs()
end

--继续方法
function DlgEquipInfo:onResume( )
	-- body
	self:updateViews()
	self:regMsgs()
end


return DlgEquipInfo
