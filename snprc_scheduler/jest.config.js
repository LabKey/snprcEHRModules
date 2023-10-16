module.exports = {
    globals: {
        LABKEY: {},
    },
    moduleFileExtensions: [
        "jsx",
        "js",
    ],
    setupFilesAfterEnv: [
        "<rootDir>/src/client/tests/setupTests.js"
    ],
    testEnvironment: "jsdom",
    testPathIgnorePatterns: [
        "node_modules",
    ],
    testRegex: "(\\.(test|spec))\\.(js|jsx)$",
    testResultsProcessor: "jest-teamcity-reporter"
};