local W, F, L, P = unpack(select(2, ...))

P.groupInfo = {
	enable = true,
	title = true,
	mode = "NORMAL",
	classIconStyle = "flat",
	template = "{{classIcon:18}} {{specIcon:14,18}} {{classColorStart}}{{className}} ({{specName}}){{classColorEnd}}{{amountStart}} x {{amount}}{{amountEnd}}",
}
