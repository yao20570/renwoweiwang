-- GirlGuideMgr.lua
----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2018-02-05 14:59:10
-- Description: 教你玩(美女引导)管理器
-----------------------------------------------------


local nGuideType = 1
local nHouse1 = 1001 	--客栈1

--教你玩管理类
local GirlGuideMgr = class("GirlGuideMgr")
function GirlGuideMgr:ctor( GirlGuideMgr )
	self:release()
end

function GirlGuideMgr:release()
	self.nCurrStepId = nil   --当前进行的步骤id
	self.pFingerUis = {}	 --手指ui
	self.pHomeLayer = nil    --城市界面
	self.tRewardKey = nil
	self.bIsStopLocalUi = false
end

--设置主页界面
function GirlGuideMgr:setHomeLayer( pHomeLayer )
	self.pHomeLayer = pHomeLayer
end

--设置ui为指引的手指指向ui
--pUi新手指
--nFingerId手指id
function GirlGuideMgr:setGirlGuideFinger(pUi, nFingerId)
	-- local pPrevUi = self.pFingerUis[nFingerId]
	local nCurrUi = pUi
	-- if nCurrUi == pPrevUi then
	-- 	return
	-- end
	--如果值和UI都相同就不触发
	self.pFingerUis[nFingerId] = nCurrUi
	if pUi then
		pUi.__guide_finger_msg = nFingerId
		
		if not self.nCurrStepId then
			return
		end
		local tGuideData = getTeachPlayStep(self.nCurrStepId)
		if not tGuideData then
			return
		end
		if nFingerId == tGuideData.fingerid then
			self:showGuideLayer()
		end
	end
end

--设置手指点击完成
--用法Player:getNewGuideMgr():onClickedNewGuideFinger( nFingerId )
function GirlGuideMgr:onClickedGirlGuideFinger( pUi )
	if not pUi then
		return
	end
	local nFingerId = pUi.__guide_finger_msg
	if not nFingerId then
		return
	end
	
	self:setGirlGuideFingerClicked(nFingerId)
end

--设置手指点击完成
--用法Player:getGirlGuideMgr():setGirlGuideFingerClicked( nFingerId )
function GirlGuideMgr:setGirlGuideFingerClicked( nFingerId )
	if not nFingerId then
		return
	end
	if not self.nCurrStepId then
		return
	end
	--指引手指点击
	local tGuideData = getTeachPlayStep(self.nCurrStepId)
	if not tGuideData then
		return
	end

	--触发完成点击跳转界面
	self:showGirlGuide(tGuideData.nextstep)

end

--跳转到某个界面
function GirlGuideMgr:jumpToDlg(nStepId)
	local tGuideData = getTeachPlayStep(nStepId)
	if tGuideData and tGuideData.interface then
		local sInterfaceId = luaSplit(tGuideData.interface, ":")
		local nInterfaceId = tonumber(sInterfaceId[1])
		if nInterfaceId == e_dlg_index.taskworld then
			closeAllDlg()--进入世界或者基地界面时候清理界面上的对话框
			sendMsg(ghd_home_show_base_or_world, nInterfaceId - 100)--世界跳转
			return true
		else
			local tObject = {}
			tObject.nType = nInterfaceId --dlg类型
			--如果跳到洗炼铺, 跳到洗炼功能界面
			if nInterfaceId == e_dlg_index.smithshop then
				tObject.nFuncIdx = tonumber(sInterfaceId[2])--n_smith_func_type.train
			end
			sendMsg(ghd_show_dlg_by_type,tObject)
			return true
		end
	end
	return false
end

--nStepId:步骤id
function GirlGuideMgr:showGirlGuide(nStepId)
	--记录当前引导id
	self:setCurrStepId(nStepId)

	local tGuideData = getTeachPlayStep(nStepId) 
	if not tGuideData then
		return
	end

	--如果有语音播放语音
	if tGuideData.audio and getIsCanPlayAudio() then
		local pAudio = tGuideData.audio
		--如果上次的语音还在播则停止
		if self.pAudio then
			Sounds.stopEffect(self.pAudio)
		end
		if Sounds.Effect.tGuideAudio[pAudio] then
			self.pAudio = Sounds.Effect.tGuideAudio[pAudio]
		elseif Sounds.Effect[pAudio] then
			self.pAudio = Sounds.Effect[pAudio]
		elseif Sounds.Effect.tFight[pAudio] then
			self.pAudio = Sounds.Effect.tFight[pAudio]
		end
		
		Sounds.playEffect(self.pAudio)
	end
	if tGuideData.interface then
		self:jumpToDlg(tGuideData.step)
	end

	self:showGuideLayer()
	--定位显示新手面板
	if getIsSequeneceFree() then 
		self:localBuildUi(true)
	end
