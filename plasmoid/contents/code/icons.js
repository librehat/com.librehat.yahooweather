var WeatherFont = {
    
    // https://erikflowers.github.io/weather-icons/
    codeByName: {
        'wi-day-sunny': '\uf00d',
        'wi-night-clear': '\uf02e',
        'wi-day-sunny-overcast': '\uf00c',
        'wi-night-partly-cloudy': '\uf083',
        'wi-day-cloudy': '\uf002',
        'wi-night-cloudy': '\uf031',
        'wi-cloudy': '\uf013',
        'wi-day-showers': '\uf009',
        'wi-night-showers': '\uf037',
        'wi-day-storm-showers': '\uf00e',
        'wi-night-storm-showers': '\uf03a',
        'wi-day-rain-mix': '\uf006',
        'wi-night-rain-mix': '\uf034',
        'wi-day-snow': '\uf00a',
        'wi-night-snow': '\uf038',
        'wi-cloud': '\uf041',   // new: for "few cloudy"
        'wi-showers': '\uf01a',
        'wi-rain': '\uf019',
        'wi-thunderstorm': '\uf01e',
        'wi-rain-mix': '\uf017',
        'wi-snow': '\uf01b',
        'wi-day-snow-thunderstorm': '\uf06b',
        'wi-night-snow-thunderstorm': '\uf06c',
        'wi-dust': '\uf063',
        'wi-day-sleet-storm': '\uf068',
        'wi-night-sleet-storm': '\uf069',
        'wi-storm-showers': '\uf01d',
        'wi-day-sprinkle': '\uf00b',
        'wi-night-sprinkle': '\uf039',
        'wi-day-thunderstorm': '\uf010',
        'wi-night-thunderstorm': '\uf03b',
        'wi-sprinkle': '\uf01c',
        'wi-day-rain': '\uf008',
        'wi-night-rain': '\uf036',
        'wi-lightning': '\uf016',
        'wi-sleet': '\uf0b5',
        'wi-fog': '\uf014',
        'wi-smoke': '\uf062',
        'wi-volcano': '\uf0c8',
        'wi-strong-wind': '\uf050',
        'wi-tornado': '\uf056',
        'wi-windy': '\uf021',
        'wi-hurricane': '\uf073',
        'wi-snowflake-cold': '\uf076',
        'wi-hot': '\uf072',
        'wi-hail': '\uf015',
        'wi-sunset': '\uf052',
        'wi-na': '\uf07b'    // new: for "not available"
    },
    
    mapConditionIconToFont: {
        'weather-storm': 'wi-thunderstorm',
        'weather-snow-rain': 'wi-rain-mix',
        'weather-snow-scattered': 'wi-snowflake-cold',
        'weather-freezing-rain': 'wi-sleet',
        'weather-showers-scattered': 'wi-showers',
        'weather-showers': 'wi-showers',
        'weather-snow': 'wi-snow',
        'weather-hail': 'wi-hail',
        'weather-mist': 'wi-sprinkle',
        'weather-clouds': 'wi-cloudy',
        'weather-many-clouds': 'wi-cloudy',
        'weather-few-clouds-night': 'wi-night-partly-cloudy',
        'weather-few-clouds': 'wi-cloud',
        'weather-clear-night': 'wi-night-clear',
        'weather-clear': 'wi-day-sunny',
        'weather-none-available': 'wi-na'
    }
}


function getFontCode(conditionIconName) {
    var fontCode = null
    var fontName = null
    fontName = WeatherFont.mapConditionIconToFont[conditionIconName];
    fontCode = WeatherFont.codeByName[fontName];

    // check for unmapped condition icon name
    if (!fontCode) {
        fontCode = WeatherFont.codeByName['wi-na']
    }
    return fontCode
}
