--This script removes the power requirements for some machines
for k, v in pairs(data.raw["assembling-machine"]) do
	v.energy_source ={type = "void"}
end


for k, v in pairs(data.raw["inserter"]) do
	v.energy_source ={type = "void"}
end
--remove power from spawned or placeable
data.raw["rocket-silo"]["rocket-silo"].energy_source ={type = "void"}
data.raw["pump"]["pump"].energy_source ={type = "void"}
data.raw["radar"]["radar"].energy_source ={type = "void"}
data.raw["lamp"]["small-lamp"].energy_source ={type = "void"}
data.raw["roboport"]["roboport"].energy_source ={type = "void"}
data.raw["beacon"]["beacon"].energy_source ={type = "void"}
data.raw["lab"]["lab"].energy_source ={type = "void"}

data.raw["arithmetic-combinator"]["arithmetic-combinator"].energy_source ={type = "void"}
data.raw["decider-combinator"]["decider-combinator"].energy_source ={type = "void"}
data.raw["constant-combinator"]["constant-combinator"].energy_source ={type = "void"}
data.raw["programmable-speaker"]["programmable-speaker"].energy_source ={type = "void"}

