const countries = [
  {
    name: "Afghanistan",
    code: "AF",
  },
  {
    name: "Åland Islands",
    code: "AX",
  },
  {
    name: "Albania",
    code: "AL",
  },
  {
    name: "Algeria",
    code: "DZ",
  },
  {
    name: "American Samoa",
    code: "AS",
  },
  {
    name: "Andorra",
    code: "AD",
  },
  {
    name: "Angola",
    code: "AO",
  },
  {
    name: "Anguilla",
    code: "AI",
  },
  {
    name: "Antarctica",
    code: "AQ",
  },
  {
    name: "Antigua and Barbuda",
    code: "AG",
  },
  {
    name: "Argentina",
    code: "AR",
  },
  {
    name: "Armenia",
    code: "AM",
  },
  {
    name: "Aruba",
    code: "AW",
  },
  {
    name: "Australia",
    code: "AU",
  },
  {
    name: "Austria",
    code: "AT",
  },
  {
    name: "Azerbaijan",
    code: "AZ",
  },
  {
    name: "the Bahamas",
    code: "BS",
  },
  {
    name: "Bahrain",
    code: "BH",
  },
  {
    name: "Bangladesh",
    code: "BD",
  },
  {
    name: "Barbados",
    code: "BB",
  },
  {
    name: "Belarus",
    code: "BY",
  },
  {
    name: "Belgium",
    code: "BE",
  },
  {
    name: "Belize",
    code: "BZ",
  },
  {
    name: "Benin",
    code: "BJ",
  },
  {
    name: "Bermuda",
    code: "BM",
  },
  {
    name: "Bhutan",
    code: "BT",
  },
  {
    name: "Bolivarian Republic of Venezuela",
    code: "VE",
  },
  {
    name: "Bolivia",
    code: "BO",
  },
  {
    name: "Bonaire, Sint Eustatius and Saba",
    code: "BQ",
  },
  {
    name: "Bosnia and Herzegovina",
    code: "BA",
  },
  {
    name: "Botswana",
    code: "BW",
  },
  {
    name: "Bouvet Island",
    code: "BV",
  },
  {
    name: "Brazil",
    code: "BR",
  },
  {
    name: "British Indian Ocean Territory",
    code: "IO",
  },
  {
    name: "Brunei",
    code: "BN",
  },
  {
    name: "Bulgaria",
    code: "BG",
  },
  {
    name: "Burkina Faso",
    code: "BF",
  },
  {
    name: "Burundi",
    code: "BI",
  },
  {
    name: "Cabo Verde",
    code: "CV",
  },
  {
    name: "Cambodia",
    code: "KH",
  },
  {
    name: "Cameroon",
    code: "CM",
  },
  {
    name: "Canada",
    code: "CA",
  },
  {
    name: "Cayman Islands",
    code: "KY",
  },
  {
    name: "Central African Republic",
    code: "CF",
  },
  {
    name: "Chad",
    code: "TD",
  },
  {
    name: "Chile",
    code: "CL",
  },
  {
    name: "China",
    code: "CN",
  },
  {
    name: "Christmas Island",
    code: "CX",
  },
  {
    name: "Cocos (Keeling) Islands",
    code: "CC",
  },
  {
    name: "Colombia",
    code: "CO",
  },
  {
    name: "Comoros",
    code: "KM",
  },
  {
    name: "Congo",
    code: "CG",
  },
  {
    name: "Congo (DRC)",
    code: "CD",
  },
  {
    name: "Cook Islands",
    code: "CK",
  },
  {
    name: "Costa Rica",
    code: "CR",
  },
  {
    name: "Côte d'Ivoire",
    code: "CI",
  },
  {
    name: "Croatia",
    code: "HR",
  },
  {
    name: "Cuba",
    code: "CU",
  },
  {
    name: "Curaçao",
    code: "CW",
  },
  {
    name: "Cyprus",
    code: "CY",
  },
  {
    name: "Czech Republic",
    code: "CZ",
  },
  {
    name: "Democratic Republic of Timor-Leste",
    code: "TL",
  },
  {
    name: "Denmark",
    code: "DK",
  },
  {
    name: "Djibouti",
    code: "DJ",
  },
  {
    name: "Dominica",
    code: "DM",
  },
  {
    name: "Dominican Republic",
    code: "DO",
  },
  {
    name: "Ecuador",
    code: "EC",
  },
  {
    name: "Egypt",
    code: "EG",
  },
  {
    name: "El Salvador",
    code: "SV",
  },
  {
    name: "Equatorial Guinea",
    code: "GQ",
  },
  {
    name: "Eritrea",
    code: "ER",
  },
  {
    name: "Estonia",
    code: "EE",
  },
  {
    name: "Ethiopia",
    code: "ET",
  },
  {
    name: "Falkland Islands (Islas Malvinas)",
    code: "FK",
  },
  {
    name: "Faroe Islands",
    code: "FO",
  },
  {
    name: "Fiji Islands",
    code: "FJ",
  },
  {
    name: "Finland",
    code: "FI",
  },
  {
    name: "France",
    code: "FR",
  },
  {
    name: "French Guiana",
    code: "GF",
  },
  {
    name: "French Polynesia",
    code: "PF",
  },
  {
    name: "French Southern and Antarctic Lands",
    code: "TF",
  },
  {
    name: "Gabon",
    code: "GA",
  },
  {
    name: "the Gambia",
    code: "GM",
  },
  {
    name: "Georgia",
    code: "GE",
  },
  {
    name: "Germany",
    code: "DE",
  },
  {
    name: "Ghana",
    code: "GH",
  },
  {
    name: "Gibraltar",
    code: "GI",
  },
  {
    name: "Greece",
    code: "GR",
  },
  {
    name: "Greenland",
    code: "GL",
  },
  {
    name: "Grenada",
    code: "GD",
  },
  {
    name: "Guadeloupe",
    code: "GP",
  },
  {
    name: "Guam",
    code: "GU",
  },
  {
    name: "Guatemala",
    code: "GT",
  },
  {
    name: "Guernsey",
    code: "GG",
  },
  {
    name: "Guinea",
    code: "GN",
  },
  {
    name: "Guinea-Bissau",
    code: "GW",
  },
  {
    name: "Guyana",
    code: "GY",
  },
  {
    name: "Haiti",
    code: "HT",
  },
  {
    name: "Heard Island and McDonald Islands",
    code: "HM",
  },
  {
    name: "Honduras",
    code: "HN",
  },
  {
    name: "Hong Kong SAR",
    code: "HK",
  },
  {
    name: "Hungary",
    code: "HU",
  },
  {
    name: "Iceland",
    code: "IS",
  },
  {
    name: "India",
    code: "IN",
  },
  {
    name: "Indonesia",
    code: "ID",
  },
  {
    name: "Iran",
    code: "IR",
  },
  {
    name: "Iraq",
    code: "IQ",
  },
  {
    name: "Ireland",
    code: "IE",
  },
  {
    name: "Israel",
    code: "IL",
  },
  {
    name: "Italy",
    code: "IT",
  },
  {
    name: "Jamaica",
    code: "JM",
  },
  {
    name: "Jan Mayen",
    code: "SJ",
  },
  {
    name: "Japan",
    code: "JP",
  },
  {
    name: "Jersey",
    code: "JE",
  },
  {
    name: "Jordan",
    code: "JO",
  },
  {
    name: "Kazakhstan",
    code: "KZ",
  },
  {
    name: "Kenya",
    code: "KE",
  },
  {
    name: "Kiribati",
    code: "KI",
  },
  {
    name: "Korea",
    code: "KR",
  },
  {
    name: "Kosovo",
    code: "XK",
  },
  {
    name: "Kuwait",
    code: "KW",
  },
  {
    name: "Kyrgyzstan",
    code: "KG",
  },
  {
    name: "Laos",
    code: "LA",
  },
  {
    name: "Latvia",
    code: "LV",
  },
  {
    name: "Lebanon",
    code: "LB",
  },
  {
    name: "Lesotho",
    code: "LS",
  },
  {
    name: "Liberia",
    code: "LR",
  },
  {
    name: "Libya",
    code: "LY",
  },
  {
    name: "Liechtenstein",
    code: "LI",
  },
  {
    name: "Lithuania",
    code: "LT",
  },
  {
    name: "Luxembourg",
    code: "LU",
  },
  {
    name: "Macao SAR",
    code: "MO",
  },
  {
    name: "North Macedonia",
    code: "MK",
  },
  {
    name: "Madagascar",
    code: "MG",
  },
  {
    name: "Malawi",
    code: "MW",
  },
  {
    name: "Malaysia",
    code: "MY",
  },
  {
    name: "the Maldives",
    code: "MV",
  },
  {
    name: "Mali",
    code: "ML",
  },
  {
    name: "Malta",
    code: "MT",
  },
  {
    name: "the Isle of Man",
    code: "IM",
  },
  {
    name: "Marshall Islands",
    code: "MH",
  },
  {
    name: "Martinique",
    code: "MQ",
  },
  {
    name: "Mauritania",
    code: "MR",
  },
  {
    name: "Mauritius",
    code: "MU",
  },
  {
    name: "Mayotte",
    code: "YT",
  },
  {
    name: "Mexico",
    code: "MX",
  },
  {
    name: "Micronesia",
    code: "FM",
  },
  {
    name: "Moldova",
    code: "MD",
  },
  {
    name: "Monaco",
    code: "MC",
  },
  {
    name: "Mongolia",
    code: "MN",
  },
  {
    name: "Montenegro",
    code: "ME",
  },
  {
    name: "Montserrat",
    code: "MS",
  },
  {
    name: "Morocco",
    code: "MA",
  },
  {
    name: "Mozambique",
    code: "MZ",
  },
  {
    name: "Myanmar",
    code: "MM",
  },
  {
    name: "Namibia",
    code: "NA",
  },
  {
    name: "Nauru",
    code: "NR",
  },
  {
    name: "Nepal",
    code: "NP",
  },
  {
    name: "the Netherlands",
    code: "NL",
  },
  {
    name: "New Caledonia",
    code: "NC",
  },
  {
    name: "New Zealand",
    code: "NZ",
  },
  {
    name: "Nicaragua",
    code: "NI",
  },
  {
    name: "Niger",
    code: "NE",
  },
  {
    name: "Nigeria",
    code: "NG",
  },
  {
    name: "Niue",
    code: "NU",
  },
  {
    name: "Norfolk Island",
    code: "NF",
  },
  {
    name: "North Korea",
    code: "KP",
  },
  {
    name: "Northern Mariana Islands",
    code: "MP",
  },
  {
    name: "Norway",
    code: "NO",
  },
  {
    name: "Oman",
    code: "OM",
  },
  {
    name: "Pakistan",
    code: "PK",
  },
  {
    name: "Palau",
    code: "PW",
  },
  {
    name: "Palestinian Authority",
    code: "PS",
  },
  {
    name: "Panama",
    code: "PA",
  },
  {
    name: "Papua New Guinea",
    code: "PG",
  },
  {
    name: "Paraguay",
    code: "PY",
  },
  {
    name: "Peru",
    code: "PE",
  },
  {
    name: "the Philippines",
    code: "PH",
  },
  {
    name: "Pitcairn Islands",
    code: "PN",
  },
  {
    name: "Poland",
    code: "PL",
  },
  {
    name: "Portugal",
    code: "PT",
  },
  {
    name: "Puerto Rico",
    code: "PR",
  },
  {
    name: "Qatar",
    code: "QA",
  },
  {
    name: "Reunion",
    code: "RE",
  },
  {
    name: "Romania",
    code: "RO",
  },
  {
    name: "Russia",
    code: "RU",
  },
  {
    name: "Rwanda",
    code: "RW",
  },
  {
    name: "Saint Barthélemy",
    code: "BL",
  },
  {
    name: "Saint Helena, Ascension and Tristan da Cunha",
    code: "SH",
  },
  {
    name: "Saint Kitts and Nevis",
    code: "KN",
  },
  {
    name: "Saint Lucia",
    code: "LC",
  },
  {
    name: "Saint Martin (French part)",
    code: "MF",
  },
  {
    name: "Saint Pierre and Miquelon",
    code: "PM",
  },
  {
    name: "Saint Vincent and the Grenadines",
    code: "VC",
  },
  {
    name: "Samoa",
    code: "WS",
  },
  {
    name: "San Marino",
    code: "SM",
  },
  {
    name: "São Tomé and Príncipe",
    code: "ST",
  },
  {
    name: "Saudi Arabia",
    code: "SA",
  },
  {
    name: "Senegal",
    code: "SN",
  },
  {
    name: "Serbia",
    code: "RS",
  },
  {
    name: "Seychelles",
    code: "SC",
  },
  {
    name: "Sierra Leone",
    code: "SL",
  },
  {
    name: "Singapore",
    code: "SG",
  },
  {
    name: "Sint Maarten (Dutch part)",
    code: "SX",
  },
  {
    name: "Slovakia",
    code: "SK",
  },
  {
    name: "Slovenia",
    code: "SI",
  },
  {
    name: "Solomon Islands",
    code: "SB",
  },
  {
    name: "Somalia",
    code: "SO",
  },
  {
    name: "South Africa",
    code: "ZA",
  },
  {
    name: "South Georgia and the South Sandwich Islands",
    code: "GS",
  },
  {
    name: "South Sudan",
    code: "SS",
  },
  {
    name: "Spain",
    code: "ES",
  },
  {
    name: "Sri Lanka",
    code: "LK",
  },
  {
    name: "Sudan",
    code: "SD",
  },
  {
    name: "Suriname",
    code: "SR",
  },
  {
    name: "Svalbard",
    code: "SJ",
  },
  {
    name: "Swaziland",
    code: "SZ",
  },
  {
    name: "Sweden",
    code: "SE",
  },
  {
    name: "Switzerland",
    code: "CH",
  },
  {
    name: "Syria",
    code: "SY",
  },
  {
    name: "Taiwan",
    code: "TW",
  },
  {
    name: "Tajikistan",
    code: "TJ",
  },
  {
    name: "Tanzania",
    code: "TZ",
  },
  {
    name: "Thailand",
    code: "TH",
  },
  {
    name: "Togo",
    code: "TG",
  },
  {
    name: "Tokelau",
    code: "TK",
  },
  {
    name: "Tonga",
    code: "TO",
  },
  {
    name: "Trinidad and Tobago",
    code: "TT",
  },
  {
    name: "Tunisia",
    code: "TN",
  },
  {
    name: "Turkey",
    code: "TR",
  },
  {
    name: "Turkmenistan",
    code: "TM",
  },
  {
    name: "Turks and Caicos Islands",
    code: "TC",
  },
  {
    name: "Tuvalu",
    code: "TV",
  },
  {
    name: "U.S. Minor Outlying Islands",
    code: "UM",
  },
  {
    name: "Uganda",
    code: "UG",
  },
  {
    name: "Ukraine",
    code: "UA",
  },
  {
    name: "United Arab Emirates",
    code: "AE",
  },
  {
    name: "the United Kingdom",
    code: "GB",
  },
  {
    name: "the United States",
    code: "US",
  },
  {
    name: "Uruguay",
    code: "UY",
  },
  {
    name: "Uzbekistan",
    code: "UZ",
  },
  {
    name: "Vanuatu",
    code: "VU",
  },
  {
    name: "Vatican City",
    code: "VA",
  },
  {
    name: "Vietnam",
    code: "VN",
  },
  {
    name: "the U.S. Virgin Islands",
    code: "VI",
  },
  {
    name: "the British Virgin Islands",
    code: "VG",
  },
  {
    name: "Wallis and Futuna",
    code: "WF",
  },
  {
    name: "Yemen",
    code: "YE",
  },
  {
    name: "Zambia",
    code: "ZM",
  },
  {
    name: "Zimbabwe",
    code: "ZW",
  },
] as const;

export const DEFAULT_REGION = "US";

export type Country = (typeof countries)[number];
export type CountryCode = Country["code"];

export default countries;