end

--显示指引层
function GirlGuideMgr:showGuideLayer( nTestStepId )
	if nTestStepId then
		self:setCurrStepId( nTestStepId )
	end
	if not self.nCurrStepId then
		return
	end

	local tGuideData = getTeachPlayStep(self.nCurrStepId)
	if not tGuideData then
		return
	end

	--需要手指
	local pFingerUi = nil
	if (tGuideData.fingerid ~= nil and tGuideData.fingerid ~= 0) then
		pFingerUi = self.pFingerUis[tGuideData.fingerid]
		local bIsNoTarget = false
		if pFingerUi == nil then
			bIsNoTarget = true
		end
		if tolua.isnull(pFingerUi) then
			self.pFingerUis[tGuideData.fingerid] = nil --消灭c++对像已经销毁的lua地址
			bIsNoTarget = true
		end
	end
	self.pFingerUi = pFingerUi

	if self.pHomeLayer == nil then return end
	local pGuideLayer = getRealShowLayer(self.pHomeLayer, e_layer_order_type.guidelayer)
    if pGuideLayer then
    	if not tolua.isnull(self.pSpeakTip) then
    		self.pSpeakTip:removeSelf()
    		self.pSpeakTip = nil
    	end
    	--手指
    	if tGuideData.fingerid ~= nil and tGuideData.fingerid ~= 0 then
		    if not self.pNewGuideFinger then
		    	local NewGuideFinger = require("app.layer.newguide.NewGuideFinger")
				self.pNewGuideFinger = NewGuideFinger.new()
				pGuideLayer:addView(self.pNewGuideFinger)
				centerInView(pGuideLayer, self.pNewGuideFinger)
		    end
			sendMsg(ghd_guide_finger_show_or_hide, true)
		    self.pNewGuideFinger:setData(tGuideData.step, pFingerUi, nGuideType)
	    else
	    	if self.pNewGuideFinger then
	    		self.pNewGuideFinger:setVisible(false)
	    		self.pNewGuideFinger:setData(nil)
	    	end
	    end
    	

    	--单屏
    	if tGuideData.chatbox == 2 or tGuideData.chatbox == 3 then
    		if getIsSequeneceFree() then
				if not self.pNewGuideTip then
					local NewGuideTip = require("app.layer.newguide.NewGuideTip")
					self.pNewGuideTip = NewGuideTip.new()
					pGuideLayer:addView(self.pNewGuideTip)
					centerInView(pGuideLayer, self.pNewGuideTip)
				else
					self.pNewGuideTip:setVisible(true)
				end
				self.pNewGuideTip:setData(self.nCurrStepId, nGuideType)
				local nUpState = 0
				if self.pNewGuideFinger then
					nUpState = self.pNewGuideFinger:getInUpHalfState()
				end
				self.pNewGuideTip:setPosByFingerUi(nUpState)
				--加入显示控制权
    			showSequenceFunc(e_show_seq.newguidehalf)
    		else
    			if self.pNewGuideTip and self.pNewGuideTip:isVisible() then
    				self.pNewGuideTip:setData(self.nCurrStepId, nGuideType)
    			end
			end
		else
			if self.pNewGuideTip then
				self.pNewGuideTip:setVisible(false)
				--显示下一个
				showNextSequenceFunc(e_show_seq.newguidehalf)
			end
		end
	end
end

