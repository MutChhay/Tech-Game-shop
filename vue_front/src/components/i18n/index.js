import { createI18n } from 'vue-i18n'

import en from './local/en.json'
import km from './local/km.json'

const savedLanguage = typeof localStorage !== 'undefined' ?
    (localStorage.getItem('language') || 'en') :
    'en'

const i18n = createI18n({
    legacy: false,
    locale: savedLanguage,
    fallbackLocale: 'en',

    messages: {
        en,
        km,
    },
})

export default i18n