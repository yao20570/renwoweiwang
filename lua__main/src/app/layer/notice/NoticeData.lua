-- NoticeData.lua
-----------------------------------------------------
-- Author: dshulan
-- Date: 2017-06-6 09:41:41
-- Description: 公告列表数据
-----------------------------------------------------


-- 公告数据类
local NoticeData = class("NoticeData")



function NoticeData:ctor(  )
	self.tNoticeMsgs   = {}    --公告列表
	self.bHasNewNotice = 0     --是否有新公告(0没有,1有)
end

--[4520]加载公告列表
function NoticeData:onLoadNotice( tData )
	-- body
	self.tNoticeList = {}
	-- local tTestData = {
	-- 	st = 1,
	-- 	nmsg = {
	-- 		[1] = {gp=1, st=1496735040, et=1499327040, tit="更新公告", ver=0606, id=1001, op=0, cnt="一个能表示一份数据在某个特定时间之前已经存在的、 完整的、 可验证的数据,通常是一个字符序列，唯一地标识某一刻的时间。"},
	-- 		[2] = {gp=2, st=1496735000, et=1499327777, tit="系统公告", ver=0607, id=1002, op=0, cnt="通常是一个字符序列，唯一地标识某一刻的时间。使用数字签名技术产生的数据， 签名的对象包括了原始文件信息、 签名参数、 签名时间等信息。"}
	-- 	}
	-- }
	local tNoticeInfo = self:createNoticeInfo(tData)
	--是否有新公告
	self.bHasNewNotice = tNoticeInfo.bHasNewNotice
end

--公告信息
function NoticeData:createNoticeInfo(_tData)
	-- body
	if not _tData then return end
	local tRes = {}
	tRes.bHasNewNotice     = _tData.st == 1   --Integer 是否有新公告 1有0没有
	tRes.tNoticeList       = _tData.nmsg      --list    公告列表
	for _, v in pairs(tRes.tNoticeList) do
		-- self.tNoticeList[v.id] = self:createNoticeMsg(v)
		table.insert(self.tNoticeList, self:createNoticeMsg(v))
	end
	return tRes
end

--创建公告列表信息
function NoticeData:createNoticeMsg(_tData)
	if not _tData then
		return
	end
	local tRes = {}
	tRes.nGroup            = _tData.gp       --Integer 公告分组:活动公告、更新公告、官方公告
	tRes.nStartTime        = _tData.st       --Long    展示开始时间
	tRes.nEndTime          = _tData.et       --Long    展示结束时间
	tRes.sTitle            = _tData.tit      --String  标题
	tRes.nVersion          = _tData.ver      --Integer 版本
	tRes.nNoticeId         = _tData.id       --Integer 公告id
	tRes.bHasRead          = _tData.op == 1  --Integer 是否公告已打开 1打开 0没有
	tRes.sContent          = _tData.cnt      --String  公告内容
	return tRes
end

--获取公告列表
function NoticeData:getNoticeMsgList()
	return self.tNoticeList
end

--[4515]公告设置为已读(公告id和公告版本)
function NoticeData:onNoticeRead(_nNoticeId, _nNoticeVer)
	for _, data in ipairs(self.tNoticeList) do
		if data.nNoticeId == _nNoticeId and data.nVersion == _nNoticeVer then
			data.bHasRead = true
			break
		end
	end
end

--获取公告红点，当玩家有未读公告时提示红点，所有公告已经阅读，红点消失
-- 1表示还有未阅读的  0表示全部阅读
function NoticeData:getNoticeRedNums( )
	if self.nRedNum then
		return self.nRedNum
	end
	local nIndex = 0
	for k,v in pairs(self.tNoticeList) do
		if v.bHasRead then
			nIndex = nIndex + 1
		else
			return 1
		end
	end
	if nIndex > 0 and nIndex == table.nums(self.tNoticeList) then
		return 0
	elseif nIndex > 0 and nIndex < table.nums(self.tNoticeList) then
		
		return 1
	else  --没有公告
		return 0
	end
end

--主公升级时等级预览红点设置
function NoticeData:setNoticeRedNums(_num)
	self.nRedNum = _num
end

function NoticeData:getLevelPreviewNums()
	return self.nRedNum
end

return NoticeData