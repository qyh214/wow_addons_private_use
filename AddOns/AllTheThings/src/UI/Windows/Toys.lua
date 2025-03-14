-- App locals
local appName, app = ...;

-- Global locals
local ipairs, pairs, tinsert, tremove =
	  ipairs, pairs, tinsert, tremove;

-- Implementation
app:CreateWindow("Toys", {
	AllowCompleteSound = true,
	IsDynamicCategory = true,
	Commands = { "atttoys" },
	OnInit = function(self, handlers)
		self.data = {
			text = TOY_BOX,
			icon = app.asset("Category_ToyBox"),
			description = "This list shows you all of the toys that you can collect.",
			visible = true,
			expanded = true,
			back = 1,
			g = {},
			OnUpdate = function(data)
				local g = data.g;
				if #g < 1 then
					local headers = {};
					for i,matches in pairs(app.SearchForFieldContainer("toyID")) do
						self.BuildCategory(data, headers, matches, app.CreateToy(tonumber(i)));
					end
					for i=#g,1,-1 do
						local header = g[i];
						if header.g and #header.g < 1 and header.headerID and header.key == "headerID" then
							headers[header.headerID] = nil;
							tremove(g, i);
						else
							header.SortType = "name";
						end
					end
					data.SortType = "name";
				end
			end
		};
	end,
	OnLoad = function(self, settings)
		if settings.Progress then
			self.data.progress = settings.Progress;
			self.data.total = settings.Total;
		end
	end,
	OnSave = function(self, settings)
		settings.Progress = self.data.progress;
		settings.Total = self.data.total;
	end,
});