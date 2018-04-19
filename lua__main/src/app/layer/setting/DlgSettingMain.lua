-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-24 20:28:23 星期三
-- Description: 游戏设置主界面
-----------------------------------------------------

local DlgBase = require("app.common.dialog.DlgBase")

local DlgSettingMain = class("DlgSettingMain", function()
	-- body
	return DlgBase.new(e_dlg_index.dlgsettingmain)
end)

function DlgSettingMain:ctor(  )
	-- body
	self:myInit()
	parseView("dlg_setting_main", handler(self, self.onParseViewCallback))
end

function DlgSettingMain:myInit(  )
	-- body
	self.tbtnGroup = nil
	self.tDefSettingGroup = {
		GameSetting_Type.gamesetting, --游戏设置
	    GameSetting_Type.helpcenter,  --帮助中心
	    GameSetting_Type.contactservice,  --联系客服
	    GameSetting_Type.giftrecharge,  --礼包兑换
	    GameSetting_Type.changeservers,  --切换服务器
	    GameSetting_Type.changeAccount,  --切换账号
	    GameSetting_Type.newnotice,--最新公告
	    GameSetting_Type.guidcopy--gui
	}		
end

--解析布局回调事件
function DlgSettingMain:onParseViewCallback( pView )
	-- body
	--设置标题
	self:setTitle(getConvertedStr(6,10262))
	self:addContentView(pView) --加入内容层
	--self:setupViews()
	self:onResume()
	--注册析构方法
	self:setDestroyHandler("DlgSettingMain",handler(self, self.onDlgSettingMainDestroy))
end

--初始化控件
function DlgSettingMain:setupViews(  )
	-- body	

	-- --服务器
	-- self.pLbService = self:findViewByName("lb_service")
	-- setTextCCColor(self.pLbService, _cc.blue)
	-- --游戏ID
	-- self.pLbGameId = self:findViewByName("lb_gameid")
	-- setTextCCColor(self.pLbGameId, _cc.blue)
	-- --版本
	-- self.pLbVersion = self:findViewByName("lb_version")
	-- setTextCCColor(self.pLbVersion, _cc.blue)

	-- --固定标签	
	-- self.pLbTip1 = self:findViewByName("lb_tip_1")--当前服
	-- setTextCCColor(self.pLbTip1, _cc.pwhite)
	-- self.pLbTip1:setString(getConvertedStr(6, 10263))
	-- self.pLbTip2 = self:findViewByName("lb_tip_2")--游戏id
	-- setTextCCColor(self.pLbTip2, _cc.pwhite)
	-- self.pLbTip2:setString(getConvertedStr(6, 10264))
	-- self.pLbTip3 = self:findViewByName("lb_tip_3")--当前版本
	-- setTextCCColor(self.pLbTip3, _cc.pwhite)
	-- self.pLbTip3:setString(getConvertedStr(6, 10265))


	-- self.tbtnGroup = {}
	-- for i = 1, 7 do
	-- 	local playbtn = self:findViewByName("lay_btn_"..i)
	-- 	local pbtn = getCommonButtonOfContainer(playbtn, TypeCommonBtn.B_DARK, getConvertedStr(6, 10256), false)
	-- 	self.tbtnGroup[i] = pbtn				
	-- end
	-- --游戏设置
	-- self.tbtnGroup[1]:updateBtnText(getConvertedStr(6, 10256))
	-- self.tbtnGroup[1]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.dlggamesetting --dlg类型
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)	
	-- end))
	-- --游戏帮助
	-- self.tbtnGroup[2]:updateBtnText(getConvertedStr(6, 10479))
	-- self.tbtnGroup[2]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.dlghelpcenter --dlg类型
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)
	-- end))		
	-- --联系客服
	-- self.tbtnGroup[3]:updateBtnText(getConvertedStr(6, 10258))
	-- self.tbtnGroup[3]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	self:doContactService()
	-- end))
	-- --礼包兑换
	-- self.tbtnGroup[4]:updateBtnText(getConvertedStr(6, 10259))
	-- self.tbtnGroup[4]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.actmodela --dlg类型
	-- 	tObject.nActID = e_id_activity.giftrecharge
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)		
	-- end))	
	-- --切换服务器
	-- self.tbtnGroup[5]:updateBtnText(getConvertedStr(6, 10257))
	-- self.tbtnGroup[5]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.serverlist --dlg类型
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)	
	-- end))	
	-- --切换账号
	-- self.tbtnGroup[6]:updateBtnText(getConvertedStr(6, 10260))
	-- self.tbtnGroup[6]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	AccountCenter.backToLoginScene(2)
	-- end))	
	-- --最新公告
	-- self.tbtnGroup[7]:updateBtnText(getConvertedStr(6, 10261))
	-- self.tbtnGroup[7]:onCommonBtnClicked(handler(self, function(  )
	-- 	-- body
	-- 	local tObject = {}
	-- 	tObject.nType = e_dlg_index.dlgnotice --dlg类型
	-- 	sendMsg(ghd_show_dlg_by_type,tObject)
	-- end))	
