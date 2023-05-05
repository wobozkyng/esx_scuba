local safeESXVersion = '1.9.0' -- compatible esx-legacy version, below than this needs adjustments
local currentESXVersion = GetResourceMetadata('es_extended', 'version', 0) or '0.0.0'
currentESXVersion = currentESXVersion and currentESXVersion:match('%d%.%d+%.%d+')
safeESXVersion = safeESXVersion and safeESXVersion:match('%d%.%d+%.%d+')

-- adjustments for esx-legacy version below than 1.8.5
if currentESXVersion < safeESXVersion then
	TranslateCap = _U
end