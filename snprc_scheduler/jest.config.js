module.exports = {
    globals: {
        LABKEY: {},
    },
    moduleFileExtensions: [
        "ts",
        "tsx",
        "jsx",
        "js",
    ],
    testEnvironment: "jsdom",
    testPathIgnorePatterns: [
        "node_modules",
    ],
    testRegex: "(\\.(test|spec))\\.(js|jsx|ts|tsx)$",
    testResultsProcessor: "jest-teamcity-reporter",
    transform: {
        "^.+\\.(js|jsx|ts|tsx)$": [
            'ts-jest',
            {
                tsconfig: 'node_modules/@labkey/build/configs/tsconfig.test.json',
            },
        ],
    }
};