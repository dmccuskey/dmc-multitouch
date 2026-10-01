# dmc-multitouch

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "dmc-multitouch"
	include: "../DMC-Corona-Library/snakemake/Snakefile"

module_config = {
	"name": "dmc-multitouch",
	"module": {
		"dir": "dmc_corona",
		"files": [
			"dmc_multitouch.lua",
		],
		"requires": [
			"dmc-corona-boot",
			"dmc-touchmanager"
		]
	},
	"examples": {
		"base_dir": "examples",
		"apps": [
			{
				"exp_dir": "dmc-multitouch-basic",
				"requires": []
			},
		]
	},
	"tests": {
		"files": [],
		"requires": []
	}
}


register( "dmc-multitouch", module_config )
