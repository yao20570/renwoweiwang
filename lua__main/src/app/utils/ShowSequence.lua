--------------------------------
--主要用于数据推送时要弹出的主要流程
e_show_seq = {
	kindreward = 1,--主公升级奖励,
	buildopen  = 2,--建筑开启特效
	taskrward  = 3,--任务奖励
	rebuildreward = 4, --重建奖励
	unlockmodel  = 5, --解锁功能
	-- newguide   = 7,
	fight   = 8, --战斗
	gethero    = 9, --武将获得
	rescollect = 10, --资源征收
	triggergift = 11, --触发礼包
	chatperStart = 12,--章节开启
	chatperEnd 	 = 13,--章节开启
	

	newguidedrama = 50,--新手流程-全屏框
	newguidehalf   = 51,--新手流程-半屏框
}

local function getIsHideFinger( nKey )
	if nKey == e_show_seq.kindreward or nKey == e_show_seq.buildopen or nKey == e_show_seq.unlockmodel or nKey == e_show_seq.rebuildreward or nKey == e_show_seq.fight then
		return true
	end
	return false
end

--在全部列表执行完后执行的一次方法
local nOnceFunc = nil

--当前显示列表的先级顺序
local nCurrShowSeq = nil
--优先级显示列表
local tShowSeqDatas = {}
--是否开启顺序开启
local bIsOpenShowSeq = false
--显示顺序方法
--nKey：e_show_seq的方法
--nHandler：回调方法
--nParam: 参数
function showSequenceFunc( nKey, nHandler, nParam)
	--容错
	if not nKey then
		return
	end
	-- print("showSequenceFunc ========",nKey, nCurrShowSeq)

	if nKey == e_show_seq.fight then
		clearShowSequenceData()
	end



	if bIsOpenShowSeq then
		--如果当前正在进行中或者还没有开始
		if nCurrShowSeq and nCurrShowSeq ~= nKey then
			if B_GUIDE_LOG then
				print("B_GUIDE_LOG showSequenceFunc nKey, nHandler 保存",nKey, nHandler, tostring(nHandler))
			end
			--保存起来
			table.insert(tShowSeqDatas, {nKey = nKey, nHandler = nHandler, nParam = nParam})
		else
			nCurrShowSeq = nKey
			--强制隐藏手指
			if getIsHideFinger(nKey) then
				--隐藏手指
				sendMsg(ghd_guide_finger_show_or_hide, false)
				--不允许定位
				Player:getNewGuideMgr():setIsStopLocalUi(true)
			end
			if nHandler then
				if B_GUIDE_LOG then
					print("B_GUIDE_LOG showSequenceFunc nKey, nHandler  ", nKey, nHandler, tostring(nHandler))
				end

				--部分操作要根据新手延时，且不可以操作
				local nDelayTime = 0
				local nStepId = Player:getNewGuideMgr():getCurrStepId()
				if nStepId then
					local tGuideData = getGuideData(nStepId)
					if tGuideData then
						if tGuideData.windelayed then
							local tData = luaSplit(tGuideData.windelayed, ":")
							local nType = tonumber(tData[1])
							local _nDelayTime = tonumber(tData[2])
							if _nDelayTime then
								if nType == 1 and nKey == e_show_seq.taskrward then --1任务领奖
									nDelayTime = _nDelayTime
								elseif nType == 3 and nKey == e_show_seq.buildopen then -- 3.获得新建筑
									nDelayTime = _nDelayTime
								end
								-- 2.对话弹窗那个放在NewGuideTip和Daram里面
							end
						end
					end
				end
				local pLayRoot = Player:getUIHomeLayer()
				if pLayRoot and nDelayTime > 0 then
					local function nFunc()
						hideUnableTouchDlg()
						if nHandler then
							nHandler()
						end
					end
					showUnableTouchDlg()
					doDelayForSomething(pLayRoot, nFunc, nDelayTime/1000)
				else
					nHandler()
				end
			end
		end
	else
		--保存起来
		table.insert(tShowSeqDatas, {nKey = nKey, nHandler = nHandler, nParam = nParam})
	end
end

--返回顺序列表
function getShowSeqDatas( )
	return tShowSeqDatas
end

