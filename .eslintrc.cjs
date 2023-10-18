module.exports = {
    root: true,
    env: {browser: true, es2024: true},
    extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/recommended',
        'plugin:react-hooks/recommended',
        "plugin:unicorn/all",
        "plugin:@typescript-eslint/recommended",
    ],
    ignorePatterns: ['node_modules/', 'build/', 'dist/', 'public/', 'vite-env.d.ts'],
    parser: '@typescript-eslint/parser',
    parserOptions: {
        "ecmaVersion": "latest",
        "sourceType": "module",
    },
    plugins: ['react-refresh', "unicorn", '@typescript-eslint'],
    rules: {
        'react-refresh/only-export-components': [
            'warn',
            {allowConstantExport: true},
        ],
    },

};
