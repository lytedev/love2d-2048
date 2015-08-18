local Board = {}
Board.__index = Board

function Board.new()
	local self = setmetatable({}, Board)

	self.padding = 10
	self.width = 4
	self.height = 4

	self.tiles = {}
	for y = 1, self.height do
		row = {}
		table.insert(self.tiles, row)
		for x = 1, self.width do
			table.insert(row, 0)
		end
	end

	self.tileColors = {
		[0] = {128, 128, 128, 50},
		[2] = {128, 128, 128, 255},
		[4] = {100, 128, 160, 255}
	}

	self:generateTile()
	self:generateTile()

	return self
end

function Board.getTile(self, x, y)
	if x < 1 or y < 1 or x > self.width or y > self.height then return nil end
	return self.tiles[y][x]
end

function Board.setTile(self, x, y, n)
	self.tiles[y][x] = n
end

function Board.generateTile(self)
	local empty = self:getEmptyTiles()
	if #empty < 1 then return end
	local i = love.math.random(#empty)
	local tile = empty[i]
	self:setTile(tile[1], tile[2], 2)
end

function Board.getEmptyTiles(self)
	local pairs = pairs
	local empty = {}
	for y = 1, self.height do
		for x = 1, self.width do
			n = self:getTile(x, y)
			if n == 0 then
				table.insert(empty, {x, y})
			end
		end
	end
	return empty
end

function Board.getNonEmptyTiles(self)
	local pairs = pairs
	local nonEmpty = {}
	for y, row in pairs(self.tiles) do
		for x, n in pairs(row) do
			if n ~= 0 then
				table.insert(nonEmpty, {x, y})
			end
		end
	end
	return nonEmpty
end

function Board.teleportTile(self, x1, y1, x2, y2)
	local tile = self:getTile(x1, y1)
	self:setTile(x2, y2, tile)
	self:setTile(x1, y1, 0)
end

function Board.mergeTile(self, x1, y1, x2, y2)
	local t1 = self:getTile(x1, y1)
	local t2 = self:getTile(x2, y2)
	self:setTile(x2, y2, t1 + t2)
	self:setTile(x1, y1, 0)
end

function Board.moveTile(self, x1, y1, x2, y2)
	print(x1, y1)
	print(x2, y2)
	local t1 = self:getTile(x1, y1)
	local t2 = self:getTile(x2, y2)
	if t2 == nil then return false
	elseif t2 == 0 and t1 ~= 0 then
		self:teleportTile(x1, y1, x2, y2)
		return true
	elseif t2 == t1 and t1 ~= 0 then
		self:mergeTile(x1, y1, x2, y2)
		return true
	elseif t1 ~= 0 and t2 ~= 0 and t1 ~= t2 then return false
	end
end

function Board.slideTile(self, x, y, dir)
	local dx, dy = getDirVector(dir)
	local tile = self:getTile(x, y)
	local tx, ty = x, y
	local tx2, ty2 = tx, ty
	local moving = true
	while moving do
		tx2, ty2 = tx + dx, ty + dy
		moving = self:moveTile(tx, ty, tx2, ty2)
		tx, ty = tx2, ty2
	end
end

function Board.slide(self, dir)

	for _, t in pairs(self:getNonEmptyTiles()) do
		self:slideTile(t[1], t[2], dir)
	end
	self:generateTile()
end

function Board.draw(self)
	local pairs = pairs
	local font = love.graphics.getFont()
	local fh = love.graphics.getFont():getHeight() / 2
	local winWidth = love.graphics.getWidth() - (self.padding * 2)
	local winHeight = love.graphics.getHeight() - (self.padding * 2)
	local xSpace = 1 / (self.width / winWidth)
	local ySpace = 1 / (self.height / winHeight)
	for y, row in pairs(self.tiles) do
		for x, n in pairs(row) do
			ns = tostring(n)
			color = self.tileColors[n] or {255, 255, 255, 255}
			love.graphics.setColor(color)
			local nw = font:getWidth(ns)
			love.graphics.printf(ns, ((x - 1) * xSpace) + self.padding - (nw / 4), ((y - 0.5) * ySpace) - fh + self.padding, xSpace, "center")
		end
	end
end

function getDirVector(dir)
	if dir == "left" then
		return -1, 0
	elseif dir == "right" then
		return 1, 0
	elseif dir == "up" then
		return 0, -1
	elseif dir == "down" then
		return 0, 1
	end
end

return Board