--显示顺序下一个
function showNextSequenceFunc( _nKey )
	-- print("showNextSequenceFunc -- nCurrShowSeq, _nKey == ", nCurrShowSeq, _nKey)
	if B_GUIDE_LOG then
		print("B_GUIDE_LOG showNextSequenceFunc _nKey = ",_nKey)
	end

	--不能重复存在列表中的字段
	if _nKey == e_show_seq.fight or _nKey == e_show_seq.gethero or _nKey == e_show_seq.taskrward then
		--采用倒序删除
		local nSize = #tShowSeqDatas
		for i=nSize, 1, -1 do
			if tShowSeqDatas[i].nKey == _nKey then
				table.remove(tShowSeqDatas, i)
				if B_GUIDE_LOG then
					print("B_GUIDE_LOG showNextSequenceFunc remove = ",_nKey)
				end
			end
		end
	end

	--如果当前不相等
	if nCurrShowSeq ~= _nKey then
		return
	end

	--清空数据
	if nCurrShowSeq then
		for i=1,#tShowSeqDatas do
			if tShowSeqDatas[i].nKey == nCurrShowSeq then
				table.remove(tShowSeqDatas, i)
				if B_GUIDE_LOG then
					print("B_GUIDE_LOG showNextSequenceFunc remove = ",nCurrShowSeq)
				end
				break
			end
		end
	end
	nCurrShowSeq = nil
	--排序
	local nKey = nil
	local nIndex = nil
	for i=1,#tShowSeqDatas do
		local k = tShowSeqDatas[i].nKey
		if nKey == nil then
			nKey = k
			nIndex = i
		else
			if k < nKey then
				nKey = k
				nIndex = i
			end
		end		
	end

	if nIndex then
		local nKey = tShowSeqDatas[nIndex].nKey
		local nHandler = tShowSeqDatas[nIndex].nHandler
		showSequenceFunc(nKey, nHandler)
		return
	end

	--显示手指
	Player:getNewGuideMgr():showNewGuideAgain()

	--执行一次性方法
	if nOnceFunc then
		nOnceFunc()
		nOnceFunc = nil
	end
end

--顺序面板开始
function showFirstSequenceFunc(  )
	--将新手引导相关的全部关掉
	local tNewData = {}
	for i=1,#tShowSeqDatas do
		local nKey = tShowSeqDatas[i].nKey
		if nKey ~= e_show_seq.newguidehalf or nKey ~= e_show_seq.newguidedrama then
			table.insert(tNewData, tShowSeqDatas[i])
		end
	end
	tShowSeqDatas = tNewData
	bIsOpenShowSeq = true
	if tShowSeqDatas and #tShowSeqDatas > 0 then
		showSequenceFunc(tShowSeqDatas[1].nKey, tShowSeqDatas[1].nHandler)
	else
		Player:getNewGuideMgr():showNewGuideAgain()
	end
end

--获取控制权限是否为空
function getIsSequeneceFree(  )
	-- dump(tShowSeqDatas, "控制权限是否为空 == ")
	if not bIsOpenShowSeq then
		return false
	end
	return #tShowSeqDatas == 0 and nCurrShowSeq == nil
end

function getIsCanPlayAudio()
	-- body
	if #tShowSeqDatas == 0 and nCurrShowSeq == nil then
		return true
	else
		if #tShowSeqDatas == 1 and tShowSeqDatas[1].nKey == e_show_seq.taskrward then
			return true
		end
	end
	return false
end

--是否显示手指
function getIsNoFingerSeq( )
	return getIsHideFinger(nCurrShowSeq)
end

--清空数据
function releaseShowSequenceData( )
	bIsOpenShowSeq = false
	tShowSeqDatas = {}
end

--清除任务奖励(没事不要调用, 为了配合策划某一个步骤加的)
function clearTaskReward( )
	-- print("清除任务奖励(没事不要调用, 为了配合策划某一个步骤加的)")
	-- body
	if #tShowSeqDatas > 0 then
		for k, v in pairs(tShowSeqDatas) do
			if v.nKey == e_show_seq.taskrward then
				table.remove(tShowSeqDatas, k)
			end
		end
	end
end

--在全部列表执行完后执行的一次方法,当空闲时马上执行
function doInAllOverFuncOnce( nFunc )
	if getIsSequeneceFree() then
		nFunc()
	else
		nOnceFunc = nFunc
	end
end

--清空数据
function clearShowSequenceData( )
	tShowSeqDatas = {}
	nCurrShowSeq = nil
end

function getCurrShowSeq()
	return nCurrShowSeq
end