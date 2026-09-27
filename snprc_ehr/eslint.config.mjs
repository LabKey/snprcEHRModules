import config from '@labkey/eslint-config';
import { globalIgnores } from 'eslint/config';

export default [
    ...config,
    globalIgnores(['.gradle/**', 'resources/**']),
    // The shared config only names ts/tsx; this module's React components are mostly .jsx
    { files: ['src/**/*.jsx'] },
];
