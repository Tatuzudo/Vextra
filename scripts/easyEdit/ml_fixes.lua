
local path = GetParentPath(...)
local ok, err = assert(pcall(package.loadlib(path.."ml_fixes/ml_fixes.dll", "add_ml_fixes")))

if not ok then
	error("EasyEdit - Error applying ml_fixes:\n"..err)
else
	LOG("EasyEdit - Successfully applied ml_fixes")
end