end
--
function DlgSettingMain:refreshinitHandlerGroup(  )
	-- body	
	self.tHandlerGroup = {}
	local tt = self.tDefSettingGroup
	for k, v in pairs(tt) do
		if self:checkHandlerOpen(v) == true then
			if v and v == GameSetting_Type.gamesetting then
				--游戏设置
				local nhandler1 = {text = getConvertedStr(6, 10256), nhandler=handler(self, function (  )
					-- body				
					local tObject = {}
					tObject.nType = e_dlg_index.dlggamesetting --dlg类型
					sendMsg(ghd_show_dlg_by_type,tObject)
				end)}
				table.insert(self.tHandlerGroup, nhandler1)
			elseif v and v == GameSetting_Type.helpcenter then
				--游戏帮助
				local nhandler2 = {text = getConvertedStr(6, 10479), nhandler=handler(self, function ( ... )
					-- body				
					local tObject = {}
					tObject.nType = e_dlg_index.dlghelpcenter --dlg类型
					sendMsg(ghd_show_dlg_by_type,tObject)
				end)}	
				table.insert(self.tHandlerGroup, nhandler2)
			elseif v and v == GameSetting_Type.contactservice then
				--联系客服
				local nhandler3 = {text = getConvertedStr(6, 10258), nhandler=handler(self, function ( ... )
					-- body
					self:doContactService()
				end)}	
				table.insert(self.tHandlerGroup, nhandler3)	
			elseif v and v == GameSetting_Type.giftrecharge then	
				--礼包兑换
				local nhandler4 = {text = getConvertedStr(6, 10259), nhandler=handler(self, function ( ... )
					-- body
					local tObject = {}
					tObject.nType = e_dlg_index.actmodela --dlg类型
					tObject.nActID = e_id_activity.giftrecharge
					sendMsg(ghd_show_dlg_by_type,tObject)	
				end)}
				table.insert(self.tHandlerGroup, nhandler4)		
			elseif v and v == GameSetting_Type.changeservers then	
				--切换服务器
				local nhandler5 = {text = getConvertedStr(6, 10257), nhandler=handler(self, function ( ... )
					-- body
					local tObject = {}
					tObject.nType = e_dlg_index.serverlist --dlg类型
					sendMsg(ghd_show_dlg_by_type,tObject)
				end)}	
				table.insert(self.tHandlerGroup, nhandler5)	
			elseif v and v == GameSetting_Type.changeAccount then									
				--切换账号
				local nhandler6 = {text = getConvertedStr(6, 10260), nhandler=handler(self, function ( ... )
					-- body
					AccountCenter.backToLoginScene(2)
				end)}		
				table.insert(self.tHandlerGroup, nhandler6)
			elseif v and v == GameSetting_Type.newnotice then	
				--最新公告
				local nhandler7 = {text = getConvertedStr(6, 10261), nhandler=handler(self, function ( ... )
					-- body
					local tObject = {}
					tObject.nType = e_dlg_index.dlgnoticemain --dlg类型
					sendMsg(ghd_show_dlg_by_type,tObject)
				end)}
				table.insert(self.tHandlerGroup, nhandler7)	
			elseif v and v == GameSetting_Type.guidcopy then
				--联系客服
				local nhandler8 = {text = getConvertedStr(1, 10306), nhandler=handler(self, function ( ... )
					-- body
					self:copyGUID()
				end)}
				table.insert(self.tHandlerGroup, nhandler8)	
			end
		end
	end
