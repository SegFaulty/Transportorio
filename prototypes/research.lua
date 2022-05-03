--This script creates custom research

--disable and hide all technology
for k, v in pairs(data.raw.technology) do
	v.enabled = false
	v.hidden = true
end

-- Create new research
data.raw.technology["steel-axe"] = {
    type = "technology",
    name = "steel-axe",
    icon_size = 128,
    icon = "__base__/graphics/technology/steel-axe.png",
    effects =
    {
      {
        type = "character-mining-speed",
        modifier = 1
      }
    },
    unit =
    {
      count = 5,
      ingredients =
      {
        {"automation-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-c-a"
  }

data.raw.technology["toolbelt"] = {
    type = "technology",
    name = "toolbelt",
    icon_size = 128,
    icon = "__base__/graphics/technology/toolbelt.png",
    effects =
    {
      {
        type = "character-inventory-slots-bonus",
        modifier = 10
      }
    },
    unit =
    {
      count = 10,
      ingredients =
      {
        {"logistic-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-k-m"
  }
      
data.raw.technology["inserter-capacity-bonus-1"] = {
    type = "technology",
    name = "inserter-capacity-bonus-1",
    icon = "__base__/graphics/technology/inserter-capacity.png",
    icon_size = 128,
    effects =
    {
      {
        type = "inserter-stack-size-bonus",
        modifier = 4
      },
      {
        type = "stack-inserter-capacity-bonus",
        modifier = 4 
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"logistic-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-o-b"
  }
  
data.raw.technology["inserter-capacity-bonus-2"] = {
    type = "technology",
    name = "inserter-capacity-bonus-2",
    icon = "__base__/graphics/technology/inserter-capacity.png",
    icon_size = 128,
    effects =
    {
      {
        type = "inserter-stack-size-bonus",
        modifier = 4
      },
      {
        type = "stack-inserter-capacity-bonus",
        modifier = 4
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"chemical-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-o-c"
  }
  
data.raw.technology["inserter-capacity-bonus-3"] = {
    type = "technology",
    name = "inserter-capacity-bonus-3",
    icon = "__base__/graphics/technology/inserter-capacity.png",
    icon_size = 128,
    effects =
    {
      {
        type = "stack-inserter-capacity-bonus",
        modifier = 4  
      }
    },
    unit =
    {
      count_formula = "2^(L-3)*100",
      ingredients =
      {
        {"space-science-pack", 10}
      },
      time = 0.1
    },
    max_level = "infinite",
    order = "c-o-d"
  }
  
  data.raw.technology["inserter-capacity-bonus-4"] = nil
  data.raw.technology["inserter-capacity-bonus-5"] = nil
  data.raw.technology["inserter-capacity-bonus-6"] = nil
  data.raw.technology["inserter-capacity-bonus-7"] = nil
  
data.raw.technology["worker-robots-speed-1"] = {
    type = "technology",
    name = "worker-robots-speed-1",
    icon_size = 128,
    icon = "__base__/graphics/technology/worker-robots-speed.png",
    effects =
    {
      {
        type = "worker-robot-speed",
        modifier = 1
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"chemical-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-k-f-a"
  }
  
data.raw.technology["worker-robots-speed-2"] = {
    type = "technology",
    name = "worker-robots-speed-2",
    icon_size = 128,
    icon = "__base__/graphics/technology/worker-robots-speed.png",
    effects =
    {
      {
        type = "worker-robot-speed",
        modifier = 1
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"utility-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-k-f-b"
  }
  
data.raw.technology["worker-robots-speed-3"] = {
    type = "technology",
    name = "worker-robots-speed-3",
    icon_size = 128,
    icon = "__base__/graphics/technology/worker-robots-speed.png",
    effects =
    {
      {
        type = "worker-robot-speed",
        modifier = 1
      }
    },
    unit =
    {
      count_formula = "2^(L-3)*100",
      ingredients =
      {
        {"space-science-pack", 10}
      },
      time = 0.1
    },
    max_level = "infinite",
    order = "c-k-f-e"
  }
  
  data.raw.technology["worker-robots-speed-4"] = nil
  data.raw.technology["worker-robots-speed-5"] = nil
  data.raw.technology["worker-robots-speed-6"] = nil
  
data.raw.technology["worker-robots-storage-1"] = {
    type = "technology",
    name = "worker-robots-storage-1",
    icon_size = 128,
    icon = "__base__/graphics/technology/worker-robots-storage.png",
    effects =
    {
      {
        type = "worker-robot-storage",
        modifier = 1
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"production-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-k-g-a"
  }
  
data.raw.technology["worker-robots-storage-2"] = {
    type = "technology",
    name = "worker-robots-storage-2",
    icon_size = 128,
    icon = "__base__/graphics/technology/worker-robots-storage.png",
    effects =
    {
      {
        type = "worker-robot-storage",
        modifier = 1
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"utility-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-k-g-b"
  }
  
data.raw.technology["worker-robots-storage-3"] = {
    type = "technology",
    name = "worker-robots-storage-3",
    icon_size = 128,
    icon = "__base__/graphics/technology/worker-robots-storage.png",
    effects =
    {
      {
        type = "worker-robot-storage",
        modifier = 1
      }
    },
    unit =
    {
      count_formula = "2^(L-3)*100",
      ingredients =
      {
        {"space-science-pack", 10}
      },
      time = 0.1
    },
    max_level = "infinite",
    order = "c-k-g-c"
  }
  
data.raw.technology["braking-force-1"] = {
    type = "technology",
    name = "braking-force-1",
    icon_size = 128,
    icon = "__base__/graphics/technology/braking-force.png",
    effects =
    {
      {
        type = "train-braking-force-bonus",
        modifier = 0.35
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"military-science-pack", 10}
      },
      time = 0.1
    },
    order = "b-f-a"
  }
  
data.raw.technology["braking-force-2"] = {
    type = "technology",
    name = "braking-force-2",
    icon_size = 128,
    icon = "__base__/graphics/technology/braking-force.png",
    effects =
    {
      {
        type = "train-braking-force-bonus",
        modifier = 0.35
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"production-science-pack", 10}
      },
      time = 0.1
    },
    order = "b-f-b"
  }
  
data.raw.technology["braking-force-3"] = {
    type = "technology",
    name = "braking-force-3",
    icon_size = 128,
    icon = "__base__/graphics/technology/braking-force.png",
    effects =
    {
      {
        type = "train-braking-force-bonus",
        modifier = 0.35
      }
    },
    unit =
    {
      count_formula = "2^(L-3)*100",
      ingredients =
      {
        {"space-science-pack", 10}
      },
      time = 0.1
    },
    max_level = "infinite",
    order = "b-f-c"
  }
  
  data.raw.technology["braking-force-4"] = nil
  data.raw.technology["braking-force-5"] = nil
  data.raw.technology["braking-force-6"] = nil
  data.raw.technology["braking-force-7"] = nil
  
data.raw.technology["logistic-robotics"] = {
    type = "technology",
    name = "logistic-robotics",
    icon_size = 128,
    icon = "__base__/graphics/technology/logistic-robotics.png",
    effects =
    {
      {
        type = "character-logistic-requests",
        modifier = true
      },
      {
        type = "character-logistic-trash-slots",
        modifier = 30
      }
    },
    unit =
    {
      count = 100,
      ingredients =
      {
        {"military-science-pack", 10}
      },
      time = 0.1
    },
    order = "c-k-c"
  }
  