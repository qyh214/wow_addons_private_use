
U1CoreAPI.RegisterAddOn("163UI_Info", {
	title = "DD数据同步插件",
	defaultEnable = 1,
	load = "NORMAL",
	tags = { "TAG_MANAGEMENT", },
	-- hide = 1,

	{
		text = "drop",
		-- var = "TestDrop",
		type = "drop",
		options = {
			"所有目标", "all",
			"目标", "target",
			"焦点", "focus",
			"鼠标指向", "mouseover",
			"目标的目标", "targettarget",
		},
		default = "target",
		callback = function(cfg, v, loading)
		end,
	},
	{
		text = "spin",
		-- var = "TestSpin",
		default = 1,
		type = "spin",
		range = { 0.0, 1.0, 0.05 },
		callback = function(cfg, v, loading)
		end,
	},
	{
		text = "input",
		-- var = "TestInput",
		default = "input",
		type = 'input',
		callback = function(cfg, v, loading)
		end,
	},
	{
		text = "button",
		-- var = "TestButton",
		type = 'button',
		callback = function(cfg, v, loading)
		end,
	},

})