function GirlGuideMgr:openGuideTip(_pGuideLayer, _sTip)
    -- body
    local DlgFlow = require("app.common.dialog.DlgFlow")
    local pDlg,bNew = getDlgByType(e_dlg_index.taskguidetip)
    if(not pDlg) then
        pDlg = DlgFlow.new(e_dlg_index.taskguidetip)
    end
    local TaskGuideTip = require("app.common.taskguidetip.TaskGuideTip")
    local pChildView = TaskGuideTip.new(_sTip)
    pDlg:showChildView(_pGuideLayer, pChildView)
    UIAction.enterDialog( pDlg, RootLayerHelper:getCurRootLayer(), bNew)
    pDlg:setDialogBgColor(GLOBAL_DIALOG_BG_COLOR_TRANSPARENT)
    return pDlg
end

--设置当前
function GirlGuideMgr:setCurrStepId( nCurrStepId )
	self.nCurrStepId = nCurrStepId
end

--建筑移动定位
function GirlGuideMgr:localBuildUi( bIsMove )
	if not self.nCurrStepId then
		return
	end

	local tGuideData = getTeachPlayStep(self.nCurrStepId)
	
	if tGuideData then
		local nCell = nil
		local bIsOpenSecond = false
		local nFingerId = tGuideData.fingerid
		if not nFingerId or nFingerId == 0 then
			return
		end
		--客栈1
		if nFingerId == e_guide_finer.house1_build then
			nCell = nHouse1
		--王宫建筑
		elseif nFingerId == e_guide_finer.palace_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.palace)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--科技院建筑
		elseif nFingerId == e_guide_finer.tnoly_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.tnoly)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--仓库建筑
		elseif nFingerId == e_guide_finer.store_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.store)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--步兵营建筑
		elseif nFingerId == e_guide_finer.infantry_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.infantry)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--竞技场建筑
		elseif nFingerId == e_guide_finer.arena_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.arena)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		--城门建筑
		elseif nFingerId == e_guide_finer.gate_build then
			local tBuild = Player:getBuildData():getBuildByCell(e_build_cell.gate)
			if tBuild then
				nCell = tBuild.nCellIndex
			end
		end
		if nCell then
			if bIsMove then
				-- if self.bIsStopLocalUi then
				-- 	return
				-- end

				local tObject = {}
				tObject.nCell = nCell
				tObject.nFunc = function (  )
					--手指+对话
			    	if tGuideData.chatbox == 1 then
			    		self.pSpeakTip = self:openGuideTip(self.pFingerUi, tGuideData.desc)
					end
				end
				
				sendMsg(ghd_move_to_build_dlg_msg, tObject)
				
				if bIsOpenSecond then
					--如果需要找手指（还没有找到手指)
					local bIsNeedFound = false
					if tolua.isnull(self.pFingerUis[nFingerId]) then
						bIsNeedFound = true
					end
					--如果有二级菜单就打开二级菜单
					if bIsNeedFound and self:isHasSecondMenu(nFingerId) then
						local tObject = {}
						tObject.nCell = nCell
						sendMsg(ghd_show_build_actionbtn_msg,tObject)
					end
				end
			end
			
		end
	end
end

--判断建筑是否有二级菜单
function GirlGuideMgr:isHasSecondMenu(_nFingerId)
	if _nFingerId == e_guide_finer.smithshop_build then
		return false
	end
	return true
end

--pUi：建筑本身layer
--tBuildData:建筑数据
function GirlGuideMgr:registeredBuildSelfEnter(pUi, tBuildData)
	local sMsg = nil
	if not tBuildData then
		return
	end
	--王宫
	if tBuildData.sTid == e_build_ids.palace then
		sMsg = e_guide_finer.palace_build
	--科技院
	elseif tBuildData.sTid == e_build_ids.tnoly then
		sMsg = e_guide_finer.tnoly_build
	--步兵营
	elseif tBuildData.sTid == e_build_ids.infantry then
		sMsg = e_guide_finer.infantry_build
	--仓库
	elseif tBuildData.sTid == e_build_ids.store then
		sMsg = e_guide_finer.store_build
	--城门
	elseif tBuildData.sTid == e_build_ids.gate then
		sMsg = e_guide_finer.gate_build
	--竞技场
	elseif tBuildData.sTid == e_build_ids.arena then
		sMsg = e_guide_finer.arena_build
	--客栈1
	elseif tBuildData.nCellIndex == nHouse1 then
		sMsg = e_guide_finer.house1_build
	end
	

	if sMsg then
		self:setGirlGuideFinger(pUi, sMsg)
	end
end


return GirlGuideMgr