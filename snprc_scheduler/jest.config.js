module.exports = {
    globals: {
        LABKEY: {},
    },
    moduleFileExtensions: [
        "tsx",
        "ts",
        "js",
    ],
    setupFilesAfterEnv: [
        "<rootDir>/src/client/tests/setupTests.ts"
    ],
    testEnvironment: "jsdom",
    testPathIgnorePatterns: [
        "node_modules",
    ],
    snapshotSerializers: [
        "enzyme-to-json/serializer"
    ],
    testRegex: "(\\.(test|spec))\\.(ts|tsx)$",
    testResultsProcessor: "jest-teamcity-reporter",
    transform: {
        "^.+\\.tsx?$": [
            "ts-jest",
            {
                "isolatedModules": true,
                "tsconfig": "node_modules/@labkey/build/webpack/tsconfig.json"
            }
        ]
    }
};
