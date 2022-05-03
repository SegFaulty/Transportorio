
for i, resource in pairs (data.raw.resource) do
  resource.autoplace = nil
  data.raw["autoplace-control"][resource.name] = nil 
  end
   
 --for i, resource in pairs (data.raw.tree) do
  --resource.autoplace = nil
 -- end
  
  --data.raw["autoplace-control"]["trees"] = nil
  