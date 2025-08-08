---@class addon
local addon = select(2, ...)
local NS = addon.C.Animation; addon.C.Animation = NS

--------------------------------
-- FUNCTIONS (EASE)
--------------------------------

do
	-- https://easings.net

	function NS.EaseLinear(x)
		return x
	end

	function NS.EaseSine_In(x)
		return 1 - math.cos((x * math.pi) / 2)
	end

	function NS.EaseSine_Out(x)
		return math.sin((x * math.pi) / 2)
	end

	function NS.EaseSine_InOut(x)
		return -(math.cos(math.pi * x) - 1) / 2
	end

	function NS.EaseCubic_In(x)
		return x * x * x
	end

	function NS.EaseCubic_Out(x)
		return 1 - math.pow(1 - x, 3)
	end

	function NS.EaseCubic_InOut(x)
		return x < 0.5 and 4 * x * x * x or 1 - math.pow(-2 * x + 2, 3) / 2
	end

	function NS.EaseQuint_In(x)
		return x * x * x * x * x
	end

	function NS.EaseQuint_Out(x)
		return 1 - math.pow(1 - x, 5)
	end

	function NS.EaseQuint_InOut(x)
		return x < 0.5 and 16 * x * x * x * x * x or 1 - math.pow(-2 * x + 2, 5) / 2
	end

	function NS.EaseCirc_In(x)
		return 1 - math.sqrt(1 - x * x)
	end

	function NS.EaseCirc_Out(x)
		return math.sqrt(1 - math.pow(x - 1, 2))
	end

	function NS.EaseCirc_InOut(x)
		return x < 0.5 and (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2 or (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2
	end

	function NS.EaseElastic_In(x)
		local c4 = (2 * math.pi) / 3
		return x == 0 and 0 or x == 1 and 1 or -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * c4)
	end

	function NS.EaseElastic_Out(x)
		local c4 = (2 * math.pi) / 3
		return x == 0 and 0 or x == 1 and 1 or math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * c4) + 1
	end

	function NS.EaseElastic_InOut(x)
		local c5 = (2 * math.pi) / 4.5
		return x == 0 and 0 or x == 1 and 1 or x < 0.5 and -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2 or (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
	end

	function NS.EaseQuad_In(x)
		return x * x
	end

	function NS.EaseQuad_Out(x)
		return 1 - math.pow(1 - x, 2)
	end

	function NS.EaseQuad_InOut(x)
		return x < 0.5 and 2 * x * x or 1 - math.pow(-2 * x + 2, 2) / 2;
	end

	function NS.EaseQuart_In(x)
		return x * x * x * x
	end

	function NS.EaseQuart_Out(x)
		return 1 - math.pow(1 - x, 4)
	end

	function NS.EaseQuart_InOut(x)
		return x < 0.5 and 8 * x * x * x * x or 1 - math.pow(-2 * x + 2, 4) / 2
	end

	function NS.EaseExpo_In(x)
		return x == 0 and 0 or math.pow(2, 10 * x - 10)
	end

	function NS.EaseExpo_Out(x)
		return x == 1 and 1 or 1 - math.pow(2, -10 * x)
	end

	function NS.EaseExpo_InOut(x)
		return x == 0 and 0 or x == 1 and 1 or x < 0.5 and math.pow(2, 20 * x - 10) / 2 or (2 - math.pow(2, -20 * x + 10)) / 2
	end

	function NS.EaseBack_In(x)
		local c1 = 1.70158
		local c3 = c1 + 1

		return c3 * x * x * x - c1 * x * x
	end

	function NS.EaseBack_Out(x)
		local c1 = 1.70158
		local c3 = c1 + 1

		return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
	end

	function NS.EaseBack_InOut(x)
		local c1 = 1.70158
		local c2 = c1 * 1.525

		return x < 0.5 and (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 or (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
	end

	function NS.EaseBounce_In(x)
		return 1 - NS.EaseBounce_Out(1 - x)
	end

	function NS.EaseBounce_Out(x)
		local n1 = 7.5625
		local d1 = 2.75

		if x < 1 / d1 then
			return n1 * x * x
		elseif x < 2 / d1 then
			return n1 * (x - 1.5 / d1) * x + 0.75
		elseif x < 2.5 / d1 then
			return n1 * (x - 2.25 / d1) * x + 0.9375
		else
			return n1 * (x - 2.625 / d1) * x + 0.984375
		end
	end

	function NS.EaseBounce_InOut(x)
		return x < 0.5 and (1 - NS.EaseBounce_Out(1 - 2 * x)) / 2 or (1 + NS.EaseBounce_Out(2 * x - 1)) / 2
	end
end
