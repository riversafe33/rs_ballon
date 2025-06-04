Config = {}

-- Change the language
Config.Lang = 'English' -- 'English' -- 'French' -- 'Portuguese_BR'  -- 'German'  -- 'Italian' -- 'Spanish'

------------------------------- Hot Air Balloon Rental ------------------------------
Config.KeyToBuyBalloon = 0xD9D0E1C0 -- [ SPACE ] Key to rent the balloon

-- Rental price  settings
Config.EnableTax = true   -- If true, the balloon rental fee will be charged, if false, it will be free.
Config.BallonPrice = 5.00 -- Rental price
Config.BalloonModel = "hotairballoon01x"

Config.EnableBalloonTimer = true -- If you set it to false, the balloon will not disappear automatically.
Config.BallonUseTime = 30 -- Rental duration time in minutes



-- Hot Air Balloon Rental locations
Config.BalloonLocations = {
  {
    coords = vector3(-397.655517578125, 715.9544677734375, 114.88623809814453), -- For the blip
    name = "Hot Air Balloon Rental",
    sprite = -1595467349
  },
  -- You can add more locations here
}

------------------------------ Hot Air Balloon store ----------------------------------

Config.Marker = {
	["valentine"]   = {name = "Hot Air Balloon Store", sprite = -780469251, x = -290.4917297363281,  y = 691.4873657226562,   z = 112.36164855957031},
  ["saint_denis"] = {name = "Hot Air Balloon Store", sprite = -780469251, x = 2477.20751953125,    y = -1364.8922119140625, z = 45.31382369995117},
  ["rhodes"]      = {name = "Hot Air Balloon Store", sprite = -780469251, x = 1225.972412109375,   y = -1271.141845703125,  z = 74.93492889404297},
  ["strawberry"]  = {name = "Hot Air Balloon Store", sprite = -780469251, x = -1784.7342529296875, y = -432.100341796875,   z = 154.2776641845703},
  ["blackwater"]  = {name = "Hot Air Balloon Store", sprite = -780469251, x = -839.0341796875,     y = -1218.6031494140625, z = 42.39957809448242},
  --  ["city"]  = {name = "Hot Air Balloon Store", sprite = -780469251, x = , y = , z = },

} 

Config.NPC = {
  model = "A_M_M_UniBoatCrew_01",
  coords = {
    vector4(-290.4917297363281, 691.4873657226562, 112.36164855957031, 309.47), -- Valentine Npc
    vector4(2477.20751953125, -1364.8922119140625, 45.31382369995117, 103.17),  -- Saint Denis Npc
    vector4(1225.972412109375, -1271.141845703125, 74.93492889404297, 249.81),  -- Rhodes Npc
    vector4(-1784.7342529296875, -432.100341796875, 154.2776641845703, 72.32),  -- Strawberry Npc
    vector4(-839.0341796875, -1218.6031494140625, 42.39957809448242, 12.37),    -- Blackwater Npc
    vector4(-397.655517578125, 715.9544677734375, 114.88623809814453, 109.31),  -- Valentine Rental Npc
  }
}

------------------------------ Sale price ----------------------------------

Config.Globo = {
  [1] = {
    ['Text'] = "Hot Air Balloon",   -- Change it to your language
    ['Param'] = {
      ['Name'] = "Hot Air Balloon", -- Change it to your language
      ['Price'] = 1250,               -- Sale price
    }
  },
}
