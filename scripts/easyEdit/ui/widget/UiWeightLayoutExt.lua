
local UiWeightLayoutExt = Class.inherit(UiWeightLayout)
function UiWeightLayoutExt:new()
	UiWeightLayout.new(self)
end

function UiWeightLayoutExt:relayout()
	assert(type(self.horizontal) == "boolean")

	local remainingSpaceW = self.w - self.padl - self.padr
	local remainingSpaceH = self.h - self.padt - self.padb
	local weightSumW = 0
	local weightSumH = 0
	local innerWidth = 0
	local innerHeight = 0

	-- Preprocess - count how much space we have to work with, and what the sum of weights is,
	-- so that we can divide the space accordingly.
	local visibleChildrenCount = 0
	for i = 1, #self.children do
		local child = self.children[i]
		if child.visible then
			visibleChildrenCount = visibleChildrenCount + 1
			if self.horizontal then
				if child.wPercent == nil then
					remainingSpaceW = math.max(0, remainingSpaceW - child.w)
				else
					weightSumW = weightSumW + child.wPercent
				end
			else
				if child.hPercent == nil then
					remainingSpaceH = math.max(0, remainingSpaceH - child.h)
				else
					weightSumH = weightSumH + child.hPercent
				end
			end
		end
	end

	remainingSpaceW = remainingSpaceW - (visibleChildrenCount - 1) * self.gapHorizontal
	remainingSpaceH = remainingSpaceH - (visibleChildrenCount - 1) * self.gapVertical

	local currentMaxSize = 0
	-- positions of the next child
	local nextX = 0
	local nextY = 0
	for i = 1, #self.children do
		local child = self.children[i]

		if child.visible then
			child.x = nextX
			child.y = nextY

			if self.horizontal then
				if child.wPercent ~= nil then
					child.w = remainingSpaceW * (child.wPercent / weightSumW)
				end
				if child.hPercent ~= nil then
					child.h = (self.h - self.padt - self.padb) * child.hPercent
				end

				nextX = nextX + child.w + self.gapHorizontal
				currentMaxSize = math.max(currentMaxSize, child.h)

				innerWidth = innerWidth + child.w + self.gapHorizontal
			else
				if child.wPercent ~= nil then
					child.w = (self.w - self.padl - self.padr) * child.wPercent
				end
				if child.hPercent ~= nil then
					child.h = remainingSpaceH * (child.hPercent / weightSumH)
				end

				nextY = nextY + child.h + self.gapVertical
				currentMaxSize = math.max(currentMaxSize, child.w)

				innerHeight = innerHeight + child.h + self.gapVertical
			end

			child.screenx = self.screenx + self.padl - self.dx + child.x
			child.screeny = self.screeny + self.padt - self.dy + child.y

			child:relayout()

			child.rect.x = child.screenx
			child.rect.y = child.screeny
			child.rect.w = child.w
			child.rect.h = child.h
		end
	end

	if self.horizontal then
		self.innerWidth = innerWidth
		self.innerHeight = currentMaxSize
	else
		self.innerWidth = currentMaxSize
		self.innerHeight = innerHeight
	end

	if self.isCompact then
		self.w = math.min(self.w, self.innerWidth)
		self.h = math.min(self.h, self.innerHeight)
	end
end

return UiWeightLayoutExt
