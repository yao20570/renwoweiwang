local ExamPlayerVo = class("ExamPlayerVo")

function ExamPlayerVo:ctor( tData )
	self:update(tData)
end

function ExamPlayerVo:update( tData )
	if not tData then
		return
	end
	self.nIndex     = tData.a   or self.nIndex      --int	        答案Index
	self.tPlayerIds = tData.r	or self.tPlayerIds  --List<String>  答题玩家列表
end

return ExamPlayerVo