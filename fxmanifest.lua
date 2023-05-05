fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game 'gta5'

name 'esx_scuba'
version '1.1.1'
description 'FiveM resource to handle scuba based on ped component variation set'
author 'wobozkyng'

dependencies {
    'es_extended'
}

shared_script {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'shared.lua',
    'locales/*.lua'
}

shared_script 'config.lua'
client_script 'cl_function.lua'
client_script 'cl_main.lua'
server_script 'sv_*.lua'