end
--检查是否开启
function DlgSettingMain:checkHandlerOpen( nSettingType )
	-- body
	if not nSettingType then
		return false
	end
	-- vivo关闭切换帐号功能
	if(nSettingType == GameSetting_Type.changeAccount and isVivo()) then
		return false
	end
	if(GameSetting_Type.giftrecharge == nSettingType) then
		local pActData = Player:getActById(e_id_activity.giftrecharge) -- 礼包兑换的活动
		if(pActData) then
			return true
		else
			return false
		end
	end

	--复制guid
	if nSettingType == GameSetting_Type.guidcopy then
		if AccountCenter.guid then
			return true
		else
			return false
		end
	end

	if nSettingType == GameSetting_Type.contactservice and (b_open_ios_shenpi or isHideContactService())  then
		return false
	else
		return true
	end	

	if nSettingType ~= GameSetting_Type.close then
		return true
	else
		return false
	end
end


-- 联系客服
function DlgSettingMain:doContactService(  )
	if(device.platform == "windows") then
		local tObject = {}
		tObject.nType = e_dlg_index.dlgcontactservice --dlg类型
		sendMsg(ghd_show_dlg_by_type,tObject)
	else
		local url = "/action/user/cusSerUrl"
		local param = {uid=AccountCenter.acc,aid=Player:getPlayerInfo().pid}
		HttpManager:doGetFunctionToHttpServer(url, param, function ( _event )
	        if _event.name == "completed" and _event.data then
	            local sAddress = _event.data.r
	            if(sAddress) then
	            	if(device.platform == "android") then
	            		local className = "com/game/quickmgr/QuickMgr"
				        local methodName = "doOpenSmrz"
				        local result, ret = luaj.callStaticMethod(className, methodName, 
				        	{2, sAddress}, "(ILjava/lang/String;)V")
	            	elseif(device.platform == "ios") then
	            		local param = {}
				        param.url = sAddress
				        param.type = 2 -- 联系客服
				        local luaoc = require("framework.luaoc")
				        local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", 
				            "doOpenSmrz", param)
	            	end
	            else
	            	TOAST(getConvertedStr(2, 10001))
	            end
	        elseif _event.name == "failed" then
	            TOAST(getConvertedStr(2, 10001))
	        end
	    end)
	end
end

function DlgSettingMain:copyGUID(  )
	if(device.platform == "windows") then
		TOAST(getConvertedStr(1, 10305))
		return
	else
	    if(device.platform == "android") then
	        local className = "com/game/quickmgr/QuickMgr"
			local methodName = "copyClipboard"
			local result, ret = luaj.callStaticMethod(className, methodName, 
				        	{tostring(AccountCenter.guid)}, "(Ljava/lang/String;)V")
			if result then
				TOAST(string.format(getConvertedStr(1,10307), AccountCenter.guid))
			end
	    elseif(device.platform == "ios") then
	    	local luaoc = require("framework.luaoc")
            local bOk, sValue = luaoc.callStaticMethod("PlatformSDK", "copyClipboard", {guid=AccountCenter.guid})
	    	if bOk then
	    		TOAST(string.format(getConvertedStr(1,10307), AccountCenter.guid))
	    	end
	    end
 
	end
