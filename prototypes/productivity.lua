require("prototypes.log1")
require("prototypes.malls")
require("prototypes.cross_city_trades")
require("prototypes.science")

function productivity_module_limitation()
return
      can_productivity_module
end


data.raw["module"]["productivity-module"].limitation = productivity_module_limitation()
data.raw["module"]["productivity-module-2"].limitation = productivity_module_limitation()
data.raw["module"]["productivity-module-3"].limitation = productivity_module_limitation()

