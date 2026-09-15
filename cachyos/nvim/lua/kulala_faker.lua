-- Fake-data generators for kulala.nvim, exposed as `{{$random.<name>}}`.
--
-- kulala resolves a magic variable by exact table lookup, so these take no
-- arguments (unlike JetBrains' `$random.integer(1,10)`). Need a different
-- shape? Add an entry below -- it's picked up on the next nvim restart.

local M = {}

math.randomseed(os.time() + ((vim.uv or vim.loop).hrtime() % 100000))

local first_names = {
  "Ada", "Blaise", "Chidi", "Dara", "Emil", "Fatima", "Grace", "Hana",
  "Ivo", "Juno", "Kai", "Lena", "Mateo", "Nina", "Omar", "Pia",
  "Quinn", "Rui", "Sena", "Tariq", "Uma", "Vera", "Wren", "Yara",
}

local last_names = {
  "Alvarez", "Bauer", "Chen", "Dubois", "Eriksen", "Farouk", "Gallo",
  "Haddad", "Ibarra", "Jansen", "Kovac", "Lindqvist", "Moreau", "Nakamura",
  "Okafor", "Petrov", "Reyes", "Silva", "Tanaka", "Vidal", "Weber", "Zhao",
}

local companies = {
  "Northwind", "Contoso", "Initech", "Umbrella", "Globex", "Soylent",
  "Hooli", "Vandelay", "Acme", "Cyberdyne", "Tyrell", "Wayne",
}

local suffixes = { "Labs", "Systems", "Group", "Industries", "Works", "Digital" }

local lorem = {
  "lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing",
  "elit", "sed", "eiusmod", "tempor", "incididunt", "labore", "magna",
  "aliqua", "veniam", "quis", "nostrud", "exercitation", "ullamco",
}

local tlds = { "com", "org", "io", "dev", "net" }

local function pick(t)
  return t[math.random(#t)]
end

local function slug(s)
  return (s:lower():gsub("[^%w]+", "-"))
end

local function join(t, sep)
  return table.concat(t, sep)
end

local function repeat_pick(source, n, sep)
  local out = {}
  for _ = 1, n do
    out[#out + 1] = pick(source)
  end
  return join(out, sep or " ")
end

local function hex(n)
  local out = {}
  for _ = 1, n do
    out[#out + 1] = string.format("%x", math.random(0, 15))
  end
  return join(out, "")
end

local function company_name()
  return pick(companies) .. " " .. pick(suffixes)
end

M.vars = {
  -- people
  ["$random.firstName"] = function()
    return pick(first_names)
  end,
  ["$random.lastName"] = function()
    return pick(last_names)
  end,
  ["$random.fullName"] = function()
    return pick(first_names) .. " " .. pick(last_names)
  end,
  ["$random.userName"] = function()
    return slug(pick(first_names)) .. "." .. slug(pick(last_names)) .. math.random(10, 99)
  end,
  ["$random.email"] = function()
    return ("%s.%s%d@%s"):format(slug(pick(first_names)), slug(pick(last_names)), math.random(10, 999), pick({
      "example.com",
      "example.org",
      "mailinator.test",
    }))
  end,
  ["$random.phone"] = function()
    return ("+1%d%07d"):format(math.random(200, 989), math.random(0, 9999999))
  end,

  -- org / web
  ["$random.company"] = company_name,
  ["$random.domain"] = function()
    return slug(pick(companies)) .. "." .. pick(tlds)
  end,
  ["$random.url"] = function()
    return ("https://%s.%s/%s"):format(slug(pick(companies)), pick(tlds), slug(pick(lorem)))
  end,
  ["$random.ipv4"] = function()
    return ("%d.%d.%d.%d"):format(math.random(1, 223), math.random(0, 255), math.random(0, 255), math.random(1, 254))
  end,

  -- text
  ["$random.word"] = function()
    return pick(lorem)
  end,
  ["$random.words"] = function()
    return repeat_pick(lorem, math.random(3, 8))
  end,
  ["$random.sentence"] = function()
    local s = repeat_pick(lorem, math.random(6, 14))
    return s:sub(1, 1):upper() .. s:sub(2) .. "."
  end,
  ["$random.slug"] = function()
    return repeat_pick(lorem, 3, "-")
  end,

  -- scalars
  ["$random.bool"] = function()
    return math.random(0, 1) == 1 and "true" or "false"
  end,
  ["$random.int"] = function()
    return math.random(0, 9999)
  end,
  ["$random.smallInt"] = function()
    return math.random(1, 100)
  end,
  ["$random.price"] = function()
    return ("%d.%02d"):format(math.random(1, 999), math.random(0, 99))
  end,
  ["$random.hex"] = function()
    return hex(16)
  end,
  ["$random.token"] = function()
    return hex(40)
  end,
  ["$random.password"] = function()
    return pick(lorem):sub(1, 1):upper() .. pick(lorem) .. math.random(100, 999) .. "!"
  end,

  -- time
  ["$random.pastDate"] = function()
    return os.date("!%Y-%m-%dT%H:%M:%SZ", os.time() - math.random(86400, 86400 * 365))
  end,
  ["$random.futureDate"] = function()
    return os.date("!%Y-%m-%dT%H:%M:%SZ", os.time() + math.random(86400, 86400 * 365))
  end,
}

return M