end

--控件刷新
function DlgSettingMain:updateViews(  )
	-- body	
	gRefreshViewsAsync(self, 3, function ( _bEnd, _index )
		if (_index == 1) then
			--初始化文字标签
			if not self.pLbService then
				--服务器
				self.pLbService = self:findViewByName("lb_service")
				setTextCCColor(self.pLbService, _cc.blue)
				--游戏ID
				self.pLbGameId = self:findViewByName("lb_gameid")
				setTextCCColor(self.pLbGameId, _cc.blue)
				--版本
				self.pLbVersion = self:findViewByName("lb_version")
				setTextCCColor(self.pLbVersion, _cc.blue)
				--3kGuid
				self.pLbGuid = self:findViewByName("lb_guid")
				setTextCCColor(self.pLbGuid, _cc.blue)
				--固定标签	
				self.pLbTip1 = self:findViewByName("lb_tip_1")--当前服
				setTextCCColor(self.pLbTip1, _cc.pwhite)
				self.pLbTip1:setString(getConvertedStr(6, 10263))
				self.pLbTip2 = self:findViewByName("lb_tip_2")--游戏id
				setTextCCColor(self.pLbTip2, _cc.pwhite)
				self.pLbTip2:setString(getConvertedStr(6, 10264))
				self.pLbTip3 = self:findViewByName("lb_tip_3")--当前版本
				setTextCCColor(self.pLbTip3, _cc.pwhite)
				self.pLbTip3:setString(getConvertedStr(6, 10265))
				self.pLbTip4 = self:findViewByName("lb_tip_4")--当前版本
				-- if AccountCenter.guid then
				-- 	setTextCCColor(self.pLbTip4, _cc.pwhite)
				-- 	self.pLbTip4:setString("guid：")
				-- end	
			end
			--按钮组
			if not self.tbtnGroup then
				self.tbtnGroup = {}
				for i = 1, 8 do
					if not self.tbtnGroup[i] then
						local playbtn = self:findViewByName("lay_btn_"..i)
						local pbtn = getCommonButtonOfContainer(playbtn, TypeCommonBtn.B_DARK, getConvertedStr(6, 10256), false)
						pbtn:setVisible(false)
						self.tbtnGroup[i] = pbtn
					end			
				end
			end			
		elseif (_index == 2) then
			--当前服
			local sServerName = AccountCenter.nowServer.ne
			self.pLbService:setString(sServerName)
			--游戏ID
			local pId = Player:getPlayerInfo().pid
			self.pLbGameId:setString(pId)
			--版本
			local sVer = getPackageResVer()
			if sVer then
			    self.pLbVersion:setString(AccountCenter.sPackageVerName .. "@" .. sVer)
			end
			--guid
			-- if AccountCenter.guid then
			-- 	self.pLbGuid:setString(AccountCenter.guid)
			-- end
		elseif (_index == 3) then
			--按钮刷新
			self:refreshinitHandlerGroup()
			--按钮展示
			for k, v in pairs(self.tbtnGroup) do
				local thandler = self.tHandlerGroup[k]		
				if thandler then
					v:updateBtnText(thandler.text)
					v:onCommonBtnClicked(thandler.nhandler)
					v:setVisible(true)
				else
					v:setVisible(false)
				end
			end	
		end

	end)
end

--析构方法
function DlgSettingMain:onDlgSettingMainDestroy()
	-- body
	self:onPause()
end

--注册消息
function DlgSettingMain:regMsgs(  )
	-- body
end
--注销消息
function DlgSettingMain:unregMsgs( )
	-- body
end

--暂停方法
function DlgSettingMain:onPause( )
	-- body			
	self:unregMsgs()	
end

--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgSettingMain:onResume( _bReshow )
	-- body			
	self:updateViews()
	self:regMsgs()
end

return DlgSettingMain