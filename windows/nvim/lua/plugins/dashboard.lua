local max_length = 10

local function opened_directory()
  local path = vim.fn.argv(0)
  if path ~= "" and vim.fn.isdirectory(path) == 1 then
    return vim.fn.fnamemodify(path, ":p")
  end
  return vim.fn.getcwd()
end

local function repo_name()
  local directory = opened_directory()
  return vim.fs.basename(vim.fs.root(directory, ".git") or vim.fs.normalize(directory))
end

local function words(name)
  local spaced = name:gsub("(%l)(%u)", "%1 %2"):gsub("[-_]", " ")
  return vim.split(spaced, " ", { trimempty = true })
end

local function initials(name_words)
  return table.concat(vim.tbl_map(function(word)
    return word:sub(1, 1):upper()
  end, name_words))
end

local function abbreviate(name)
  if #name <= max_length then
    return name
  end
  local last_segment = name:match("[^.]+$")
  if #last_segment <= max_length then
    return last_segment
  end
  local segment_words = words(last_segment)
  local short = initials(vim.list_slice(segment_words, 1, #segment_words - 1)) .. segment_words[#segment_words]
  if #short <= max_length then
    return short
  end
  return initials(segment_words):sub(1, max_length)
end

local function ascii_art(text)
  if vim.fn.executable("figlet") == 0 then
    return text
  end
  return (vim.fn.system({ "figlet", "-f", "slant", "-w", "200", text }):gsub("%s+$", ""))
end

return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard.preset.header = ascii_art(abbreviate(repo_name()))
  end,
}
